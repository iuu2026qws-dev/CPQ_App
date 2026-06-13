package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqSystemConfig;
import org.dromara.cpq.domain.bo.CpqSystemConfigBo;
import org.dromara.cpq.domain.vo.CpqSystemConfigVo;
import org.dromara.cpq.mapper.CpqSystemConfigMapper;
import org.dromara.cpq.service.ICpqSystemConfigService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ 系统参数 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqSystemConfigServiceImpl implements ICpqSystemConfigService {

    private final CpqSystemConfigMapper baseMapper;

    @Override
    public List<CpqSystemConfigVo> selectConfigList(CpqSystemConfigBo bo) {
        log.info("查询CPQ系统参数列表，参数: {}", bo);
        LambdaQueryWrapper<CpqSystemConfig> wrapper = new LambdaQueryWrapper<>();
        if (StrUtil.isNotBlank(bo.getConfigKey())) {
            wrapper.like(CpqSystemConfig::getConfigKey, bo.getConfigKey());
        }
        if (StrUtil.isNotBlank(bo.getConfigType())) {
            wrapper.eq(CpqSystemConfig::getConfigType, bo.getConfigType());
        }
        wrapper.orderByAsc(CpqSystemConfig::getConfigKey);
        return MapstructUtils.convert(baseMapper.selectList(wrapper), CpqSystemConfigVo.class);
    }

    @Override
    public CpqSystemConfigVo selectConfigById(Long configId) {
        log.info("查询CPQ系统参数，ID: {}", configId);
        CpqSystemConfig config = baseMapper.selectById(configId);
        if (ObjectUtil.isNull(config)) {
            throw new ServiceException("系统参数不存在");
        }
        return MapstructUtils.convert(config, CpqSystemConfigVo.class);
    }

    @Override
    public CpqSystemConfigVo selectConfigByKey(String configKey) {
        log.info("按KEY查询CPQ系统参数，configKey: {}", configKey);
        CpqSystemConfig config = baseMapper.selectOne(
            new LambdaQueryWrapper<CpqSystemConfig>()
                .eq(CpqSystemConfig::getConfigKey, configKey));
        if (ObjectUtil.isNull(config)) {
            return null;
        }
        return MapstructUtils.convert(config, CpqSystemConfigVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertConfig(CpqSystemConfigBo bo) {
        log.info("新增CPQ系统参数，参数: {}", bo);
        CpqSystemConfig config = MapstructUtils.convert(bo, CpqSystemConfig.class);
        return baseMapper.insert(config);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateConfig(CpqSystemConfigBo bo) {
        log.info("修改CPQ系统参数，参数: {}", bo);
        CpqSystemConfig config = MapstructUtils.convert(bo, CpqSystemConfig.class);
        return baseMapper.updateById(config);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteConfig(Long configId) {
        log.info("删除CPQ系统参数，ID: {}", configId);
        return baseMapper.deleteById(configId);
    }
}
