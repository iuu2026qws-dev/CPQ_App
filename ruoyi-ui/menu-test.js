#!/usr/bin/env node
// Quick CPQ menu test using playwright-cli eval
const { execSync } = require('child_process');
const BASE = 'http://localhost:5173';
const PCLI = '/Users/yongfengyang/.nvm/versions/node/v25.9.0/bin/playwright-cli';

const pages = [
  ['产品目录', '/cpq/product/catalog'],
  ['产品模型', '/cpq/product/model'],
  ['配置规则', '/cpq/product/rules'],
  ['替代品管理', '/cpq/product/supersession'],
  ['产品分类管理', '/cpq/product/category'],
  ['产品搜索', '/cpq/configure/search'],
  ['标准配置', '/cpq/configure/standard'],
  ['向导式配置', '/cpq/configure/guided'],
  ['ATO配置', '/cpq/configure/ato'],
  ['报价单列表', '/cpq/quoting/list'],
  ['新建报价', '/cpq/quoting/create'],
  ['报价模板', '/cpq/quoting/templates'],
  ['方案列表', '/cpq/solution/list'],
  ['方案对比', '/cpq/solution/compare'],
  ['待我审批', '/cpq/approval/pending'],
  ['我已审批', '/cpq/approval/processed'],
  ['我发起的', '/cpq/approval/initiated'],
  ['效率看板', '/cpq/approval/analytics'],
  ['任务看板', '/cpq/presales/board'],
  ['评审工作台', '/cpq/presales/review'],
  ['竞品库', '/cpq/competitive/library'],
  ['对比分析', '/cpq/competitive/compare'],
  ['价格手册', '/cpq/pricing/books'],
  ['定价规则', '/cpq/pricing/rules'],
  ['阶梯定价', '/cpq/pricing/volume'],
  ['交期检查', '/cpq/atpctp/check'],
  ['批量查询', '/cpq/atpctp/batch'],
  ['SLA看板', '/cpq/atpctp/sla'],
  ['产品知识', '/cpq/knowledge/products'],
  ['销售话术', '/cpq/knowledge/scripts'],
  ['成功案例', '/cpq/knowledge/cases'],
  ['培训认证', '/cpq/knowledge/training'],
  ['CRM连接器', '/cpq/integration/crm'],
  ['ERP连接器', '/cpq/integration/erp'],
  ['PLM连接器', '/cpq/integration/plm'],
  ['同步日志', '/cpq/integration/logs'],
  ['租户配置', '/cpq/settings/tenant'],
  ['用户管理', '/cpq/settings/users'],
  ['角色管理', '/cpq/settings/roles'],
  ['ABAC策略', '/cpq/settings/abac'],
  ['审计日志', '/cpq/settings/audit'],
  ['数据迁移', '/cpq/settings/migration'],
  ['变更管理', '/cpq/settings/ecn'],
  ['系统参数', '/cpq/settings/params'],
];

let pass = 0, fail = 0;
console.log('=== CPQ Menu E2E Test ===\n');

for (const [name, path] of pages) {
  try {
    execSync(`${PCLI} goto "${BASE}${path}"`, { stdio: 'pipe', timeout: 8000 });
    const urlResult = execSync(`${PCLI} eval "window.location.pathname + ' | ' + (document.querySelector('.app-container') ? 'HAS_CONTENT' : 'EMPTY')"`, { stdio: 'pipe', timeout: 5000 });
    const output = urlResult.toString();
    
    // Parse the result from the output
    const resultMatch = output.match(/"([^"]+)"/);
    const result = resultMatch ? resultMatch[1] : '';
    
    const [actualPath, status] = result.split(' | ');
    
    if (status === 'HAS_CONTENT') {
      console.log(`  ✅ ${name} (${actualPath})`);
      pass++;
    } else {
      console.log(`  ❌ ${name} → ${result || 'UNKNOWN'}`);
      fail++;
    }
  } catch(e) {
    console.log(`  ❌ ${name} → ERROR: ${e.message?.substring(0,60)}`);
    fail++;
  }
}

console.log(`\n=== ${pass}/${pass+fail} PASS ===`);
if (fail > 0) process.exit(1);
