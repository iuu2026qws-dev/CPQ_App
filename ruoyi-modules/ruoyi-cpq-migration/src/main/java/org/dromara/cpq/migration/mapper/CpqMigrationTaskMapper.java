package org.dromara.cpq.migration.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.migration.domain.CpqMigrationTask;

@Mapper
public interface CpqMigrationTaskMapper extends BaseMapperPlus<CpqMigrationTask, CpqMigrationTask> {}
