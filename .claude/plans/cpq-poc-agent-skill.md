---
name: cpq-poc-match
description: |
  CPQ POC 锂原电池标品匹配推荐 Agent。使用 LangGraph 状态机实现
  需求采集→智能引导→评分匹配→结果展示→工艺确认 全流程。
  触发场景：用户说"帮我找电池"、"推荐一款锂亚电池"、"电池选型"等。
---

# CPQ POC — 锂原电池标品匹配推荐 Agent

## 一、LangGraph 状态机

```python
from typing import TypedDict
from langgraph.graph import StateGraph, END
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage

class MatchState(TypedDict):
    messages: list[BaseMessage]          # 对话历史
    stage: str                           # guiding/collecting/matching/presenting/confirming
    category_id: int                     # 产品线ID，默认507(锂亚ER)
    requirements: dict                   # 已采集的6维需求 {usageType, tempMin, tempMax, ...}
    collected_count: int                 # 已采集维度数 0-6
    match_result: dict | None            # match_product 返回的完整结果
    selected_model_id: int | None        # 用户选定的产品ID
    rematch_count: int                   # 重匹配次数，最大2
    error: str | None                    # 错误信息
```

### 节点定义

```
        ┌──────────────────────────────────────────────────────┐
        │                     START                            │
        └─────────┬────────────────────────────────────────────┘
                  │
                  ▼
        ┌──────────────────┐
        │  ① guide_node     │  ← LLM 追问第一轮（无Tool）
        │  解析已有维度      │
        │  生成追问(1-2维)   │
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐   维度<3     ┌──────────────────┐
        │  ② collect_node  │ ──────────→  │  ② collect_node  │
        │  解析用户补充      │ ←────────── │  (继续追问)       │
        │  合并到requirements│             │  无Tool            │
        └────────┬─────────┘              └──────────────────┘
                 │ 维度>=3
                 ▼
        ┌──────────────────┐
        │  ③ match_node    │  ← 调用 match_product(507, requirements)
        │  带Tool执行        │     Tool: match_product
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │  ④ present_node  │  ← LLM 格式化Top10为产品卡片
        │  无Tool(纯LLM)    │     包含: 型号/主图/核心参数/差异/报价/AI理由
        └────────┬─────────┘
                 │
          ┌──────┼──────┐
          │      │      │
     选产品  重匹配<2  重匹配>=3
          │      │      │
          ▼      ▼      ▼
        ┌────┐ ┌────┐ ┌────┐
        │ ⑤ │ │ ②  │ │END │
        └────┘ └────┘ └────┘
    confirm_node  继续追问  转定制
    Tool: submit_
    feasibility_
    confirm
```

### 路由逻辑

```python
def route_after_guide(state: MatchState):
    """首轮引导后 → 维度已够则match，不够则collect"""
    if state["collected_count"] >= 3:
        return "match"
    return "collect"

def route_after_collect(state: MatchState):
    """采集后 → >=3维进match，否则继续追问"""
    if state["collected_count"] >= 3:
        return "match"
    return "collect"

def route_after_present(state: MatchState):
    """结果展示后 → 用户选产品则confirm，否则检查重匹配"""
    if state.get("selected_model_id"):
        return "confirm"
    if state.get("rematch_count", 0) < 2:
        return "collect"
    return END  # → 转定制建议

def route_after_confirm(state: MatchState):
    return END
```

## 二、Tool 定义

```python
# 只暴露2个Tool给Agent
@tool
def match_product(category_id: int, requirements: dict) -> dict:
    """6维评分匹配锂原电池。收集到>=3维度后调用。返回Top10+评分明细。
    
    Args:
        category_id: 产品线ID (507=锂亚ER)
        requirements: {
            usageType: str,        # 用途（智能水表/安防/...）
            tempMin: number,       # 温度下限(℃)
            tempMax: number,       # 温度上限(℃)
            sealLevel: str,        # 防护等级(IP54/IP65/IP67/IP68)
            lifeCycleYears: number,# 期望寿命(年)
            requiredCertifications: [str],  # 认证要求
            dimensions: {length, width, height}  # 尺寸(mm)
        }
    
    Returns:
        {resultId, sessionId, recommendations: [{rank, modelCode, modelName,
         imageUrl, coreParams, matchDifferences, priceRange, aiReason,
         totalScore, dimensionScores, moq, leadTimeDays}], thresholdPassed, ...}
    """
    ...

@tool
def submit_feasibility_confirm(result_id: int, model_id: int, 
                                 action: str = "CONFIRM",
                                 replaced_model_id: int = None,
                                 replaced_reason: str = "") -> dict:
    """提交工艺审核。action: CONFIRM/REJECT/REPLACE。
    REPLACE时传入替代产品ID和理由，工艺可直接推荐替代品。
    """
    ...
```

## 三、System Prompt（按节点定制）

```python
GUIDE_PROMPT = """你是亿纬锂能电池选型助手。用户需要匹配锂亚ER电池。

## 你的任务
根据用户的第一条消息，追问1-2个缺失的需求维度。
六维需求：用途、温度、尺寸、密封等级、寿命、认证。

## 规则
- 只问1-2个关键维度，不要问太多
- 简短回复，1-2句话
- 不调用任何工具
- 不加结束语"""

COLLECT_PROMPT = """你是亿纬锂能电池选型助手。正在采集客户需求。

## 你的任务
分析用户最新消息，提取需求维度，追问剩余缺失维度。

## 当前已采集: {collected_dimensions}/6
## 缺失维度: {missing_dimensions}

## 规则
- 如果已>=3维，不要追问，回复"好的，开始匹配"触发匹配
- 问到>=3维后停止
- 每轮最多追问1-2个维度
- 不加结束语"""

PRESENT_PROMPT = """你是亿纬锂能电池选型助手。匹配结果已出。

## 输出格式
用 markdown 表格展示 Top10，每款包含：
| 排名 | 型号 | 主图 | 核心参数 | 匹配差异 | 报价区间 | AI理由 |
|------|------|------|----------|----------|----------|--------|
"""
```

## 四、SSE 事件契约

| 事件类型 | 触发时机 | data 格式 | 前端渲染 |
|----------|----------|-----------|----------|
| `status` | 处理中/工具调用 | `{status: "processing"/"tool_call"/"tool_result"}` | 状态提示 |
| `message_delta` | LLM 流式文本 | `{content: "..."}` | Markdown |
| `match_result` | match_product 完成 | `MatchResult` 完整JSON | **MatchResultCard** |
| `done` | 流程结束 | `{status: "completed"}` | 停止loading |
| `error` | 异常 | `{error: "..."}` | 错误提示 |

**关键**：`match_result` 事件包含完整的结构化数据，前端不解析 markdown，直接用 `MatchResultCard` 渲染。

## 五、文件变更清单

| 文件 | 操作 | 说明 |
|------|:---:|------|
| `backend/agent.py` | 重写 | 移除旧流程，用 LangGraph StateGraph |
| `backend/tools.py` | 不变 | match_product + submit_feasibility_confirm 已就绪 |
| `backend/server.py` | 改 | 用 agent graph 的 astream 替换简单 prompt |
| `frontend/src/types/index.ts` | 不变 | MatchResult 类型已就绪 |
| `frontend/src/components/widgets/MatchResultCard.vue` | 改 | 确保6要素齐全 |
| `frontend/src/api/agent.ts` | 不变 | match_result 事件已处理 |
| `frontend/src/stores/chat.ts` | 不变 | matchResult 存储已就绪 |

## 六、测试清单

- [ ] 首轮追问：输入"帮我找智能水表电池" → Agent追问1-2个维度，无API调用
- [ ] 逐轮采集：追问2轮后>=3维 → 自动触发匹配
- [ ] 产品卡片：match_result事件包含10个字段（型号/主图/核心参数/差异/报价/AI理由/评分/moq/交期/维度明细）
- [ ] 工艺CONFIRM：选定产品 → submit_feasibility_confirm → 返回CONFIRMED
- [ ] 工艺REPLACE：工艺推荐替代产品 → 展示替代型号和理由
- [ ] 异常兜底：API超时 → 提示手动查询，不崩溃
- [ ] 转定制：3次重匹配仍无结果 → 建议转定制
