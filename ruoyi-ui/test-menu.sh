#!/bin/bash
# CPQ Menu E2E Test Script using playwright-cli
set -e

BASE="http://localhost:5173"
PCLI="playwright-cli"
PASS=0
FAIL=0
RESULTS=""

check_page() {
  local name="$1"
  local path="$2"
  echo "--- Testing: $name ($path) ---"
  
  $PCLI goto "$BASE$path" 2>/dev/null
  sleep 2
  
  # Take snapshot and check content
  SNAP=$($PCLI snapshot --filename="snap_${name// /_}.yaml" 2>/dev/null; cat .playwright-cli/snap_${name// /_}.yaml 2>/dev/null | tail -30)
  
  # Check if redirected to dashboard
  URL=$($PCLI eval "window.location.href" 2>/dev/null | tail -1)
  
  # Check body text
  BODY=$($PCLI eval "document.body.innerText.substring(0,200)" 2>/dev/null | tail -1)
  
  if echo "$URL" | grep -q "dashboard" && [ "$path" != "/dashboard" ]; then
    echo "  ❌ REDIRECTED to dashboard"
    FAIL=$((FAIL+1))
    RESULTS+="❌ $name → dashboard redirect\n"
  elif echo "$BODY" | grep -q "页面建设中"; then
    echo "  ❌ PLACEHOLDER: 页面建设中"
    FAIL=$((FAIL+1))
    RESULTS+="❌ $name → 页面建设中\n"
  elif [ -z "$BODY" ] || [ ${#BODY} -lt 100 ]; then
    echo "  ❌ EMPTY/TOO SHORT"
    FAIL=$((FAIL+1))
    RESULTS+="❌ $name → empty page\n"
  else
    echo "  ✅ PASS"
    PASS=$((PASS+1))
    RESULTS+="✅ $name\n"
  fi
}

# Open browser and login
echo "=== Opening browser and logging in ==="
$PCLI open "$BASE/login" 2>/dev/null
sleep 3

# Login
$PCLI fill "@username" "admin" 2>/dev/null || $PCLI type "admin" 2>/dev/null
sleep 1
# Try different selector approaches
$PCLI snapshot --filename=login.yaml 2>/dev/null
cat .playwright-cli/login.yaml 2>/dev/null | head -40

echo "=== Starting menu tests ==="
echo ""

# Product Management (should all pass)
check_page "产品目录" "/cpq/product/catalog"
check_page "产品模型" "/cpq/product/model"
check_page "配置规则" "/cpq/product/rules"
check_page "替代品管理" "/cpq/product/supersession"
check_page "产品分类管理" "/cpq/product/category"

# Configure
check_page "产品搜索" "/cpq/configure/search"
check_page "新建标准配置" "/cpq/configure/standard"
check_page "向导式配置" "/cpq/configure/guided"
check_page "ATO定制配置" "/cpq/configure/ato"

# Quoting
check_page "报价单列表" "/cpq/quoting/list"
check_page "新建报价" "/cpq/quoting/create"
check_page "报价模板" "/cpq/quoting/templates"

# Solution
check_page "方案列表" "/cpq/solution/list"
check_page "方案对比" "/cpq/solution/compare"

# Approval
check_page "待我审批" "/cpq/approval/pending"
check_page "我已审批" "/cpq/approval/processed"
check_page "我发起的" "/cpq/approval/initiated"
check_page "效率看板" "/cpq/approval/analytics"

# Presales
check_page "任务看板" "/cpq/presales/board"
check_page "评审工作台" "/cpq/presales/review"

# Competitive
check_page "竞品库" "/cpq/competitive/library"
check_page "对比分析" "/cpq/competitive/compare"

# Pricing
check_page "价格手册" "/cpq/pricing/books"
check_page "定价规则" "/cpq/pricing/rules"
check_page "阶梯定价" "/cpq/pricing/volume"

# ATP/CTP
check_page "交期检查" "/cpq/atpctp/check"
check_page "批量查询" "/cpq/atpctp/batch"
check_page "SLA看板" "/cpq/atpctp/sla"

# Knowledge
check_page "产品知识" "/cpq/knowledge/products"
check_page "销售话术" "/cpq/knowledge/scripts"
check_page "成功案例" "/cpq/knowledge/cases"
check_page "培训认证" "/cpq/knowledge/training"

# Integration
check_page "CRM连接器" "/cpq/integration/crm"
check_page "ERP连接器" "/cpq/integration/erp"
check_page "PLM连接器" "/cpq/integration/plm"
check_page "同步日志" "/cpq/integration/logs"

# Settings
check_page "租户配置" "/cpq/settings/tenant"
check_page "用户管理" "/cpq/settings/users"
check_page "角色管理" "/cpq/settings/roles"
check_page "ABAC策略" "/cpq/settings/abac"
check_page "审计日志" "/cpq/settings/audit"
check_page "数据迁移" "/cpq/settings/migration"
check_page "变更管理" "/cpq/settings/ecn"
check_page "系统参数" "/cpq/settings/params"

echo ""
echo "=== Test Results ==="
echo -e "$RESULTS"
echo "Total: $PASS PASS / $FAIL FAIL / $((PASS+FAIL)) TOTAL"

$PCLI close 2>/dev/null

[ $FAIL -eq 0 ] && exit 0 || exit 1
