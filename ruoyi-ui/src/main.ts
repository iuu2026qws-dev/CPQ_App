import { createApp } from 'vue'

// UnoCSS
import 'virtual:uno.css'

// Element Plus
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

// 自定义样式
import '@/assets/styles/index.scss'

// 动画
import 'animate.css'

// App、router、store
import App from './App.vue'
import store from './store'
import router from './router'

// 自定义指令（hasPermi/hasRoles/copyText）
import directive from './directive'

// 注册插件（modal/tab/download/cache/auth/animate/global methods）
import plugins from './plugins/index'

// 国际化
import i18n from '@/lang/index'

const app = createApp(App)

// 注册所有 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(ElementPlus)
app.use(store)
app.use(router)
app.use(i18n)
app.use(plugins)

// 注册自定义指令
directive(app)

app.mount('#app')
