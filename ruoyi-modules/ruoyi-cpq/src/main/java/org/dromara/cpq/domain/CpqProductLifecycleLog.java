package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.activerecord.Model;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;
import java.util.Date;

/**
 * CPQ 产品生命周期变更日志（对齐 M-CPQ 数据架构设计 cpq_product_lifecycle_log）
 * D01 产品数据域 — 不可删除（无 del_flag），不含 BaseEntity 审计字段
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_lifecycle_log")
public class CpqProductLifecycleLog extends Model<CpqProductLifecycleLog> {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "log_id")
    private Long logId;

    /** 租户ID */
    private String tenantId;

    /** 产品ID */
    private Long modelId;

    /** 变更前状态 */
    private String fromStatus;

    /** 变更后状态 */
    private String toStatus;

    /** 变更原因 */
    private String changeReason;

    /** 变更人 */
    private Long changeBy;

    /** 变更时间 */
    private Date changeTime;
}
