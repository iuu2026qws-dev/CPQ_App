import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

// ========== 基础 CRUD ==========
export function listTemplate(params: any) { return request({ url: '/cpq/quote/template/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getTemplate(id: number) { return request({ url: `/cpq/quote/template/${id}`, method: 'get' }) }
export function addTemplate(data: any) { return request({ url: '/cpq/quote/template', method: 'post', data }) }
export function updateTemplate(data: any) { return request({ url: '/cpq/quote/template', method: 'put', data }) }
export function delTemplate(id: number) { return request({ url: `/cpq/quote/template/${id}`, method: 'delete' }) }

// ========== 模板设计器 API ==========

/** 获取字段库 — 可用字段列表（按 category 分组） */
export function getFieldLibrary() {
  return request({ url: '/cpq/quote/template/fields', method: 'get' })
}

/** 保存模板设计配置 — templateJson */
export function saveTemplateDesign(templateId: number, templateJson: string) {
  return request({ url: `/cpq/quote/template/${templateId}/design`, method: 'put', data: { templateJson } })
}

/** 生成模板预览 HTML */
export function previewTemplate(templateId: number) {
  return request({ url: `/cpq/quote/template/${templateId}/preview`, method: 'get' })
}

/** 设为默认模板 */
export function setDefaultTemplate(templateId: number) {
  return request({ url: `/cpq/quote/template/${templateId}/default`, method: 'put' })
}
