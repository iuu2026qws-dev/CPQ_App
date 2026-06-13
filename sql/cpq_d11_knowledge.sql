-- S15 知识库模块 DDL
DROP TABLE IF EXISTS cpq_knowledge_article;
CREATE TABLE cpq_knowledge_article (
    article_id          BIGINT NOT NULL COMMENT '文章ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    title               VARCHAR(500) NOT NULL COMMENT '标题',
    content             LONGTEXT COMMENT '内容',
    category            VARCHAR(100) DEFAULT NULL COMMENT '分类',
    article_type        VARCHAR(20) NOT NULL COMMENT '类型: PRODUCT/SCRIPT/CASE/TRAINING',
    tags                VARCHAR(500) DEFAULT NULL COMMENT '标签',
    view_count          INT DEFAULT 0 COMMENT '浏览次数',
    status              CHAR(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
    del_flag            CHAR(1) DEFAULT '0' COMMENT '删除标志(0正常 2删除)',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (article_id),
    INDEX idx_type (tenant_id, article_type, status),
    FULLTEXT INDEX ft_title_content (title, content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CPQ知识库文章';
