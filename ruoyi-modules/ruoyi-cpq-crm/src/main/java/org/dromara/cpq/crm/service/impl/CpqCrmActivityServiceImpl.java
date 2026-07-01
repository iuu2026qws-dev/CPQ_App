package org.dromara.cpq.crm.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.mybatis.utils.IdGeneratorUtil;
import org.dromara.cpq.crm.domain.CpqCrmActivity;
import org.dromara.cpq.crm.domain.bo.CpqCrmActivityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmActivityVo;
import org.dromara.cpq.crm.mapper.CpqCrmActivityMapper;
import org.dromara.cpq.crm.service.ICpqCrmActivityService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 销售活动 Service 实现（简单 CRUD，无复杂业务逻辑）
 *
 * @author CPQ Team
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class CpqCrmActivityServiceImpl extends ServiceImpl<CpqCrmActivityMapper, CpqCrmActivity>
        implements ICpqCrmActivityService {

    @Override
    public CpqCrmActivityVo queryById(Long id) {
        log.info("查询销售活动: id={}", id);
        CpqCrmActivity entity = getById(id);
        return entity == null ? null : BeanUtil.toBean(entity, CpqCrmActivityVo.class);
    }

    @Override
    public TableDataInfo<CpqCrmActivityVo> queryPageList(CpqCrmActivityBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CpqCrmActivity> qw = new LambdaQueryWrapper<>();
        qw.eq(bo.getOpportunityId() != null, CpqCrmActivity::getOpportunityId, bo.getOpportunityId());
        qw.eq(bo.getAccountId() != null, CpqCrmActivity::getAccountId, bo.getAccountId());
        qw.orderByDesc(CpqCrmActivity::getActivityDate, CpqCrmActivity::getCreateTime);
        List<CpqCrmActivity> list = page(pageQuery.build(), qw).getRecords();
        return TableDataInfo.build(BeanUtil.copyToList(list, CpqCrmActivityVo.class));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insertByBo(CpqCrmActivityBo bo) {
        log.info("新增销售活动: subject={}", bo.getSubject());
        CpqCrmActivity entity = BeanUtil.toBean(bo, CpqCrmActivity.class);
        if (entity.getActivityId() == null) {
            entity.setActivityId(IdGeneratorUtil.nextLongId());
        }
        return save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean updateByBo(CpqCrmActivityBo bo) {
        log.info("更新销售活动: id={}", bo.getActivityId());
        CpqCrmActivity entity = BeanUtil.toBean(bo, CpqCrmActivity.class);
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean deleteWithValidByIds(List<Long> ids) {
        log.info("软删除销售活动: ids={}", ids);
        if (CollUtil.isEmpty(ids)) {
            return false;
        }
        return update(new LambdaUpdateWrapper<CpqCrmActivity>()
                .setSql("del_flag = '2'")
                .in(CpqCrmActivity::getActivityId, ids));
    }
}
