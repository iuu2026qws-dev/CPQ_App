import axios, { type AxiosResponse } from 'axios'
import { getToken, removeToken } from '@/utils/auth'

const clientId = 'e5cd7e4891bf95d1d19206ce24a7b32e'

// 全局默认请求头：clientid 是 Sa-Token 多终端认证必需
axios.defaults.headers['clientid'] = clientId

const service = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: { 'Content-Type': 'application/json;charset=utf-8' }
})

service.interceptors.request.use(
  (config: any) => {
    // 如果请求明确标注不需要 token，跳过 Authorization
    if (config.headers?.isToken === false || config.headers?.isToken === 'false') {
      return config
    }
    const token = getToken()
    if (token) {
      config.headers['Authorization'] = 'Bearer ' + token
    }
    return config
  },
  error => Promise.reject(error)
)

// 类型声明：扩展 axios 实例，让 .get/.post 返回解包后的 data
declare module 'axios' {
  interface AxiosInstance {
    request<T = any>(config: any): Promise<T>
    get<T = any>(url: string, config?: any): Promise<T>
    delete<T = any>(url: string, config?: any): Promise<T>
    head<T = any>(url: string, config?: any): Promise<T>
    options<T = any>(url: string, config?: any): Promise<T>
    post<T = any>(url: string, data?: any, config?: any): Promise<T>
    put<T = any>(url: string, data?: any, config?: any): Promise<T>
    patch<T = any>(url: string, data?: any, config?: any): Promise<T>
  }
}

service.interceptors.response.use(
  (res: AxiosResponse) => {
    // 二进制响应（blob/arraybuffer）直接透传，不做 JSON 解包
    const responseType = (res.config as any)?.responseType
    if (responseType === 'blob' || responseType === 'arraybuffer') {
      return res.data
    }
    const body = res.data
    if (body !== null && typeof body === 'object') {
      const code = body.code
      if (code !== undefined && code !== 200) {
        return Promise.reject(new Error(body.msg || '请求失败'))
      }
      // TableDataInfo 格式：{ total, rows, code, msg }
      if ('rows' in body) {
        return { rows: body.rows, total: body.total }
      }
      // R<T> 格式：{ code, msg, data }
      if ('data' in body) {
        // 数组自动包装为 TableDataInfo 格式，统一前端消费
        if (Array.isArray(body.data)) {
          return { rows: body.data, total: body.data.length }
        }
        return body.data
      }
    }
    return body
  },
  error => {
    console.error('[CPQ Portal] API Error:', error.message)
    if (error.response?.status === 401) {
      removeToken()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default service
