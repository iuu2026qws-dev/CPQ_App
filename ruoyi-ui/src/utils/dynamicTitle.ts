import { useTitle } from '@vueuse/core'
import defaultSettings from '@/settings'

export const useDynamicTitle = () => {
  // 从 localStorage 读取 dynamicTitle 设置，避免循环依赖 settings store
  let dynamicTitle = defaultSettings.dynamicTitle
  try {
    const storageSetting = localStorage.getItem('layout-setting')
    if (storageSetting) {
      const parsed = JSON.parse(storageSetting)
      if (typeof parsed.dynamicTitle === 'boolean') {
        dynamicTitle = parsed.dynamicTitle
      }
    }
  } catch (e) {
    // ignore parse error
  }

  if (dynamicTitle) {
    const title = useTitle()
    title.value = defaultSettings.title
    return
  }
}
