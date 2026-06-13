package org.dromara.cpq.competitive.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.competitive.domain.CpqComparison;

@Mapper
public interface CpqComparisonMapper extends BaseMapperPlus<CpqComparison, CpqComparison> {}
