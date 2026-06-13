package org.dromara.cpq.customer.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.customer.domain.CpqChannel;

@Mapper
public interface CpqChannelMapper extends BaseMapperPlus<CpqChannel, CpqChannel> {}
