package org.dromara.cpq.service;

import cn.hutool.json.JSONUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * BOM 展开 + 定价缓存服务（S20.2 / S20.3）
 * 将 BOM 递归展开结果、报价模板填充结果写入 Redis，
 * 键策略：cpq:bom:{productId}:{plantId} / cpq:quote:template:{templateId}
 * TTL：BOM 缓存 30min，报价模板 10min
 *
 * @author CPQ Team
 * @since 2026-06-09
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BomCacheService {

    private final StringRedisTemplate redisTemplate;

    private static final String BOM_KEY_PREFIX = "cpq:bom:";
    private static final String QUOTE_KEY_PREFIX = "cpq:quote:template:";
    private static final long BOM_TTL_MINUTES = 30;
    private static final long QUOTE_TTL_MINUTES = 10;

    // ========== BOM 展开缓存 ==========

    /**
     * 缓存 BOM 展开结果
     * @param productId 产品ID
     * @param plantId 工厂ID（可选，0表示忽略工厂）
     * @param bomItems BOM行项目列表
     */
    public void cacheBomExplosion(Long productId, Long plantId, List<Map<String, Object>> bomItems) {
        if (productId == null) return;
        String key = buildBomKey(productId, plantId);
        String json = JSONUtil.toJsonStr(bomItems);
        redisTemplate.opsForValue().set(key, json, BOM_TTL_MINUTES, TimeUnit.MINUTES);
        if (log.isDebugEnabled()) {
            log.debug("[BOM Cache] 写入 {} — {} 行, TTL={}min", key, bomItems.size(), BOM_TTL_MINUTES);
        }
    }

    /**
     * 获取 BOM 展开缓存
     * @return 缓存命中的BOM行项目列表，未命中返回 null
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getBomExplosion(Long productId, Long plantId) {
        if (productId == null) return null;
        String key = buildBomKey(productId, plantId);
        String json = redisTemplate.opsForValue().get(key);
        if (json == null) return null;
        try {
            List<Map<String, Object>> result = (List) JSONUtil.toList(json, Map.class);
            log.debug("[BOM Cache] 命中 {} — {} 行", key, result.size());
            return result;
        } catch (Exception e) {
            log.warn("[BOM Cache] 反序列化失败 {}: {}", key, e.getMessage());
            evictBomCache(productId, plantId);
            return null;
        }
    }

    /**
     * 清除 BOM 缓存（当 BOM 数据变更时调用）
     */
    public void evictBomCache(Long productId, Long plantId) {
        String key = buildBomKey(productId, plantId);
        redisTemplate.delete(key);
        // 也清除无工厂的通用缓存
        if (plantId != null && plantId != 0) {
            redisTemplate.delete(buildBomKey(productId, 0L));
        }
        log.debug("[BOM Cache] 清除 {}", key);
    }

    /**
     * 批量清除所有相关 BOM 缓存
     */
    public void evictBomCacheByProduct(Long productId) {
        String pattern = BOM_KEY_PREFIX + productId + ":*";
        redisTemplate.keys(pattern).forEach(redisTemplate::delete);
        log.info("[BOM Cache] 批量清除 productId={}", productId);
    }

    // ========== 报价模板缓存 ==========

    /**
     * 缓存报价模板填充结果
     */
    public void cacheQuoteTemplate(Long templateId, Map<String, Object> templateData) {
        if (templateId == null) return;
        String key = QUOTE_KEY_PREFIX + templateId;
        String json = JSONUtil.toJsonStr(templateData);
        redisTemplate.opsForValue().set(key, json, QUOTE_TTL_MINUTES, TimeUnit.MINUTES);
    }

    /**
     * 获取报价模板缓存
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> getQuoteTemplate(Long templateId) {
        if (templateId == null) return null;
        String key = QUOTE_KEY_PREFIX + templateId;
        String json = redisTemplate.opsForValue().get(key);
        if (json == null) return null;
        try {
            return JSONUtil.toBean(json, Map.class);
        } catch (Exception e) {
            log.warn("[Quote Cache] 反序列化失败 {}: {}", key, e.getMessage());
            redisTemplate.delete(key);
            return null;
        }
    }

    public void evictQuoteTemplateCache(Long templateId) {
        redisTemplate.delete(QUOTE_KEY_PREFIX + templateId);
    }

    // ========== 辅助方法 ==========

    private String buildBomKey(Long productId, Long plantId) {
        return BOM_KEY_PREFIX + productId + ":" + (plantId != null && plantId > 0 ? plantId : 0);
    }
}
