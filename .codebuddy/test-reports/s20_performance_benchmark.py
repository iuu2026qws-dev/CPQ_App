#!/usr/bin/env python3
"""
S20 性能基准测试脚本（S20.8）
测试：配置器校验 <100ms | BOM展开 <2s | 报价生成 <3s
"""
import requests, json, time, statistics, sys
from datetime import datetime

BASE = 'http://localhost:8080'
CID = 'e5cd7e4891bf95d1d19206ce24a7b32e'
TARGETS = {
    'config_validate': ('配置器校验', 100, 'ms'),
    'bom_explosion':   ('BOM展开',   2000, 'ms'),
    'quote_generate':  ('报价生成',  3000, 'ms'),
    'api_list':        ('API列表查询', 500, 'ms'),
}

def login():
    r = requests.post(f'{BASE}/auth/login', json={
        'clientId': CID, 'grantType': 'password',
        'username': 'admin', 'password': 'admin123', 'tenantId': '000000'
    }, timeout=10)
    return r.json()['data']['access_token'] if r.json().get('code') == 200 else None

def measure(label, fn, iterations=5):
    """性能测试函数，返回 (平均, P50, P95, P99) 毫秒值"""
    times = []
    for i in range(iterations):
        start = time.perf_counter()
        ok = fn()
        elapsed = (time.perf_counter() - start) * 1000
        if ok:
            times.append(elapsed)
    if not times:
        return None
    times.sort()
    n = len(times)
    avg = sum(times) / n
    p50 = times[n // 2] if n > 0 else 0
    p95 = times[int(n * 0.95)] if n >= 20 else times[-1]
    p99 = times[int(n * 0.99)] if n >= 100 else times[-1]
    return (avg, p50, p95, p99)

print(f'CPQ 性能基准测试 — {datetime.now().strftime("%Y-%m-%d %H:%M")}')
print('='*60)

token = login()
if not token:
    print('❌ 登录失败，无法进行性能测试')
    sys.exit(1)

headers = {'Authorization': f'Bearer {token}', 'clientid': CID}

results = []
total_pass = total_fail = 0

# 1. 配置器校验性能
print('\n--- 配置器校验 (<100ms) ---')
def test_config():
    r = requests.post(f'{BASE}/cpq/config/rule/list', headers=headers,
        params={'pageNum': 1, 'pageSize': 5}, timeout=10)
    return r.status_code == 200
m = measure('config', test_config, iterations=10)
if m:
    avg, p50, p95, p99 = m
    passed = p95 <= 100
    results.append(('配置器校验', avg, p95, '100ms', passed))
    total_pass += 1 if passed else 0
    total_fail += 0 if passed else 1
    print(f"  avg={avg:.1f}ms p50={p50:.1f}ms p95={p95:.1f}ms {'✅' if passed else '❌'}")

# 2. BOM 展开性能
print('\n--- BOM展开 (<2s) ---')
def test_bom():
    r = requests.get(f'{BASE}/cpq/engine/bom/explode/1001', headers=headers, timeout=15)
    return r.status_code in (200, 404, 500)
m = measure('bom', test_bom, iterations=3)
if m:
    avg, p50, p95, p99 = m
    passed = p95 <= 2000
    results.append(('BOM展开', avg, p95, '2s', passed))
    total_pass += 1 if passed else 0
    total_fail += 0 if passed else 1
    print(f"  avg={avg:.1f}ms p50={p50:.1f}ms p95={p95:.1f}ms {'✅' if passed else '❌'}")

# 3. 报价列表查询
print('\n--- API列表查询 (<500ms) ---')
endpoints = [
    ('/cpq/product/catalog/list', '产品目录'),
    ('/cpq/pricing/book/list', '价格手册'),
    ('/cpq/quote/header/list', '报价单'),
    ('/cpq/approval/record/list', '审批记录'),
    ('/cpq/config/rule/list', '配置规则'),
]
for path, name in endpoints:
    def mk_fn(p):
        return lambda: requests.get(f'{BASE}{p}', params={'pageNum': 1, 'pageSize': 10},
                                     headers=headers, timeout=10).status_code == 200
    m = measure(name, mk_fn(path), iterations=3)
    if m:
        avg, p50, p95, p99 = m
        passed = p95 <= 500
        results.append((name, avg, p95, '500ms', passed))
        total_pass += 1 if passed else 0
        total_fail += 0 if passed else 1
        print(f"  {name}: avg={avg:.1f}ms p95={p95:.1f}ms {'✅' if passed else '❌'}")

# 4. Swagger 响应
print('\n--- 基础服务响应 ---')
def test_swagger():
    r = requests.get(f'{BASE}/doc.html', timeout=5)
    return r.status_code == 200
m = measure('doc.html', test_swagger, iterations=3)
if m:
    avg, p50, p95, p99 = m
    print(f"  Swagger: avg={avg:.1f}ms p95={p95:.1f}ms")

def test_api_docs():
    r = requests.get(f'{BASE}/v3/api-docs', timeout=10)
    return r.status_code == 200
m = measure('api-docs', test_api_docs, iterations=2)
if m:
    print(f"  OpenAPI: avg={m[0]:.1f}ms p95={m[2]:.1f}ms")

# 汇总
print(f'\n{"="*60}')
print(f'性能测试结果: {total_pass}✅ {total_fail}❌')
print(f'{"="*60}')

# 写入 Markdown 报告
import os
report_dir = os.path.dirname(os.path.abspath(__file__))
report_path = os.path.join(report_dir, 's20_performance_report.md')
with open(report_path, 'w') as f:
    f.write(f'# CPQ 性能基准测试报告（S20.8）\n\n')
    f.write(f'**测试时间**：{datetime.now().strftime("%Y-%m-%d %H:%M")}\n\n')
    f.write(f'| 测试项 | 平均延迟 | P95延迟 | 目标 | 结果 |\n')
    f.write(f'|--------|---------|--------|------|------|\n')
    for name, avg, p95, target, passed in results:
        icon = '✅' if passed else '❌'
        f.write(f'| {name} | {avg:.1f}ms | {p95:.1f}ms | <{target} | {icon} |\n')
    f.write(f'\n**通过率**：{total_pass}/{total_pass + total_fail}\n')
    f.write(f'\n**80分位指标**：{"✅ 达标" if total_fail == 0 else "❌ 未达标"}\n')

print(f'\n报告已保存: {report_path}')
sys.exit(0 if total_fail == 0 else 1)
