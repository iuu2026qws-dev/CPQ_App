package org.dromara.cpq.config.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.MapstructUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.dromara.cpq.config.domain.CpqAttributeOption;
import org.dromara.cpq.config.domain.bo.CpqAttributeOptionBo;
import org.dromara.cpq.config.domain.vo.CpqAttributeOptionVo;
import org.dromara.cpq.config.mapper.CpqAttributeOptionMapper;
import org.dromara.cpq.config.service.ICpqAttributeOptionService;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqAttributeOptionServiceImpl implements ICpqAttributeOptionService {

    private final CpqAttributeOptionMapper mapper;

    @Override
    public List<CpqAttributeOptionVo> selectList(CpqAttributeOptionBo bo) {
        log.info("查询属性选项列表，bo={}", cn.hutool.json.JSONUtil.toJsonStr(bo));
        LambdaQueryWrapper<CpqAttributeOption> qw = Wrappers.lambdaQuery();
        if (bo.getModelId() != null) {
            qw.eq(CpqAttributeOption::getModelId, bo.getModelId());
        }
        if (cn.hutool.core.util.StrUtil.isNotBlank(bo.getAttrName())) {
            qw.like(CpqAttributeOption::getAttrName, bo.getAttrName());
        }
        qw.orderByAsc(CpqAttributeOption::getModelId)
          .orderByAsc(CpqAttributeOption::getAttrName)
          .orderByAsc(CpqAttributeOption::getSortOrder);
        return mapper.selectVoList(qw);
    }

    @Override
    public CpqAttributeOptionVo selectById(Long id) {
        return mapper.selectVoById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert(CpqAttributeOptionBo bo) {
        CpqAttributeOption entity = MapstructUtils.convert(bo, CpqAttributeOption.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update(CpqAttributeOptionBo bo) {
        CpqAttributeOption existing = mapper.selectById(bo.getOptionId());
        if (ObjectUtil.isNull(existing)) {
            throw new RuntimeException("记录不存在");
        }
        CpqAttributeOption entity = MapstructUtils.convert(bo, CpqAttributeOption.class);
        int rows = mapper.updateById(entity);
        return rows > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean delete(Long id) {
        int rows = mapper.deleteById(id);
        return rows > 0;
    }
}
