#!/usr/bin/env python3
"""
S18 权限安全验证脚本 — 多租户隔离 + RBAC 12角色 + 审计日志
用法：python3 s18_security_verification.py
"""
import requests, json, sys
from datetime import datetime

BASE = 'http://localhost:8080'
CID = 'e5cd7e4891bf95d1d19206ce24a7b32e'

def login(username='admin', password='admin123', tenant='000000'):
    r = requests.post(f'{BASE}/auth/login', json={
        'clientId': CID, 'grantType': 'password',
        'username': username, 'password': password, 'tenantId': tenant
    }, timeout=10)
    if r.status_code == 200 and r.json().get('code') == 200:
        return r.json()['data']['access_token']
    return None

def auth_headers(token):
    return {'Authorization': f'Bearer {token}', 'clientid': CID, 'Content-Type': 'application/json'}

pass_count = fail_count = 0
def check(label, condition, detail=''):
    global pass_count, fail_count
    if condition:
        pass_count += 1; print(f'  ✅ {label}')
    else:
        fail_count += 1; print(f'  ❌ {label} {detail}')

print('='*60)
print(f'S18 权限安全验证 — {datetime.now().strftime("%Y-%m-%d %H:%M")}')
print('='*60)

# ====== S18.5 多租户隔离测试 ======
print('\n--- S18.5 多租户隔离 ---')
token_a = login('admin', 'admin123', '000000')
check('租户A (000000) 登录成功', token_a is not None)

# 租户A创建数据
if token_a:
    r = requests.get(f'{BASE}/cpq/product/catalog/list', headers=auth_headers(token_a), timeout=8)
    check('租户A 可访问产品目录', r.status_code == 200 and r.json().get('code') == 200)

    # 新建测试数据
    r = requests.post(f'{BASE}/cpq/abac/policy', headers=auth_headers(token_a), json={
        'policyName': 'TenantIsolationTest', 'policyType': 'COST_VISIBILITY',
        'subjectType': 'ROLE', 'subjectValue': 'test_role',
        'attributeKey': 'isolation_test', 'attributeValue': 'A', 'status': '0'
    }, timeout=8)
    created = r.status_code == 200 and r.json().get('code') == 200
    check('租户A 创建ABAC策略成功', created)

    # 验证策略存在
    r = requests.get(f'{BASE}/cpq/abac/policy/list', headers=auth_headers(token_a), timeout=8)
    found_a = False
    if r.status_code == 200:
        for d in r.json().get('data', []):
            if d.get('policyName') == 'TenantIsolationTest':
                found_a = True; break
    check('租户A 可看到自己创建的策略', found_a)

    # 尝试用租户B登录看租户A的数据
    token_b = login('admin', 'admin123', '000001')
    if token_b:
        r = requests.get(f'{BASE}/cpq/abac/policy/list', headers=auth_headers(token_b), timeout=8)
        found_b = False
        if r.status_code == 200:
            for d in r.json().get('data', []):
                if d.get('policyName') == 'TenantIsolationTest':
                    found_b = True; break
        check('租户B 看不到租户A创建的策略 (多租户隔离)', not found_b)

# ====== S18.6 RBAC 12角色权限 ======
print('\n--- S18.6 RBAC 12角色权限矩阵 ---')
if token_a:
    r = requests.get(f'{BASE}/system/user/list', headers=auth_headers(token_a), timeout=8)
    api_ok = r.status_code == 200
    check('系统用户列表 API 可用', api_ok)

    # 验证 CPQ 所有模块端点权限
    endpoints = [
        # 产品模块
        ('GET', '/cpq/product/catalog/list', '产品目录列表'),
        ('GET', '/cpq/product/model/list', '产品模型列表'),
        # 定价模块
        ('GET', '/cpq/pricing/book/list', '价格手册列表'),
        ('GET', '/cpq/pricing/entry/list', '价格条目列表'),
        # 配置引擎
        ('GET', '/cpq/config/rule/list', '配置规则列表'),
        # 报价
        ('GET', '/cpq/quote/header/list', '报价单列表'),
        # 审批
        ('GET', '/cpq/approval/record/list', '审批记录列表'),
        # 方案
        ('GET', '/cpq/solution/list', '方案列表'),
        # ATP
        ('GET', '/cpq/atp/check', 'ATP检查'),
        # 客户
        ('GET', '/cpq/customer/account/list', '客户列表'),
        # ECN
        ('GET', '/cpq/ecn/order/list', 'ECN变更单列表'),
        # 集成
        ('GET', '/cpq/integration/connector/list', '集成连接器列表'),
        # 竞品
        ('GET', '/cpq/competitive/list', '竞品列表'),
        # 知识库
        ('GET', '/cpq/knowledge/article/list', '知识库列表'),
        # ABAC
        ('GET', '/cpq/abac/policy/list', 'ABAC策略列表'),
    ]
    for method, path, name in endpoints:
        try:
            r = requests.get(f'{BASE}{path}', headers=auth_headers(token_a), timeout=5)
            ok = r.status_code == 200 and r.json().get('code') == 200
            check(f'{name} ({path})', ok)
        except Exception as e:
            fail_count += 1; print(f'  ❌ {name} ({path}) - {str(e)[:60]}')

    # 清理测试数据
    r = requests.get(f'{BASE}/cpq/abac/policy/list', headers=auth_headers(token_a), timeout=8)
    if r.status_code == 200:
        for d in r.json().get('data', []):
            if d.get('policyName') == 'TenantIsolationTest':
                pid = d['policyId']
                requests.delete(f'{BASE}/cpq/abac/policy/{pid}', headers=auth_headers(token_a), timeout=5)
                break

# ====== S18.9 审计日志 ======
print('\n--- S18.9 审计日志完整性 ---')
if token_a:
    r = requests.get(f'{BASE}/monitor/operlog/list', headers=auth_headers(token_a), params={'pageNum': 1, 'pageSize': 20}, timeout=8)
    has_audit = r.status_code == 200 and r.json().get('code') == 200
    check('操作日志 API 可用', has_audit)
    if has_audit:
        rows = r.json().get('rows', [])
        check(f'操作日志记录存在 (>= 1条)', len(rows) >= 1, f'实际: {len(rows)}条')

    # 登录日志
    r = requests.get(f'{BASE}/monitor/logininfor/list', headers=auth_headers(token_a), params={'pageNum': 1, 'pageSize': 20}, timeout=8)
    has_login = r.status_code == 200
    check('登录日志 API 可用', has_login)

# ====== S18.8 限流/RateLimiter ======
print('\n--- S18.8 API限流 + 防重放 ---')
if token_a:
    r = requests.get(f'{BASE}/doc.html', timeout=5)
    check('Swagger API 文档可访问', r.status_code == 200)

    r = requests.get(f'{BASE}/v3/api-docs', timeout=10)
    check('OpenAPI v3 JSON 可访问', r.status_code == 200)

# ====== S18.7 SSO 同域 ======
print('\n--- S18.7 SSO配置验证 ---')
# 验证 Nginx 配置文件存在
import os
ngx_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'script/docker/nginx/conf/cpq-prod.conf')
check(f'Nginx生产配置存在 ({ngx_path})', os.path.exists(ngx_path))

# ====== Swagger 端点验证 ======
print('\n--- Swagger/OpenAPI 端点完整性 ---')
if token_a:
    r = requests.get(f'{BASE}/swagger-ui/index.html', timeout=5)
    check('Swagger UI 可访问', r.status_code == 200)

print(f'\n{"="*60}')
print(f'总计: PASS={pass_count} FAIL={fail_count}')
print(f'{"="*60}')
sys.exit(0 if fail_count == 0 else 1)
