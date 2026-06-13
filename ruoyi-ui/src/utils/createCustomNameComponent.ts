import { defineAsyncComponent } from 'vue'

/**
 * 创建一个带有自定义名称的异步组件
 * 用于在路由中设置组件名称，方便调试和 keep-alive
 * @param componentPath 组件路径
 * @param name 组件名称
 */
export const createCustomNameComponent = (componentPath: string, name: string) => {
  return defineAsyncComponent(() => import(`@/views/${componentPath}.vue`).then(component => {
    component.default.name = name
    return component
  }))
}
