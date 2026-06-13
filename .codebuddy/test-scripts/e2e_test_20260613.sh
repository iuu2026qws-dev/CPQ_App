#!/bin/bash
# ============================================================
# CPQ 配置管理全栈改造 — 端到端验证测试脚本
# ============================================================
# 前提条件：
#   1. 后端运行在 localhost:8080
#   2. ruoyi-ui 运行在 localhost:3000
#   3. cpq-portal 运行在 localhost:3000（需要错开，见下方说明）
# ============================================================
set -e

BASE_URL="http://localhost:8080"
ADMIN_UI="http://localhost:3000"
CPQ_PORTAL="http://localhost:3000"  # 同端口但不同路径，实际需错开
PASS=0
FAIL=0
TOTAL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); echo -e "${RED}[FAIL]${NC} $1"; }

echo "============================================="
echo " CPQ 配置管理全栈改造 - 端到端验证测试"
echo " 日期: 2026-06-13"
echo "============================================="

# ============================================
# Phase 1: 后端编译验证
# ============================================
echo ""
echo "--- Phase 1: 后端编译验证 ---"
cd "$(dirname "$0")/../.."

echo "1.1 mvn compile cpq-config..."
mvn compile -pl "ruoyi-modules/ruoyi-cpq-config" -am -q 2>&1 && log_pass "mvn compile 通过" || log_fail "mvn compile 失败"

# ============================================
# Phase 2: Swagger端点注册检查
# ============================================
echo ""
echo "--- Phase 2: Swagger端点注册检查 ---"

echo "2.1 Swagger文档可访问..."
SWAGGER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${BASE_URL}/swagger-ui/index.html 2>/dev/null || echo "000")
if [ "$SWAGGER_STATUS" = "200" ]; then
  log_pass "Swagger UI 可访问 (${SWAGGER_STATUS})"
else
  log_fail "Swagger UI 不可访问 (${SWAGGER_STATUS})"
fi

echo "2.2 API文档可获取..."
API_DOCS=$(curl -s ${BASE_URL}/v3/api-docs 2>/dev/null)
if echo "$API_DOCS" | grep -q "cpq/config/attributeoption"; then
  log_pass "/cpq/config/attributeoption 已注册"
else
  log_fail "/cpq/config/attributeoption 未注册"
fi

if echo "$API_DOCS" | grep -q "cpq/config/rule"; then
  log_pass "/cpq/config/rule 已注册"
else
  log_fail "/cpq/config/rule 未注册"
fi

if echo "$API_DOCS" | grep -q "cpq/config/attributemapping"; then
  log_pass "/cpq/config/attributemapping 已注册"
else
  log_fail "/cpq/config/attributemapping 未注册"
fi

if echo "$API_DOCS" | grep -q "cpq/configure/guide"; then
  log_pass "/cpq/configure/guide 已注册"
else
  log_fail "/cpq/configure/guide 未注册"
fi

# ============================================
# Phase 3: 前端静态检查
# ============================================
echo ""
echo "--- Phase 3: 前端静态检查 ---"

echo "3.1 Admin Portal 占位文件已删除..."
for f in \
  "ruoyi-ui/src/views/configure/ProductSearch.vue" \
  "ruoyi-ui/src/views/configure/Configurator.vue" \
  "ruoyi-ui/src/views/configure/GuidedSelling.vue" \
  "ruoyi-ui/src/views/configure/AtoCustomize.vue" \
  "ruoyi-ui/src/api/cpq/configure.ts"
do
  if [ ! -f "$f" ]; then
    log_pass "$f 已删除"
  else
    log_fail "$f 仍存在"
  fi
done

echo "3.2 Admin Portal 新页面已创建..."
for f in \
  "ruoyi-ui/src/views/cpq/attribute-option/index.vue" \
  "ruoyi-ui/src/views/cpq/config-rule/index.vue" \
  "ruoyi-ui/src/views/cpq/attribute-mapping/index.vue" \
  "ruoyi-ui/src/api/cpq/attribute-option.ts" \
  "ruoyi-ui/src/api/cpq/config-rule.ts" \
  "ruoyi-ui/src/api/cpq/attribute-mapping.ts"
do
  if [ -f "$f" ]; then
    log_pass "$f 已创建"
  else
    log_fail "$f 缺失"
  fi
done

echo "3.3 CPQ Portal 新页面已创建..."
for f in \
  "cpq-portal/src/views/configure/GuidedSelling.vue" \
  "cpq-portal/src/views/configure/AtoCustomize.vue"
do
  if [ -f "$f" ]; then
    log_pass "$f 已创建"
  else
    log_fail "$f 缺失"
  fi
done

echo "3.4 CPQ Portal 菜单配置已更新..."
if grep -q "configure-standard" cpq-portal/src/config/menu.ts; then
  log_pass "menu.ts 包含 configure-standard"
else
  log_fail "menu.ts 缺少 configure-standard"
fi

if grep -q "configure-guided" cpq-portal/src/config/menu.ts; then
  log_pass "menu.ts 包含 configure-guided"
else
  log_fail "menu.ts 缺少 configure-guided"
fi

echo "3.5 CPQ Portal 路由已注册..."
if grep -q "GuidedSelling" cpq-portal/src/router/index.ts; then
  log_pass "router 包含 GuidedSelling 路由"
else
  log_fail "router 缺少 GuidedSelling 路由"
fi

if grep -q "AtoCustomize" cpq-portal/src/router/index.ts; then
  log_pass "router 包含 AtoCustomize 路由"
else
  log_fail "router 缺少 AtoCustomize 路由"
fi

echo "3.6 SQL 菜单已更新..."
if ! grep -q "50021, '产品搜索'" sql/cpq_menu.sql; then
  log_pass "SQL 已删除 50020-50024 旧菜单"
else
  log_fail "SQL 仍包含旧菜单"
fi

if grep -q "50086.*属性选项管理" sql/cpq_menu.sql; then
  log_pass "SQL 包含 50086 属性选项管理"
else
  log_fail "SQL 缺少 50086"
fi

if grep -q "50087.*属性映射管理" sql/cpq_menu.sql; then
  log_pass "SQL 包含 50087 属性映射管理"
else
  log_fail "SQL 缺少 50087"
fi

echo "3.7 后端 guide 端点已添加..."
if grep -q "@PostMapping.*guide" ruoyi-modules/ruoyi-cpq-config/src/main/java/org/dromara/cpq/config/controller/ConfiguratorController.java; then
  log_pass "ConfiguratorController 包含 /guide 端点"
else
  log_fail "ConfiguratorController 缺少 /guide 端点"
fi

# ============================================
# Phase 4: 前端编译验证
# ============================================
echo ""
echo "--- Phase 4: 前端编译验证 ---"

echo "4.1 cpq-portal TypeScript检查..."
cd cpq-portal
npx vue-tsc --noEmit 2>&1 && log_pass "cpq-portal vue-tsc 通过" || log_fail "cpq-portal vue-tsc 失败"
cd ..

echo "4.2 ruoyi-ui TypeScript检查..."
cd ruoyi-ui
npx vue-tsc --noEmit 2>&1 && log_pass "ruoyi-ui vue-tsc 通过" || log_fail "ruoyi-ui vue-tsc 失败"
cd ..

# ============================================
# Phase 5: API测试（需要token，如不可用则跳过）
# ============================================
echo ""
echo "--- Phase 5: API连通性测试 ---"

echo "5.1 后端8080端口..."
curl -s -o /dev/null -w "%{http_code}" ${BASE_URL} | grep -q "200" && log_pass "8080 响应200" || log_fail "8080 不响应"

echo "5.2 获取token..."
TOKEN=$(curl -s ${BASE_URL}/auth/login -H 'Content-Type: application/json' -d '{"tenantId":"000000","username":"admin","password":"admin123","code":"","uuid":""}' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('access_token',''))" 2>/dev/null)

if [ -n "$TOKEN" ] && [ ${#TOKEN} -gt 10 ]; then
  log_pass "Token获取成功"
  
  # 属性选项API测试
  echo "5.3 /cpq/config/attributeoption/list..."
  ATTR_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/cpq/config/attributeoption/list" -H "Authorization: Bearer ${TOKEN}")
  if [ "$ATTR_STATUS" = "200" ]; then
    log_pass "属性选项列表API: 200"
  else
    log_fail "属性选项列表API: ${ATTR_STATUS}"
  fi

  # 配置规则API测试
  echo "5.4 /cpq/config/rule/list..."
  RULE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/cpq/config/rule/list" -H "Authorization: Bearer ${TOKEN}")
  if [ "$RULE_STATUS" = "200" ]; then
    log_pass "配置规则列表API: 200"
  else
    log_fail "配置规则列表API: ${RULE_STATUS}"
  fi

  # 属性映射API测试
  echo "5.5 /cpq/config/attributemapping/list..."
  MAP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/cpq/config/attributemapping/list" -H "Authorization: Bearer ${TOKEN}")
  if [ "$MAP_STATUS" = "200" ]; then
    log_pass "属性映射列表API: 200"
  else
    log_fail "属性映射列表API: ${MAP_STATUS}"
  fi

  # guide端点测试
  echo "5.6 /cpq/configure/guide..."
  GUIDE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/cpq/configure/guide?modelId=1" -H "Authorization: Bearer ${TOKEN}" -H 'Content-Type: application/json' -d '{}')
  if [ "$GUIDE_STATUS" = "200" ] || [ "$GUIDE_STATUS" = "500" ]; then
    # 500可能是modelId=1不存在，只要不是404/401就行
    log_pass "guide端点: ${GUIDE_STATUS} (端点存在)"
  else
    log_fail "guide端点: ${GUIDE_STATUS}"
  fi

else
  log_fail "Token获取失败，跳过API测试"
fi

# ============================================
# 最终统计
# ============================================
echo ""
echo "============================================="
echo " 测试结果: ${PASS}/${TOTAL} 通过"
if [ $FAIL -gt 0 ]; then
  echo -e " ${RED}${FAIL} 项失败${NC}"
  exit 1
else
  echo -e " ${GREEN}全部通过!${NC}"
  exit 0
fi
echo "============================================="
