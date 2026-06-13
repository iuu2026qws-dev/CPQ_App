package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ 系统参数（对齐设计文档 cpq_system_config）
 * D07 系统数据域 — 扩展 RuoYi sys_config，存储 CPQ 业务级配置参数
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_system_config")
public class CpqSystemConfig extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "config_id")
    private Long configId;

    /** 配置键 */
    private String configKey;

    /** 配置值 */
    private String configValue;

    /** 值类型: STRING/NUMBER/JSON/BOOLEAN */
    private String configType;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
