package org.dromara.cpq.crm.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.crm.domain.CpqCrmOrderLine;

@Mapper
public interface CpqCrmOrderLineMapper extends BaseMapperPlus<CpqCrmOrderLine, CpqCrmOrderLine> {
}
