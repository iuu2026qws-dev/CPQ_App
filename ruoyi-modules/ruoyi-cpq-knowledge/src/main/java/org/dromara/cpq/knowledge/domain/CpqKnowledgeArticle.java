package org.dromara.cpq.knowledge.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_knowledge_article")
public class CpqKnowledgeArticle extends TenantEntity {
    @TableId
    private Long articleId;
    private String title;
    private String content;
    private String category;
    private String articleType;
    private String tags;
    private Integer viewCount;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
