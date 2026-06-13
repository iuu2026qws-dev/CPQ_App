package org.dromara.cpq.customer.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.customer.domain.CpqTerritory;

@Mapper
public interface CpqTerritoryMapper extends BaseMapperPlus<CpqTerritory, CpqTerritory> {}
