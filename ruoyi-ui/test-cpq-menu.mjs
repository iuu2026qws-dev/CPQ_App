import { chromium } from 'playwright';

const BASE = 'http://localhost:5173';
const MENU_ITEMS = [
  // 产品管理 (已知可用)
  { name: '产品目录', path: '/cpq/product/catalog', expectedTitle: '产品目录' },
  { name: '产品模型', path: '/cpq/product/model', expectedTitle: '产品模型' },
  { name: '配置规则', path: '/cpq/product/rules', expectedTitle: '配置规则' },
  { name: '替代品管理', path: '/cpq/product/supersession', expectedTitle: '替代品' },
  { name: '产品分类管理', path: '/cpq/product/category', expectedTitle: '产品分类' },
  // 配置报价
  { name: '产品搜索', path: '/cpq/configure/search', expectedTitle: '' },
  { name: '新建标准配置', path: '/cpq/configure/standard', expectedTitle: '' },
  { name: '向导式配置', path: '/cpq/configure/guided', expectedTitle: '' },
  { name: 'ATO定制配置', path: '/cpq/configure/ato', expectedTitle: '' },
  // 报价管理
  { name: '报价单列表', path: '/cpq/quoting/list', expectedTitle: '' },
  { name: '新建报价', path: '/cpq/quoting/create', expectedTitle: '' },
  { name: '报价模板', path: '/cpq/quoting/templates', expectedTitle: '' },
  // 方案管理
  { name: '方案列表', path: '/cpq/solution/list', expectedTitle: '' },
  { name: '方案对比', path: '/cpq/solution/compare', expectedTitle: '' },
  // 审批中心
  { name: '待我审批', path: '/cpq/approval/pending', expectedTitle: '' },
  { name: '我已审批', path: '/cpq/approval/processed', expectedTitle: '' },
  { name: '我发起的', path: '/cpq/approval/initiated', expectedTitle: '' },
  { name: '效率看板', path: '/cpq/approval/analytics', expectedTitle: '' },
  // 售前协同
  { name: '任务看板', path: '/cpq/presales/board', expectedTitle: '' },
  { name: '评审工作台', path: '/cpq/presales/review', expectedTitle: '' },
  // 竞品对标
  { name: '竞品库', path: '/cpq/competitive/library', expectedTitle: '' },
  { name: '对比分析', path: '/cpq/competitive/compare', expectedTitle: '' },
  // 定价管理
  { name: '价格手册', path: '/cpq/pricing/books', expectedTitle: '' },
  { name: '定价规则', path: '/cpq/pricing/rules', expectedTitle: '' },
  { name: '阶梯定价', path: '/cpq/pricing/volume', expectedTitle: '' },
  // 交期查询
  { name: '交期检查', path: '/cpq/atpctp/check', expectedTitle: '' },
  { name: '批量查询', path: '/cpq/atpctp/batch', expectedTitle: '' },
  { name: 'SLA看板', path: '/cpq/atpctp/sla', expectedTitle: '' },
  // 知识库
  { name: '产品知识', path: '/cpq/knowledge/products', expectedTitle: '' },
  { name: '销售话术', path: '/cpq/knowledge/scripts', expectedTitle: '' },
  { name: '成功案例', path: '/cpq/knowledge/cases', expectedTitle: '' },
  { name: '培训认证', path: '/cpq/knowledge/training', expectedTitle: '' },
  // 系统集成
  { name: 'CRM连接器', path: '/cpq/integration/crm', expectedTitle: '' },
  { name: 'ERP连接器', path: '/cpq/integration/erp', expectedTitle: '' },
  { name: 'PLM连接器', path: '/cpq/integration/plm', expectedTitle: '' },
  { name: '同步日志', path: '/cpq/integration/logs', expectedTitle: '' },
  // 系统设置
  { name: '租户配置', path: '/cpq/settings/tenant', expectedTitle: '' },
  { name: '用户管理', path: '/cpq/settings/users', expectedTitle: '' },
  { name: '角色管理', path: '/cpq/settings/roles', expectedTitle: '' },
  { name: 'ABAC策略', path: '/cpq/settings/abac', expectedTitle: '' },
  { name: '审计日志', path: '/cpq/settings/audit', expectedTitle: '' },
  { name: '数据迁移', path: '/cpq/settings/migration', expectedTitle: '' },
  { name: '变更管理', path: '/cpq/settings/ecn', expectedTitle: '' },
  { name: '系统参数', path: '/cpq/settings/params', expectedTitle: '' },
];

async function login(page) {
  await page.goto(`${BASE}/login`);
  await page.waitForSelector('input[placeholder*="账号"], input[name="username"], .el-input__inner', { timeout: 10000 });
  // Fill login form
  const inputs = page.locator('.el-input__inner');
  const count = await inputs.count();
  if (count >= 2) {
    await inputs.nth(0).fill('admin');
    await inputs.nth(1).fill('admin123');
  }
  // Click login button
  const loginBtn = page.locator('button').filter({ hasText: /登录|登 录|Login/i });
  if (await loginBtn.count() > 0) {
    await loginBtn.first().click();
    await page.waitForTimeout(2000);
  }
  // Wait for dashboard
  await page.waitForTimeout(1000);
  const url = page.url();
  if (url.includes('/login')) {
    // maybe already logged in via token, try going to dashboard
    await page.goto(`${BASE}/dashboard`);
    await page.waitForTimeout(2000);
  }
}

async function run() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  console.log('=== CPQ Menu E2E Test ===');
  console.log(`Base URL: ${BASE}`);
  
  await login(page);
  console.log(`Login complete, current URL: ${page.url()}`);

  let pass = 0, fail = 0;
  const failures = [];

  for (const item of MENU_ITEMS) {
    try {
      await page.goto(`${BASE}${item.path}`, { waitUntil: 'domcontentloaded', timeout: 10000 });
      await page.waitForTimeout(1000);
      
      const url = page.url();
      const body = await page.textContent('body') || '';
      
      // Check if we got redirected to dashboard
      const isDashboard = url.includes('/dashboard') && !item.path.includes('dashboard');
      
      // Check for placeholder / under construction
      const hasPlaceholder = body.includes('页面建设中') || body.includes('建设中');
      
      // Check if the page has meaningful content (not empty)
      const hasContent = body.length > 200 && !isDashboard && !hasPlaceholder;
      
      let status = '';
      if (hasPlaceholder) {
        status = 'PLACEHOLDER';
        fail++;
      } else if (isDashboard) {
        status = 'REDIRECTED_TO_DASHBOARD';
        fail++;
      } else if (hasContent) {
        status = 'PASS';
        pass++;
      } else {
        status = 'CHECK';
        fail++;
      }
      
      const mark = status === 'PASS' ? '✅' : '❌';
      console.log(`  ${mark} ${item.name} (${item.path}) → ${status} [URL: ${url.substring(0, 60)}]`);
      
      if (status !== 'PASS') {
        failures.push({ ...item, status, url });
      }
    } catch (e) {
      console.log(`  ❌ ${item.name} (${item.path}) → ERROR: ${e.message?.substring(0, 80)}`);
      failures.push({ ...item, status: 'ERROR', error: e.message });
      fail++;
    }
  }

  console.log(`\n=== Results: ${pass}/${pass+fail} PASS ===`);
  if (fail > 0) {
    console.log('\nFailures:');
    for (const f of failures) {
      console.log(`  ❌ ${f.name} (${f.path}) → ${f.status}`);
    }
  }

  await browser.close();
  return { pass, fail, failures };
}

run().then(r => {
  if (r.fail > 0) process.exit(1);
}).catch(e => {
  console.error('Fatal:', e);
  process.exit(1);
});
