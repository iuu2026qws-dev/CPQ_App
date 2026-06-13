package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqPriceBookBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookVo;

import java.util.List;

public interface ICpqPriceBookService {
    List<CpqPriceBookVo> selectPriceBookList(CpqPriceBookBo bo);
    CpqPriceBookVo selectPriceBookById(Long priceBookId);
    int insertPriceBook(CpqPriceBookBo bo);
    int updatePriceBook(CpqPriceBookBo bo);
    int deletePriceBook(Long priceBookId);
}
