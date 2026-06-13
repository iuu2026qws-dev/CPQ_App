package org.dromara.cpq.pricing.service;

import org.dromara.cpq.pricing.domain.bo.CpqPriceBookEntryBo;
import org.dromara.cpq.pricing.domain.vo.CpqPriceBookEntryVo;

import java.util.List;

public interface ICpqPriceBookEntryService {
    List<CpqPriceBookEntryVo> selectEntryList(CpqPriceBookEntryBo bo);
    CpqPriceBookEntryVo selectEntryById(Long entryId);
    int insertEntry(CpqPriceBookEntryBo bo);
    int updateEntry(CpqPriceBookEntryBo bo);
    int deleteEntry(Long entryId);
}
