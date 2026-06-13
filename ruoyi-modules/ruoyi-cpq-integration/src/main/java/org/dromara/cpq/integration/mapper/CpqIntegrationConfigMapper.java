package org.dromara.cpq.integration.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.integration.domain.CpqIntegrationConfig;

@Mapper
public interface CpqIntegrationConfigMapper extends BaseMapperPlus<CpqIntegrationConfig, CpqIntegrationConfig> {}
