package org.dromara.cpq.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.domain.CpqProductCatalog;
import org.dromara.cpq.domain.bo.CpqProductCatalogBo;
import org.dromara.cpq.domain.vo.CpqProductCatalogVo;
import org.dromara.cpq.mapper.CpqProductCatalogMapper;
import org.dromara.cpq.service.ICpqProductCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * CPQ 产品目录 Service 实现
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CpqProductCatalogServiceImpl implements ICpqProductCatalogService {

    private final CpqProductCatalogMapper baseMapper;

    @Override
    public List<CpqProductCatalogVo> selectCatalogList(CpqProductCatalogBo bo) {
        log.info("查询CPQ产品目录列表，参数: {}", bo);
        LambdaQueryWrapper<CpqProductCatalog> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getCatalogName())) {
            wrapper.like(CpqProductCatalog::getCatalogName, bo.getCatalogName());
        }
        if (ObjectUtil.isNotNull(bo.getCatalogType())) {
            wrapper.eq(CpqProductCatalog::getCatalogType, bo.getCatalogType());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqProductCatalog::getStatus, bo.getStatus());
        }
        wrapper.orderByAsc(CpqProductCatalog::getCreateTime);
        List<CpqProductCatalog> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqProductCatalogVo.class);
    }

    @Override
    public CpqProductCatalogVo selectCatalogById(Long catalogId) {
        log.info("查询CPQ产品目录，ID: {}", catalogId);
        CpqProductCatalog catalog = baseMapper.selectById(catalogId);
        if (ObjectUtil.isNull(catalog)) {
            throw new ServiceException("产品目录不存在");
        }
        return MapstructUtils.convert(catalog, CpqProductCatalogVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertCatalog(CpqProductCatalogBo bo) {
        log.info("新增CPQ产品目录，参数: {}", bo);
        if (!checkCatalogNameUnique(bo)) {
            throw new ServiceException("产品目录名称已存在");
        }
        CpqProductCatalog catalog = MapstructUtils.convert(bo, CpqProductCatalog.class);
        return baseMapper.insert(catalog);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateCatalog(CpqProductCatalogBo bo) {
        log.info("修改CPQ产品目录，参数: {}", bo);
        if (!checkCatalogNameUnique(bo)) {
            throw new ServiceException("产品目录名称已存在");
        }
        CpqProductCatalog catalog = MapstructUtils.convert(bo, CpqProductCatalog.class);
        return baseMapper.updateById(catalog);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteCatalog(Long catalogId) {
        log.info("删除CPQ产品目录，ID: {}", catalogId);
        return baseMapper.deleteById(catalogId);
    }

    @Override
    public boolean checkCatalogNameUnique(CpqProductCatalogBo bo) {
        return !baseMapper.exists(new LambdaQueryWrapper<CpqProductCatalog>()
            .eq(CpqProductCatalog::getCatalogName, bo.getCatalogName())
            .ne(ObjectUtil.isNotNull(bo.getCatalogId()), CpqProductCatalog::getCatalogId, bo.getCatalogId()));
    }
}
