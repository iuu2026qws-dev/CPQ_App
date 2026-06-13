#!/usr/bin/env python3
"""E2E 测试：拦截器修复 + 属性选项 + 产品模型分页 + ECN 列表"""
import requests, json, sys

BASE = "http://localhost:8080"
CLIENT_ID = "e5cd7e4891bf95d1d19206ce24a7b32e"
pass_count = 0
fail_count = 0

def check(name, condition, detail=""):
    global pass_count, fail_count
    if condition:
        print(f"  ✅ {name} {detail}")
        pass_count += 1
    else:
        print(f"  ❌ {name} {detail}")
        fail_count += 1

def api(method, path, **kw):
    url = f"{BASE}{path}"
    r = requests.request(method, url, headers=headers, **kw)
    return r

# ===== Login =====
print("=" * 60)
print("🔐 登录")
print("=" * 60)
r = requests.post(f"{BASE}/auth/login", json={
    "clientId": CLIENT_ID, "grantType": "password",
    "username": "admin", "password": "admin123", "tenantId": "000000"
})
token_data = r.json()
check("登录成功", r.status_code == 200, f"code={r.status_code}")
token = token_data["data"]["access_token"]
headers = {"Authorization": f"Bearer {token}", "clientid": CLIENT_ID, "Content-Type": "application/json"}

# ===== Test 1: 产品模型列表分页 =====
print("\n" + "=" * 60)
print("1️⃣  产品模型列表分页 (TableDataInfo 解包修复)")
print("=" * 60)
r = api("GET", "/cpq/product/model/list", params={"pageNum": 1, "pageSize": 5})
check("HTTP 200", r.status_code == 200)
body = r.json()
print(f"    原始响应 keys: {list(body.keys()) if isinstance(body, dict) else 'NOT_DICT'}")
check("响应有 rows", "rows" in body, f"rows count={len(body.get('rows', []))}")
check("响应有 total", "total" in body, f"total={body.get('total')}")
check("rows 是数组", isinstance(body.get("rows"), list))
check("total > 0", body.get("total", 0) > 0)
if body.get("rows"):
    first = body["rows"][0]
    check("有 modelCode", "modelCode" in first)
    check("有 modelName", "modelName" in first)

# ===== Test 2: 属性选项 CRUD =====
print("\n" + "=" * 60)
print("2️⃣  属性选项 CRUD (AttributeOptionManager)")
print("=" * 60)

# 2a. 列表查询
r = api("GET", "/cpq/config/attributeoption/list", params={"modelId": 1001})
check("属性列表 HTTP 200", r.status_code == 200)
attr_data = r.json()
check("属性列表是数组", isinstance(attr_data.get("data") if "data" in attr_data else None, list) or isinstance(attr_data, list))
check("有数据 (10条)", isinstance(attr_data.get("data", []), list) and len(attr_data["data"]) == 10 or 
      isinstance(attr_data, list) and len(attr_data) == 10)

# 2b. 新增
r = api("POST", "/cpq/config/attributeoption", json={
    "modelId": 1001, "attrName": "颜色", "optionCode": "TEST-E2E-001",
    "optionLabel": "E2E测试色", "optionValue": "test_e2e_001",
    "isDefault": "0", "sortOrder": 99
})
check("新增 HTTP 200", r.status_code == 200)
new_body = r.json()
check("新增 code=200", new_body.get("code") == 200)

# 2c. 查询新增记录
r = api("GET", "/cpq/config/attributeoption/list", params={"modelId": 1001, "attrName": "颜色"})
found = False
new_id = None
data = r.json()
items = data.get("data", []) if "data" in data else data
for item in items:
    if item.get("optionCode") == "TEST-E2E-001":
        found = True
        new_id = item["optionId"]
        break
check("新增记录可查询到", found, f"optionId={new_id}")
check("已有 12 条(含测试数据)", len(items) == 12 if "TEST-RED" in str(items) else True)

# 2d. 编辑
if new_id:
    r = api("PUT", "/cpq/config/attributeoption", json={
        "optionId": new_id, "modelId": 1001, "attrName": "颜色",
        "optionCode": "TEST-E2E-001", "optionLabel": "E2E测试色(已编辑)",
        "optionValue": "test_e2e_001_v2", "isDefault": "0", "sortOrder": 50
    })
    check("编辑 HTTP 200", r.status_code == 200)
    # Verify edit
    r = api("GET", f"/cpq/config/attributeoption/{new_id}")
    detail = r.json()
    item = detail.get("data") if "data" in detail else detail
    check("编辑后的 optionLabel", item.get("optionLabel") == "E2E测试色(已编辑)")
    check("编辑后的 optionValue", item.get("optionValue") == "test_e2e_001_v2")

# 2e. 删除
if new_id:
    r = api("DELETE", f"/cpq/config/attributeoption/{new_id}")
    check("删除 HTTP 200", r.status_code == 200)
    r = api("GET", f"/cpq/config/attributeoption/{new_id}")
    detail = r.json()
    check("删除后不可查询", detail.get("code") != 200 or detail.get("data") is None)

# 2f. 清理之前TEST-RED残留
r = api("GET", "/cpq/config/attributeoption/list", params={"modelId": 1001, "attrName": "颜色"})
data = r.json()
items = data.get("data", []) if "data" in data else data
for item in items:
    code = item.get("optionCode", "")
    if code.startswith("TEST-"):
        api("DELETE", f"/cpq/config/attributeoption/{item['optionId']}")
        print(f"  🧹 清理残留: {item['optionId']} {code}")

# ===== Test 3: ECN 变更单列表 =====
print("\n" + "=" * 60)
print("3️⃣  ECN 变更单列表 (.rows 修复)")
print("=" * 60)
r = api("GET", "/cpq/ecn/order/list")
check("ECN 列表 HTTP 200", r.status_code == 200)
ecn_body = r.json()
check("ECN 响应有 data", "data" in ecn_body or isinstance(ecn_body, list))
ecn_data = ecn_body.get("data") if "data" in ecn_body else ecn_body
if isinstance(ecn_data, list):
    ecn_count = len(ecn_data)
    check(f"ECN 列表是数组 ({ecn_count} 条)", True)
else:
    check("ECN 列表是数组", False, f"type={type(ecn_data)}")

# ===== Test 4: ECN 变更单详情 =====
if isinstance(ecn_data, list) and len(ecn_data) > 0:
    ecn_id = ecn_data[0].get("changeOrderId")
    print("\n" + "=" * 60)
    print("4️⃣  ECN 审批记录 (.rows 修复)")
    print("=" * 60)
    r = api("GET", "/cpq/ecn/approval/list", params={"changeOrderId": ecn_id, "pageSize": 100})
    check("审批列表 HTTP 200", r.status_code == 200)
    app_body = r.json()
    app_data = app_body.get("data") if "data" in app_body else app_body
    check("审批记录是数组", isinstance(app_data, list), f"count={len(app_data) if isinstance(app_data, list) else 'N/A'}")

    print("\n" + "=" * 60)
    print("5️⃣  ECN 影响分析 (.rows 修复)")
    print("=" * 60)
    r = api("GET", "/cpq/ecn/impact/list", params={"changeOrderId": ecn_id, "pageSize": 100})
    check("影响分析 HTTP 200", r.status_code == 200)

# ===== Test 5: 验证拦截器对 R<T> 格式不受影响 =====
print("\n" + "=" * 60)
print("6️⃣  目录列表 (R<List<>> 格式，确保不受影响)")
print("=" * 60)
r = api("GET", "/cpq/product/catalog/list", params={"pageNum": 1, "pageSize": 200})
check("目录列表 HTTP 200", r.status_code == 200)
cat_body = r.json()
cat_data = cat_body.get("data") if "data" in cat_body else cat_body
check("目录是数组", isinstance(cat_data, list), f"count={len(cat_data) if isinstance(cat_data, list) else 'N/A'}")

# ===== Summary =====
print("\n" + "=" * 60)
print(f"📊 测试结果: {pass_count} 通过 / {pass_count + fail_count} 总共")
print("=" * 60)
if fail_count == 0:
    print("🎉 全部通过！")
    sys.exit(0)
else:
    print(f"⚠️ {fail_count} 项失败！")
    sys.exit(1)
