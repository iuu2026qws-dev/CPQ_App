package org.dromara.cpq.competitive.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.competitive.domain.CpqCompetitor;

@Mapper
public interface CpqCompetitorMapper extends BaseMapperPlus<CpqCompetitor, CpqCompetitor> {}
