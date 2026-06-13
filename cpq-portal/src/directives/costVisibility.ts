import type { Directive, DirectiveBinding } from 'vue'
import { useUserStore } from '@/store/user'

/**
 * 成本可见性级别（ABAC 四级脱敏）
 * L0 — 仅看协议价（最低权限，渠道伙伴/外部用户）
 * L1 — 销售价 + 毛利率%（销售代表）
 * L2 — 毛利 + 物料成本（销售经理/产品经理）
 * L3 — 完整成本明细（定价经理/高管/审计）
 */
export type CostVisibilityLevel = 'L0' | 'L1' | 'L2' | 'L3'

/**
 * 根据用户角色推导成本可见性级别
 * ABAC 策略表 cpq_abac_policy 定义主体→属性→值的映射
 * 此处为前端快速判断，实际脱敏在后端 API 层执行
 */
function getUserCostLevel(): CostVisibilityLevel {
  const userStore = useUserStore()
  const roles: string[] = userStore.roles || []

  // 高管、审计、定价经理 — 完整成本
  if (roles.some(r => ['executive', 'auditor', 'pricing_manager', 'admin', 'superadmin'].includes(r))) {
    return 'L3'
  }
  // 销售经理、产品经理 — 毛利 + 物料成本
  if (roles.some(r => ['sales_manager', 'product_manager'].includes(r))) {
    return 'L2'
  }
  // 销售代表、售前 — 销售价 + 毛利率%
  if (roles.some(r => ['sales_rep', 'presales', 'default'].includes(r))) {
    return 'L1'
  }
  // 渠道伙伴、运营、供应链 — 仅协议价
  return 'L0'
}

const LEVEL_ORDER: Record<CostVisibilityLevel, number> = { L0: 0, L1: 1, L2: 2, L3: 3 }

/**
 * v-cost-visibility — ABAC 成本可见性指令
 *
 * 用法：
 *   v-cost-visibility="'L2'"          — 元素仅对 L2 及以上用户显示
 *   v-cost-visibility="['L2','L3']"   — 元素对 L2 或 L3 用户显示
 *
 * 典型场景：
 *   <el-table-column label="物料成本" v-cost-visibility="'L2'" />
 *   <el-table-column label="BOM成本"  v-cost-visibility="'L3'" />
 *   <div class="price-detail" v-cost-visibility="['L1','L2','L3']">...</div>
 */
export const costVisibility: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const userLevel = getUserCostLevel()
    const { value } = binding

    if (!value) {
      throw new Error("v-cost-visibility 需要级别参数，如 v-cost-visibility=\"'L2'\"")
    }

    const allowed: CostVisibilityLevel[] = typeof value === 'string' ? [value as CostVisibilityLevel] : value

    const isVisible = allowed.some(level => LEVEL_ORDER[userLevel] >= LEVEL_ORDER[level])

    if (!isVisible) {
      el.parentNode && el.parentNode.removeChild(el)
    }
  }
}
