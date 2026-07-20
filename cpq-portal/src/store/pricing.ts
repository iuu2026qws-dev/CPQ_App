/**
 * CPQ 定价管理 Pinia Store
 * 参考：[前端§21.1 usePricingStore]
 */
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  getPriceBookList, getPriceBookById, addPriceBook, updatePriceBook, deletePriceBook,
  getEntryList, getEntryById, addEntry, updateEntry, deleteEntry,
  getPriceRuleList, addPriceRule, updatePriceRule, deletePriceRule,
  getVolumeTierList, addVolumeTier, updateVolumeTier, deleteVolumeTier,
  getChannelPriceList, addChannelPrice, updateChannelPrice, deleteChannelPrice,
  getCurrencyRateList, addCurrencyRate, updateCurrencyRate, deleteCurrencyRate,
  type CpqPriceBook, type CpqPriceBookEntry, type CpqPriceRule,
  type CpqVolumeTier, type CpqChannelPrice, type CpqCurrencyRate
} from '@/api/pricing'

export const usePricingStore = defineStore('pricing', () => {
  // ===== 价格手册 =====
  const books = ref<CpqPriceBook[]>([])
  const bookLoading = ref(false)
  const loadBooks = async () => { bookLoading.value = true; try { const data = await getPriceBookList(); books.value = Array.isArray(data) ? data : (data?.rows || []) } finally { bookLoading.value = false } }

  // ===== 价格手册条目 =====
  const entries = ref<CpqPriceBookEntry[]>([])
  const entryLoading = ref(false)
  const loadEntries = async (priceBookId: number) => { entryLoading.value = true; try { const data = await getEntryList({ priceBookId }); entries.value = Array.isArray(data) ? data : (data?.rows || []) } finally { entryLoading.value = false } }

  // ===== 定价规则 =====
  const rules = ref<CpqPriceRule[]>([])
  const ruleLoading = ref(false)
  const loadRules = async () => { ruleLoading.value = true; try { const data = await getPriceRuleList(); rules.value = Array.isArray(data) ? data : (data?.rows || []) } finally { ruleLoading.value = false } }

  // ===== 阶梯定价 =====
  const tiers = ref<CpqVolumeTier[]>([])
  const tierLoading = ref(false)
  const loadTiers = async () => { tierLoading.value = true; try { const data = await getVolumeTierList(); tiers.value = Array.isArray(data) ? data : (data?.rows || []) } finally { tierLoading.value = false } }

  // ===== 渠道价格 =====
  const channelPrices = ref<CpqChannelPrice[]>([])
  const channelPriceLoading = ref(false)
  const loadChannelPrices = async () => { channelPriceLoading.value = true; try { const data = await getChannelPriceList(); channelPrices.value = Array.isArray(data) ? data : (data?.rows || []) } finally { channelPriceLoading.value = false } }

  // ===== 汇率 =====
  const rates = ref<CpqCurrencyRate[]>([])
  const rateLoading = ref(false)
  const loadRates = async () => { rateLoading.value = true; try { const data = await getCurrencyRateList(); rates.value = Array.isArray(data) ? data : (data?.rows || []) } finally { rateLoading.value = false } }

  return {
    books, bookLoading, loadBooks,
    entries, entryLoading, loadEntries,
    rules, ruleLoading, loadRules,
    tiers, tierLoading, loadTiers,
    channelPrices, channelPriceLoading, loadChannelPrices,
    rates, rateLoading, loadRates
  }
})
