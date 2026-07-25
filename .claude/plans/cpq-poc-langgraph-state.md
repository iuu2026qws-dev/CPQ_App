# CPQ POC — LangGraph 状态流转设计

## State 定义

```python
class ConversationState(TypedDict):
    # 对话消息
    messages: list[BaseMessage]
    
    # 当前阶段: guiding / collecting / matching / presenting / confirming
    stage: str
    
    # 已采集的需求维度 (6维)
    requirements: dict  # {usageType, tempMin, tempMax, sealLevel, lifeCycleYears, 
                        #  requiredCertifications: [], dimensions: {length, width, height}}
    
    # 已采集维度计数
    collected_dimensions: int  # 0-6
    
    # 匹配结果
    match_result: dict | None  # match_product 返回的完整结果
    
    # 用户选定的产品
    selected_model_id: int | None
    
    # 工艺确认结果
    confirm_result: dict | None
    
    # 重匹配计数
    rematch_count: int  # 默认0，最大2
    
    # 错误信息
    error: str | None
```

## 节点 (Nodes)

```
┌─────────┐      ┌──────────┐      ┌───────────┐
│ ① guide │ ───→ │ ② collect│ ───→ │ ③ match   │
│ 首轮引导 │      │ 逐轮采集  │      │ 评分匹配   │
│ 无Tool   │      │ 无Tool    │      │ Tool:match │
└─────────┘      └──────────┘      └─────┬─────┘
                     ↑                    │
                     │ 维度<3              │ API返回
                     └────────────────────┘
                     │                    ▼
                     │              ┌───────────┐
                     │              │ ④ present │
                     │              │ 结果展示   │
                     │              │ 无Tool     │
                     │              └─────┬─────┘
                     │                    │
                     │        用户选产品    │ 用户说"重试"/
                     │        调用confirm  │ rematch_count<2
                     │                    ▼
                     │              ┌───────────┐
                     └──────────────│ ⑤ confirm │
                                    │ 工艺确认   │
                                    │ Tool:conf  │
                                    └───────────┘
```

### ① guide — 首轮引导
- **触发**: 用户首条消息
- **逻辑**: 
  - 解析用户输入，用 LLM 提取已有的需求维度
  - 如果 >=3 维度 → 直接跳 ③ match
  - 否则 → LLM 生成追问（1-2句），询问缺失的关键维度
- **Tool**: ❌ 无
- **输出**: stage='collecting', collected_dimensions 更新

### ② collect — 逐轮采集
- **触发**: guide 之后，每次用户补充信息
- **逻辑**:
  - 解析用户消息，合并到 requirements
  - 统计 collected_dimensions
  - 如果 >=3 维度 → 跳 ③ match
  - 否则 → 继续追问下一个缺失维度
  - 如果用户说"就这些/开始匹配/帮我推荐"且 >=2 维度 → 跳 ③
- **Tool**: ❌ 无
- **输出**: stage='matching' 或保持 'collecting'

### ③ match — 评分匹配
- **触发**: 维度 >= 3
- **逻辑**: 
  - 调用 `match_product(categoryId=507, requirements)`
  - 如果 API 失败 → error 节点
  - 如果 totalScored == 0 → 提示转定制
- **Tool**: ✅ match_product
- **输出**: stage='presenting', match_result

### ④ present — 结果展示
- **触发**: match 完成
- **逻辑**:
  - 用 LLM 格式化 Top10 为产品卡片
  - 每张卡片: 型号/核心参数/差异点/报价/AI理由
  - 低于70分不展示
  - 等用户响应: "选第X款" / "重试" / "确认"
- **Tool**: ❌ 无
- **输出**: 展示 → 等待用户选择

### ⑤ confirm — 工艺确认
- **触发**: 用户选定产品
- **逻辑**:
  - 调用 `submit_feasibility_confirm(resultId, modelId, "CONFIRM")`
  - 展示审核状态: PENDING → 轮询 → CONFIRMED/REPLACED/REJECTED
- **Tool**: ✅ submit_feasibility_confirm
- **输出**: stage=结束

## 路由 (Edges)

```python
def route_after_guide(state):
    if state["collected_dimensions"] >= 3:
        return "match"
    return "collect"

def route_after_collect(state):
    if state["collected_dimensions"] >= 3:
        return "match"
    return "collect"  # 继续追问

def route_after_present(state):
    if state.get("selected_model_id"):
        return "confirm"
    if state["rematch_count"] < 2:
        return "collect"  # 重匹配
    return END  # 转定制，结束

def route_after_match(state):
    if state.get("error"):
        return END  # 异常退出
    return "present"
```

## 状态图

```
START
  │
  ▼
guide ──(>=3维)──→ match ──→ present ──→ confirm ──→ END
  │                  ↑                      │
  │                  │ (rematch<2)          │
  ▼                  │                      │
collect ──(>=3维)───→┘                      │
  │                                         │
  │ (<3维，继续追问)                          │
  └──────────────→ collect                  │
                                            │
  present ──(无匹配)──→ END (建议转定制)      │
  present ──(rematch>=3)→ END (建议转定制)   │
                                            │
  match ──(error)──→ END (异常兜底)         │
```

---

## 确认点

| # | 确认项 | 
|---|--------|
| 1 | 5 个节点: guide/collect/match/present/confirm |
| 2 | ① ② 阶段不给任何 Tool，纯 LLM 追问 |
| 3 | ③ ⑤ 阶段才有 Tool（match_product / submit_feasibility_confirm） |
| 4 | ≥3 维度触发匹配（不再用之前的 4 维） |
| 5 | 重匹配最多 2 次 |
| 6 | 异常/无匹配 → 友好提示 + 转定制建议 |
