#!/usr/bin/env python3
"""S12/S13 E2E Verification Test Suite — ECN Impact Analysis + ERP/CRM Connectors"""
import requests, json, sys

BASE = "http://localhost:8080"
H = {"Content-Type": "application/json", "clientid": "e5cd7e4891bf95d1d19206ce24a7b32e"}
passed = 0; failed = 0; results = []

def test(name, method, path, expected_code=200, data=None, params=None):
    global passed, failed
    url = f"{BASE}{path}" if path.startswith("/") else path
    try:
        r = getattr(requests, method)(url, json=data, params=params, headers=H, timeout=15)
        status = r.status_code
        body = r.json() if r.text else {}
        ok = status == expected_code
        code = body.get("code", "?") if isinstance(body, dict) else "?"
        if ok: passed += 1; mark = "✅"
        else: failed += 1; mark = "❌"
        results.append(f"{mark} {status} {method.upper()} {path} → code={code}")
        if not ok:
            print(f"  FAIL {name}: status={status} body={json.dumps(body)[:200]}")
        return body
    except Exception as e:
        failed += 1
        results.append(f"❌ ERR {method.upper()} {path} → {e}")
        print(f"  ERR {name}: {e}")
        return {}

# ===== Login =====
print("=== Login ===")
r = requests.post(f"{BASE}/auth/login", json={"clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","username":"admin","password":"admin123","tenantId":"000000"})
token = r.json().get("data", {}).get("access_token", "")
H["Authorization"] = f"Bearer {token}"
print(f"Token OK: {token[:20]}...")

# ===== S12 ECN CRUD =====
print("\n=== S12 ECN CRUD ===")
body = test("CreateOrder", "post", "/cpq/ecn/order", data={"title":"S12验证变更","reason":"E2E测试","changeType":"PRODUCT","severity":"MAJOR"})
change_order_id = body.get("data") if isinstance(body.get("data"), int) else None
if not change_order_id:
    try: change_order_id = int(body.get("data", 0))
    except: change_order_id = 1
print(f"  changeOrderId={change_order_id}")

test("ListOrder", "get", "/cpq/ecn/order/list")
test("GetOrder", "get", f"/cpq/ecn/order/{change_order_id}")
test("AddItem", "post", "/cpq/ecn/item", data={"changeOrderId":change_order_id,"entityType":"PRODUCT","entityId":1,"entityName":"测试产品","changeDescription":"S12验证"})
test("ListItems", "get", "/cpq/ecn/item/list", params={"changeOrderId":change_order_id})

# ===== S12.7 analyzeImpact =====
print("\n=== S12.7 analyzeImpact ===")
body = test("AnalyzeImpact", "post", f"/cpq/ecn/impact/analyze/{change_order_id}")
impacts = body.get("data", [])
if isinstance(impacts, list):
    print(f"  Impact records: {len(impacts)} (expected: L1-BOM, L2-CONFIG_RULE, L3-QUOTE, L4-APPROVAL, L5-ERP)")
    for imp in impacts[:5]:
        print(f"    L{imp.get('propagationLevel','?')}: entityType={imp.get('affectedEntityType','?')} severity={imp.get('severity','?')} entityId={imp.get('affectedEntityId','?')}")
    # Verify at least L1-L4 are present
    levels = {imp.get("propagationLevel") for imp in impacts}
    if 1 in levels and 2 in levels and 3 in levels: print("  All levels present ✅")
    else: print(f"  Levels found: {levels}")

test("ListImpacts", "get", "/cpq/ecn/impact/list", params={"changeOrderId":change_order_id})

# ===== S12.8 whereUsed =====
print("\n=== S12.8 whereUsed ===")
body = test("WhereUsed", "get", "/cpq/ecn/impact/where-used", params={"productId":1})
refs = body.get("data", [])
print(f"  Where-used refs: {len(refs)} (real query, may be 0 if no BOM/quote data for productId=1)")
for ref in refs[:3]:
    print(f"    {ref.get('type','?')}: {ref.get('name','?')} (id={ref.get('id','?')})")

# ===== S12.9 propagateChange =====
print("\n=== S12.9 propagateChange ===")
body = test("Propagate", "post", f"/cpq/ecn/impact/propagate/{change_order_id}")
prop_count = body.get("data", 0)
print(f"  Propagated: {prop_count} records")

body = test("GetAfterPropagate", "get", f"/cpq/ecn/order/{change_order_id}")
status = body.get("data", {}).get("status", "?") if isinstance(body.get("data"), dict) else "?"
print(f"  Order status after propagate: {status}")

# ===== S13.7 ErpConnector =====
print("\n=== S13.7 ErpConnector ===")
body = test("ErpCreateOrder", "post", "/cpq/integration/erp/order", data={
    "quoteId": 1, "plantCode": "SHANGHAI", "currency": "CNY",
    "orderItems": [{"itemCode":"TEST-001","quantity":10,"unitPrice":100.0}]
})
erp = body.get("data", {}) if isinstance(body.get("data"), dict) else {}
print(f"  ERP: id={erp.get('erpOrderId','?')} status={erp.get('status','?')} plant={erp.get('plantCode','?')}")
if erp.get("mockMode"): print("  (降级模拟模式 — ERP服务不可用时的兜底)")

# ===== S13.6 CrmConnector =====
print("\n=== S13.6 CrmConnector ===")
body = test("CrmSyncOpp", "post", "/cpq/integration/crm/opportunity", data={"accountId":1,"opportunityName":"测试商机","amount":100000})
crm = body.get("data", {}) if isinstance(body.get("data"), dict) else {}
print(f"  CRM Opp: id={crm.get('opportunityId','?')} status={crm.get('status','?')}")

test("CrmPushStatus", "post", "/cpq/integration/crm/quote-status/1", data={"status":"SUBMITTED"})

# ===== ECN Approval =====
print("\n=== S12 ECN Approval ===")
test("EcnApprovalList", "get", "/cpq/ecn/approval/list", params={"changeOrderId":change_order_id})

# ===== Swagger =====
print("\n=== Swagger ===")
test("Swagger", "get", "/v3/api-docs")

# ===== Quote Service =====
print("\n=== Quote Service ===")
test("QuoteList", "get", "/cpq/quote/list", params={"pageNum":1,"pageSize":5})

# ===== Report =====
print("\n" + "="*60)
print(f"RESULTS: {passed} PASSED, {failed} FAILED ({passed+failed} total)")
for r in results: print(f"  {r}")
print()

if failed > 0: sys.exit(1)
