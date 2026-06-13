package org.dromara.cpq.integration.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.integration.domain.CpqSyncLog;

@Mapper
public interface CpqSyncLogMapper extends BaseMapperPlus<CpqSyncLog, CpqSyncLog> {}
