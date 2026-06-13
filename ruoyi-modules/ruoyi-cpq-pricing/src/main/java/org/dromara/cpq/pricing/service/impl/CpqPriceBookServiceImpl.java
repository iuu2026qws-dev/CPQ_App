package org.dromara.cpq.pricing.service.impl;

import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.cpq.pricing.domain.CpqPriceBook;
import org.dromara.cpq.pricing.domain.bo.CpqPriceBookBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookVo;
import org.dromara.cpq.pricing.mapper.CpqPriceBookMapper;
import org.dromara.cpq.pricing.service.ICpqPriceBookService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CpqPriceBookServiceImpl implements ICpqPriceBookService {

    private final CpqPriceBookMapper baseMapper;

    @Override
    public List<CpqPriceBookVo> selectPriceBookList(CpqPriceBookBo bo) {
        log.info("查询CPQ价格手册列表，参数: {}", bo);
        LambdaQueryWrapper<CpqPriceBook> wrapper = new LambdaQueryWrapper<>();
        if (ObjectUtil.isNotNull(bo.getBookName())) {
            wrapper.like(CpqPriceBook::getBookName, bo.getBookName());
        }
        if (ObjectUtil.isNotNull(bo.getBookType())) {
            wrapper.eq(CpqPriceBook::getBookType, bo.getBookType());
        }
        if (ObjectUtil.isNotNull(bo.getStatus())) {
            wrapper.eq(CpqPriceBook::getStatus, bo.getStatus());
        }
        wrapper.orderByDesc(CpqPriceBook::getPriority).orderByDesc(CpqPriceBook::getCreateTime);
        List<CpqPriceBook> list = baseMapper.selectList(wrapper);
        return MapstructUtils.convert(list, CpqPriceBookVo.class);
    }

    @Override
    public CpqPriceBookVo selectPriceBookById(Long priceBookId) {
        log.info("查询CPQ价格手册详情，ID: {}", priceBookId);
        CpqPriceBook book = baseMapper.selectById(priceBookId);
        if (ObjectUtil.isNull(book)) {
            throw new ServiceException("价格手册不存在");
        }
        return MapstructUtils.convert(book, CpqPriceBookVo.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertPriceBook(CpqPriceBookBo bo) {
        log.info("新增CPQ价格手册，参数: {}", bo);
        CpqPriceBook book = MapstructUtils.convert(bo, CpqPriceBook.class);
        return baseMapper.insert(book);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updatePriceBook(CpqPriceBookBo bo) {
        log.info("修改CPQ价格手册，参数: {}", bo);
        CpqPriceBook book = MapstructUtils.convert(bo, CpqPriceBook.class);
        return baseMapper.updateById(book);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deletePriceBook(Long priceBookId) {
        log.info("删除CPQ价格手册，ID: {}", priceBookId);
        return baseMapper.deleteById(priceBookId);
    }
}
