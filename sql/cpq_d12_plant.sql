-- S16 多工厂产能分配 DDL
DROP TABLE IF EXISTS cpq_plant;
CREATE TABLE cpq_plant (
    plant_id            BIGINT NOT NULL COMMENT '工厂ID',
    tenant_id           VARCHAR(20) DEFAULT '000000',
    plant_code          VARCHAR(50) NOT NULL COMMENT '工厂编码',
    plant_name          VARCHAR(100) NOT NULL COMMENT '工厂名称',
    location            VARCHAR(200) DEFAULT NULL COMMENT '位置',
    capacity_per_day    INT DEFAULT 0 COMMENT '日产能',
    working_days_per_year INT DEFAULT 250 COMMENT '年工作天数',
    quality_level       VARCHAR(20) DEFAULT 'STANDARD' COMMENT '资质等级',
    status              CHAR(1) DEFAULT '0',
    del_flag            CHAR(1) DEFAULT '0' COMMENT '0正常 2删除',
    create_dept         BIGINT DEFAULT NULL,
    create_by           BIGINT DEFAULT NULL,
    create_time         DATETIME DEFAULT NULL,
    update_by           BIGINT DEFAULT NULL,
    update_time         DATETIME DEFAULT NULL,
    remark              VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (plant_id),
    UNIQUE KEY uk_plant (tenant_id, plant_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CPQ工厂注册';
