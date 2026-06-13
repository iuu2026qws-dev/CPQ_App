import { defineStore } from 'pinia'
import { ref } from 'vue'
import { listApprovalRule, listApprovalChain, getApprovalChain, listApprovalRecord, listApprovalMatrix, type ApprovalRuleVo, type ApprovalChainVo, type ApprovalRecordVo, type ApprovalMatrixVo } from '@/api/approval'

export const useApprovalStore = defineStore('approval', () => {
  const rules = ref<ApprovalRuleVo[]>([])
  const chains = ref<ApprovalChainVo[]>([])
  const currentChain = ref<ApprovalChainVo | null>(null)
  const records = ref<ApprovalRecordVo[]>([])
  const matrices = ref<ApprovalMatrixVo[]>([])
  const loading = ref(false)

  async function fetchRules(params?: Record<string, unknown>) {
    loading.value = true
    try { const res = await listApprovalRule(params || {}); rules.value = Array.isArray(res) ? res : (res as { rows: ApprovalRuleVo[] }).rows || [] }
    finally { loading.value = false }
  }

  async function fetchChains(params?: Record<string, unknown>) {
    loading.value = true
    try { const res = await listApprovalChain(params || {}); chains.value = Array.isArray(res) ? res : (res as { rows: ApprovalChainVo[] }).rows || [] }
    finally { loading.value = false }
  }

  async function fetchChain(chainId: number) {
    const res = await getApprovalChain(chainId); currentChain.value = res as unknown as ApprovalChainVo
  }

  async function fetchRecords(chainId: number) {
    const res = await listApprovalRecord(chainId); records.value = (Array.isArray(res) ? res : res as unknown as ApprovalRecordVo[]) || []
  }

  async function fetchMatrices(params?: Record<string, unknown>) {
    loading.value = true
    try { const res = await listApprovalMatrix(params || {}); matrices.value = Array.isArray(res) ? res : (res as { rows: ApprovalMatrixVo[] }).rows || [] }
    finally { loading.value = false }
  }

  return { rules, chains, currentChain, records, matrices, loading,
    fetchRules, fetchChains, fetchChain, fetchRecords, fetchMatrices }
})
