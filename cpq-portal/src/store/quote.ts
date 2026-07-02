import { defineStore } from 'pinia'
import { ref } from 'vue'
import { listQuote, getQuote, addQuote, updateQuote, delQuote, listLineItem, addLineItem, updateLineItem, delLineItem, listSnapshot, listVersion, listTemplate, type QuoteVo, type QuoteBo, type LineItemVo, type SnapshotVo, type VersionVo, type TemplateVo } from '@/api/quoting'

export const useQuoteStore = defineStore('quote', () => {
  const quoteList = ref<QuoteVo[]>([])
  const currentQuote = ref<QuoteVo | null>(null)
  const lineItems = ref<LineItemVo[]>([])
  const snapshots = ref<SnapshotVo[]>([])
  const versions = ref<VersionVo[]>([])
  const templates = ref<TemplateVo[]>([])
  const total = ref(0)
  const loading = ref(false)

  async function fetchQuoteList(params?: Record<string, unknown>) {
    loading.value = true
    try {
      const res = await listQuote(params || {})
      quoteList.value = res.rows || []
      total.value = res.total ?? quoteList.value.length
    } finally { loading.value = false }
  }

  async function fetchQuote(id: string) {
    loading.value = true
    try { const res = await getQuote(id); currentQuote.value = res as unknown as QuoteVo }
    finally { loading.value = false }
  }

  async function createQuote(data: QuoteBo) {
    await addQuote(data)
  }

  async function editQuote(data: QuoteBo) {
    await updateQuote(data)
  }

  async function removeQuote(id: string) {
    await delQuote(id)
  }

  async function fetchLineItems(quoteId: string) {
    const res = await listLineItem(quoteId)
    lineItems.value = Array.isArray(res) ? res : (res as { rows: LineItemVo[] }).rows || []
  }

  async function createLineItem(data: Record<string, unknown>) {
    await addLineItem(data)
  }

  async function editLineItem(data: Record<string, unknown>) {
    await updateLineItem(data)
  }

  async function removeLineItem(id: string) {
    await delLineItem(id)
  }

  async function fetchSnapshots(quoteId: string) {
    const res = await listSnapshot(quoteId)
    snapshots.value = Array.isArray(res) ? res : (res as { rows: SnapshotVo[] }).rows || []
  }

  async function fetchVersions(quoteId: string) {
    const res = await listVersion(quoteId)
    versions.value = Array.isArray(res) ? res : (res as { rows: VersionVo[] }).rows || []
  }

  async function fetchTemplates() {
    const res = await listTemplate()
    templates.value = Array.isArray(res) ? res : (res as { rows: TemplateVo[] }).rows || []
  }

  return { quoteList, currentQuote, lineItems, snapshots, versions, templates, total, loading,
    fetchQuoteList, fetchQuote, createQuote, editQuote, removeQuote,
    fetchLineItems, createLineItem, editLineItem, removeLineItem,
    fetchSnapshots, fetchVersions, fetchTemplates }
})
