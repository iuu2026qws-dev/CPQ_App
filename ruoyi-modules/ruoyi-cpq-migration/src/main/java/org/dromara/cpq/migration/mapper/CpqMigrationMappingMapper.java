package org.dromara.cpq.migration.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.migration.domain.CpqMigrationMapping;

@Mapper
public interface CpqMigrationMappingMapper extends BaseMapperPlus<CpqMigrationMapping, CpqMigrationMapping> {}
