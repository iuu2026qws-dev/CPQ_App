import { defineConfig } from 'vite'
import createPlugins from './vite/plugins'
import path from 'path'

export default defineConfig(({ mode }) => {
  return {
    base: '/',
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src')
      },
      extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue']
    },
    plugins: createPlugins({}, mode === 'build'),
    server: {
      host: '0.0.0.0',
      port: 3000,
      proxy: {
        '/dev-api': {
          target: 'http://localhost:8080',
          changeOrigin: true,
          ws: true,
          rewrite: (path) => path.replace(/^\/dev-api/, '')
        }
      }
    },
    esbuild: {
      tsconfigRaw: {
        compilerOptions: {
          verbatimModuleSyntax: false
        }
      }
    },
    optimizeDeps: {
      include: [
        'vue',
        'vue-router',
        'pinia',
        'axios',
        '@vueuse/core',
        'echarts',
        'vue-i18n',
        'element-plus/es/components/**/css'
      ]
    }
  }
})
