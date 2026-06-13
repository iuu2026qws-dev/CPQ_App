#!/bin/bash
# CPQ Menu E2E Test
B="http://localhost:5173"
P=playwright-cli

test_page() {
  name="$1"; path="$2"
  $P goto "$B$path" > /dev/null 2>&1
  sleep 2
  url=$($P eval "window.location.href" 2>/dev/null | tail -1 | tr -d '"')
  body=$($P eval "document.body.innerText.substring(0,80)" 2>/dev/null | tail -1 | tr -d '"')
  if echo "$url" | grep -q "dashboard" && [ "$path" != "/dashboard" ]; then
    printf "%-30s ❌ REDIRECTED\n" "$name ($path)"
  elif echo "$body" | grep -q "建设中"; then
    printf "%-30s ❌ PLACEHOLDER\n" "$name ($path)"
  elif [ -z "$body" ] || [ ${#body} -lt 30 ]; then
    printf "%-30s ❌ EMPTY(${#body})\n" "$name ($path)"
  else
    printf "%-30s ✅ PASS [%s...]\n" "$name ($path)" "$body"
  fi
}

echo "=== CPQ Menu E2E Test ==="
echo ""

test_page "产品目录" "/cpq/product/catalog"
test_page "产品模型" "/cpq/product/model"
test_page "配置规则" "/cpq/product/rules"
test_page "替代品管理" "/cpq/product/supersession"
test_page "产品分类管理" "/cpq/product/category"
test_page "产品搜索" "/cpq/configure/search"
test_page "标准配置" "/cpq/configure/standard"
test_page "向导式配置" "/cpq/configure/guided"
test_page "ATO配置" "/cpq/configure/ato"
test_page "报价单列表" "/cpq/quoting/list"
test_page "新建报价" "/cpq/quoting/create"
test_page "报价模板" "/cpq/quoting/templates"
test_page "方案列表" "/cpq/solution/list"
test_page "方案对比" "/cpq/solution/compare"
test_page "待我审批" "/cpq/approval/pending"
test_page "我已审批" "/cpq/approval/processed"
test_page "我发起的" "/cpq/approval/initiated"
test_page "效率看板" "/cpq/approval/analytics"
test_page "任务看板" "/cpq/presales/board"
test_page "评审工作台" "/cpq/presales/review"
test_page "竞品库" "/cpq/competitive/library"
test_page "对比分析" "/cpq/competitive/compare"
test_page "价格手册" "/cpq/pricing/books"
test_page "定价规则" "/cpq/pricing/rules"
test_page "阶梯定价" "/cpq/pricing/volume"
test_page "交期检查" "/cpq/atpctp/check"
test_page "批量查询" "/cpq/atpctp/batch"
test_page "SLA看板" "/cpq/atpctp/sla"
test_page "产品知识" "/cpq/knowledge/products"
test_page "销售话术" "/cpq/knowledge/scripts"
test_page "成功案例" "/cpq/knowledge/cases"
test_page "培训认证" "/cpq/knowledge/training"
test_page "CRM连接器" "/cpq/integration/crm"
test_page "ERP连接器" "/cpq/integration/erp"
test_page "PLM连接器" "/cpq/integration/plm"
test_page "同步日志" "/cpq/integration/logs"
test_page "租户配置" "/cpq/settings/tenant"
test_page "用户管理" "/cpq/settings/users"
test_page "角色管理" "/cpq/settings/roles"
test_page "ABAC策略" "/cpq/settings/abac"
test_page "审计日志" "/cpq/settings/audit"
test_page "数据迁移" "/cpq/settings/migration"
test_page "变更管理" "/cpq/settings/ecn"
test_page "系统参数" "/cpq/settings/params"

echo ""
echo "=== Done ==="
