/**
 * CPQ Portal 侧边栏菜单 —— 唯一数据源
 *
 * 本文件是 cpq-portal 侧边栏菜单的 Single Source of Truth。
 * 与 ruoyi-ui（admin portal）的 sys_menu 表 / getRouters API 完全解耦，
 * 两套系统的菜单独立管理，互不影响。
 *
 * 两级菜单结构：
 *   - 一级菜单（8个分组）：任务中心、审批中心、产品管理、配置管理、价格管理、报价管理、工厂协同、运营及参数
 *   - 二级菜单：原本的一级菜单项，全部归入对应一级分组
 *
 * 新增 CPQ Portal 页面时：
 *   1. 在 router/index.ts 添加路由定义
 *   2. 在下方 portalMenuItems 数组对应分组的 children 中添加菜单项
 *   3. 确保 path 与路由 path 一致
 */
import type { Component } from 'vue'
import {
  Goods, Box, Connection, Setting,
  Coin, EditPen, Histogram, Share, Money, MagicStick,
  Document, Checked, Operation, Link, TrendCharts,
  Upload, Reading, Notebook, Timer, RefreshRight,
  OfficeBuilding, Platform, Lock, Tools, Compass, SetUp,
  Stamp, List, Odometer, DocumentChecked, Bell, Clock,
  CircleCheck, Postcard, DataAnalysis, Files, User, Aim, DocumentAdd, Tickets
} from '@element-plus/icons-vue'

/** 二级子菜单项 */
export interface PortalSubMenuItem {
  path: string
  label: string
  icon: Component
}

/** 一级菜单分组（包含子菜单） */
export interface PortalMenuItem {
  label: string
  icon: Component
  /** 该分组下所有子页面的路径前缀，用于判断 active 高亮 */
  children: PortalSubMenuItem[]
}

/** 按侧边栏展示顺序排列的两级菜单 */
export const portalMenuItems: PortalMenuItem[] = [
  {
    label: 'CRM信息',
    icon: User,
    children: [
      { path: '/crm/account',     label: '客户管理', icon: User },
      { path: '/crm/opportunity', label: '商机管理', icon: Aim },
      { path: '/crm/contract',    label: '合同管理', icon: DocumentAdd },
      { path: '/crm/order',       label: '订单管理', icon: Tickets },
    ]
  },
  {
    label: '任务中心',
    icon: List,
    children: [
      { path: '/task/board',  label: '任务看板',   icon: Odometer },
      { path: '/task/review', label: '评审工作台', icon: DocumentChecked },
    ]
  },
  {
    label: '审批中心',
    icon: Bell,
    children: [
      { path: '/approval/pending',   label: '待我审批', icon: Clock },
      { path: '/approval/processed', label: '我已审批', icon: CircleCheck },
      { path: '/approval/initiated', label: '我发起的', icon: Postcard },
      { path: '/approval/analytics', label: '效率看板', icon: DataAnalysis },
    ]
  },
  {
    label: '产品管理',
    icon: Goods,
    children: [
      { path: '/catalog',          label: '产品目录',   icon: Goods },
      { path: '/bom',              label: 'BOM管理',    icon: Box },
      { path: '/bundle',           label: '捆绑包管理', icon: Box },
      { path: '/supersession',     label: '替代品管理', icon: Connection },
      { path: '/attribute-option', label: '属性选项',   icon: Operation },
      { path: '/competitive',      label: '竞品对标',   icon: TrendCharts },
      { path: '/ecn',              label: '变更管理',   icon: RefreshRight },
    ]
  },
  {
    label: '配置管理',
    icon: Setting,
    children: [
      { path: '/config',              label: '配置规则',     icon: Setting },
      { path: '/configure',           label: '产品配置器',   icon: MagicStick },
      { path: '/configure-standard',  label: '新建标准配置', icon: MagicStick },
      { path: '/configure-guided',    label: '向导式配置',   icon: Compass },
      { path: '/configure-ato',       label: 'ATO定制配置',  icon: SetUp },
    ]
  },
  {
    label: '价格管理',
    icon: Coin,
    children: [
      { path: '/pricing/book',         label: '价格手册', icon: Coin },
      { path: '/pricing/rule',         label: '定价规则', icon: EditPen },
      { path: '/pricing/volumetier',   label: '阶梯定价', icon: Histogram },
      { path: '/pricing/channelprice', label: '渠道价格', icon: Share },
    ]
  },
  {
    label: '报价管理',
    icon: Document,
    children: [
      { path: '/quoting',             label: '报价单管理',   icon: Document },
      { path: '/quoting/template',    label: '报价模板管理', icon: Stamp },
      { path: '/quick-quote',         label: '快速报价',     icon: Platform },
      { path: '/solution',            label: '方案管理',     icon: Notebook },
    ]
  },
  {
    label: '工厂协同',
    icon: OfficeBuilding,
    children: [
      { path: '/atp',       label: '交期管理', icon: Timer },
      { path: '/atp/batch', label: '批量查询', icon: Files },
      { path: '/plant',     label: '工厂管理', icon: OfficeBuilding },
    ]
  },
  {
    label: '运营及参数',
    icon: Tools,
    children: [
      { path: '/pricing/currencyrate', label: '汇率配置',   icon: Money },
      { path: '/integration',          label: '集成管理',   icon: Link },
      { path: '/migration',            label: '数据迁移',   icon: Upload },
      { path: '/knowledge',            label: '知识库',     icon: Reading },
      { path: '/settings/abac',        label: 'ABAC策略',   icon: Lock },
    ]
  },
]

/** 兼容旧代码：扁平化所有二级菜单项（用于按路径查找 label 等场景） */
export const flatMenuItems: PortalSubMenuItem[] =
  portalMenuItems.flatMap(g => g.children)
