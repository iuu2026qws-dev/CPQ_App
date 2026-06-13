import { getDicts } from '@/api/system/dict/data';
import { useDictStore } from '@/store/modules/dict';
/**
 * 获取字典数据
 */
export const useDict = (...args: string[]): { [key: string]: DictDataOption[] } => {
  const res = ref<{
    [key: string]: DictDataOption[];
  }>({});

  args.forEach(async (dictType) => {
    res.value[dictType] = [];
    const dicts = useDictStore().getDict(dictType);
    if (dicts) {
      res.value[dictType] = dicts;
    } else {
      await getDicts(dictType).then((resp) => {
        // 响应拦截器已自动解包 data 字段，resp 可能已是数组
        const dataArray = Array.isArray(resp) ? resp : resp.data;
        res.value[dictType] = dataArray.map(
          (p): DictDataOption => ({ label: p.dictLabel, value: p.dictValue, elTagType: p.listClass, elTagClass: p.cssClass })
        );
        useDictStore().setDict(dictType, res.value[dictType]);
      });
    }
  });
  return res.value;
};
