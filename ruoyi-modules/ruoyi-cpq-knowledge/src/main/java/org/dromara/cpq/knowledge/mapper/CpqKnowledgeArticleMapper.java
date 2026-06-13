package org.dromara.cpq.knowledge.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.cpq.knowledge.domain.CpqKnowledgeArticle;

@Mapper
public interface CpqKnowledgeArticleMapper extends BaseMapperPlus<CpqKnowledgeArticle, CpqKnowledgeArticle> {}
