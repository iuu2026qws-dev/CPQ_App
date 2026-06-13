package org.dromara.cpq.competitive.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.competitive.domain.CpqRecommendation;

@Mapper
public interface CpqRecommendationMapper extends BaseMapperPlus<CpqRecommendation, CpqRecommendation> {}
