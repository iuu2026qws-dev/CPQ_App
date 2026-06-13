import type { App } from 'vue'
import { hasPermi, hasRole } from './permission'
import { costVisibility } from './costVisibility'

/**
 * 注册所有 CPQ 自定义指令
 * 在 main.ts 中调用：app.use(installDirectives)
 */
export default function installDirectives(app: App) {
  app.directive('hasPermi', hasPermi)
  app.directive('hasRole', hasRole)
  app.directive('costVisibility', costVisibility)
}

export { hasPermi, hasRole, costVisibility }
