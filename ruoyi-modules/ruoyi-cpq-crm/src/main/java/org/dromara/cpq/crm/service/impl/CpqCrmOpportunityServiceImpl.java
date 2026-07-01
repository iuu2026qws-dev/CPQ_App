package org.dromara.cpq.crm.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.mybatis.utils.IdGeneratorUtil;
import org.dromara.cpq.crm.domain.CpqCrmActivity;
import org.dromara.cpq.crm.domain.CpqCrmOpportunity;
import org.dromara.cpq.crm.domain.bo.CpqCrmOpportunityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmActivityVo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOpportunityVo;
import org.dromara.cpq.crm.mapper.CpqCrmActivityMapper;
import org.dromara.cpq.crm.mapper.CpqCrmOpportunityMapper;
import org.dromara.cpq.crm.service.ICpqCrmOpportunityService;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.mapper.CpqQuoteMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 商机 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class CpqCrmOpportunityServiceImpl extends ServiceImpl<CpqCrmOpportunityMapper, CpqCrmOpportunity>
        implements ICpqCrmOpportunityService {

    private final CpqCrmActivityMapper activityMapper;
    private final CpqQuoteMapper quoteMapper;

    private final AtomicInteger codeSeq = new AtomicInteger(1);

    /** 阶段→概率 映射 */
    private static final Map<String, BigDecimal> STAGE_PROBABILITY = new LinkedHashMap<>();
    static {
        STAGE_PROBABILITY.put("PROSPECTING", new BigDecimal("10"));
        STAGE_PROBABILITY.put("QUALIFICATION", new BigDecimal("25"));
        STAGE_PROBABILITY.put("PROPOSAL", new BigDecimal("50"));
        STAGE_PROBABILITY.put("NEGOTIATION", new BigDecimal("75"));
        STAGE_PROBABILITY.put("CLOSED_WON", new BigDecimal("100"));
        STAGE_PROBABILITY.put("CLOSED_LOST", new BigDecimal("0"));
    }

    /** 阶段顺序（用于校验不可回退） */
    private static final List<String> STAGE_ORDER = Arrays.asList(
        "PROSPECTING", "QUALIFICATION", "PROPOSAL", "NEGOTIATION", "CLOSED_WON", "CLOSED_LOST"
    );

    @Override
    public CpqCrmOpportunityVo queryById(Long id) {
        log.info("查询商机详情: id={}", id);
        CpqCrmOpportunity entity = getById(id);
        return entity == null ? null : BeanUtil.toBean(entity, CpqCrmOpportunityVo.class);
    }

    @Override
    public TableDataInfo<CpqCrmOpportunityVo> queryPageList(CpqCrmOpportunityBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqCrmOpportunity> qw = buildQueryWrapper(bo);
        List<CpqCrmOpportunity> list = page(pageQuery.build(), qw).getRecords();
        return TableDataInfo.build(BeanUtil.copyToList(list, CpqCrmOpportunityVo.class));
    }

    @Override
    public List<CpqCrmOpportunityVo> queryList(CpqCrmOpportunityBo bo) {
        LambdaQueryWrapper<CpqCrmOpportunity> qw = buildQueryWrapper(bo);
        return BeanUtil.copyToList(list(qw), CpqCrmOpportunityVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insertByBo(CpqCrmOpportunityBo bo) {
        log.info("新增商机: {}", bo.getOpportunityName());
        CpqCrmOpportunity entity = BeanUtil.toBean(bo, CpqCrmOpportunity.class);
        if (entity.getOpportunityId() == null) {
            entity.setOpportunityId(IdGeneratorUtil.nextLongId());
        }
        // 自动生成商机编码: OPP-20260615-0001
        if (StringUtils.isBlank(entity.getOpportunityCode())) {
            entity.setOpportunityCode(generateOpportunityCode());
        }
        // 默认阶段
        if (StringUtils.isBlank(entity.getStage())) {
            entity.setStage("PROSPECTING");
        }
        // 阶段→概率自动赋值
        entity.setProbability(STAGE_PROBABILITY.getOrDefault(entity.getStage(), new BigDecimal("10")));
        // 非关闭状态默认进行中
        if (StringUtils.isBlank(entity.getIsClosed())) {
            entity.setIsClosed("0");
        }
        return save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean updateByBo(CpqCrmOpportunityBo bo) {
        log.info("更新商机: id={}", bo.getOpportunityId());
        CpqCrmOpportunity entity = BeanUtil.toBean(bo, CpqCrmOpportunity.class);
        // 如果更新了阶段，重新设置概率
        if (StringUtils.isNotBlank(entity.getStage())) {
            entity.setProbability(STAGE_PROBABILITY.getOrDefault(entity.getStage(), entity.getProbability()));
            // CLOSED_WON/CLOSED_LOST 自动关闭
            if ("CLOSED_WON".equals(entity.getStage()) || "CLOSED_LOST".equals(entity.getStage())) {
                entity.setIsClosed("1");
            }
        }
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean deleteWithValidByIds(List<Long> ids) {
        log.info("软删除商机: ids={}", ids);
        if (CollUtil.isEmpty(ids)) {
            return false;
        }
        return update(new LambdaUpdateWrapper<CpqCrmOpportunity>()
                .setSql("del_flag = '2'")
                .in(CpqCrmOpportunity::getOpportunityId, ids));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean advanceStage(Long id, String stage, String nextStep) {
        log.info("推进商机阶段: id={}, stage={}, nextStep={}", id, stage, nextStep);
        CpqCrmOpportunity entity = getById(id);
        if (entity == null) {
            log.warn("商机不存在: id={}", id);
            return false;
        }

        String currentStage = entity.getStage();
        // 校验阶段不可回退
        int currentIdx = STAGE_ORDER.indexOf(currentStage);
        int targetIdx = STAGE_ORDER.indexOf(stage);
        if (targetIdx <= currentIdx) {
            log.warn("阶段不可回退: {} -> {}", currentStage, stage);
            throw new RuntimeException("阶段不可回退，当前阶段: " + currentStage);
        }

        // 更新阶段和概率
        entity.setStage(stage);
        entity.setProbability(STAGE_PROBABILITY.getOrDefault(stage, entity.getProbability()));
        if (StringUtils.isNotBlank(nextStep)) {
            entity.setNextStep(nextStep);
        }
        // CLOSED_WON/CLOSED_LOST 自动关闭
        if ("CLOSED_WON".equals(stage) || "CLOSED_LOST".equals(stage)) {
            entity.setIsClosed("1");
        }
        boolean updated = updateById(entity);

        // 自动创建活动日志
        if (updated) {
            CpqCrmActivity activity = new CpqCrmActivity();
            activity.setActivityId(IdGeneratorUtil.nextLongId());
            activity.setOpportunityId(id);
            activity.setAccountId(entity.getAccountId());
            activity.setActivityType("STAGE_CHANGE");
            activity.setSubject("阶段推进: " + currentStage + " → " + stage);
            activity.setActivityDate(new Date());
            activity.setResult("系统自动记录: 商机阶段从 " + currentStage + " 推进到 " + stage);
            if (StringUtils.isNotBlank(nextStep)) {
                activity.setNextPlan(nextStep);
            }
            activityMapper.insert(activity);
            log.info("商机阶段推进成功，已自动记录活动日志: id={}, {} -> {}", id, currentStage, stage);
        }

        return updated;
    }

    @Override
    public List<?> queryQuotesByOpportunityId(Long opportunityId) {
        log.info("查询商机关联报价单: opportunityId={}", opportunityId);
        List<CpqQuote> quotes = quoteMapper.selectList(new LambdaQueryWrapper<CpqQuote>()
                .eq(CpqQuote::getOpportunityId, opportunityId)
                .orderByDesc(CpqQuote::getCreateTime));
        return quotes;
    }

    @Override
    public List<?> queryActivitiesByOpportunityId(Long opportunityId) {
        log.info("查询商机关联销售活动: opportunityId={}", opportunityId);
        List<CpqCrmActivity> activities = activityMapper.selectList(new LambdaQueryWrapper<CpqCrmActivity>()
                .eq(CpqCrmActivity::getOpportunityId, opportunityId)
                .orderByDesc(CpqCrmActivity::getActivityDate));
        return BeanUtil.copyToList(activities, CpqCrmActivityVo.class);
    }

    /**
     * 生成商机编码: OPP-YYYYMMDD-序号
     */
    private String generateOpportunityCode() {
        String datePart = DateUtil.format(DateUtil.date(), "yyyyMMdd");
        int seq = codeSeq.getAndIncrement();
        return String.format("OPP-%s-%04d", datePart, seq % 10000);
    }

    /**
     * 构建查询条件
     */
    private LambdaQueryWrapper<CpqCrmOpportunity> buildQueryWrapper(CpqCrmOpportunityBo bo) {
        LambdaQueryWrapper<CpqCrmOpportunity> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.isNotBlank(bo.getOpportunityName()), CpqCrmOpportunity::getOpportunityName, bo.getOpportunityName());
        qw.like(StringUtils.isNotBlank(bo.getOpportunityCode()), CpqCrmOpportunity::getOpportunityCode, bo.getOpportunityCode());
        qw.eq(bo.getAccountId() != null, CpqCrmOpportunity::getAccountId, bo.getAccountId());
        qw.eq(StringUtils.isNotBlank(bo.getStage()), CpqCrmOpportunity::getStage, bo.getStage());
        qw.eq(bo.getOwnerId() != null, CpqCrmOpportunity::getOwnerId, bo.getOwnerId());
        qw.orderByDesc(CpqCrmOpportunity::getCreateTime);
        return qw;
    }
}
