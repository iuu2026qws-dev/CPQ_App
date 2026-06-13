package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * CPQ 产品目录（对齐设计文档 cpq_product_catalog）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_catalog")
public class CpqProductCatalog extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 目录ID */
    @TableId(value = "catalog_id")
    private Long catalogId;

    /** 目录名称 */
    private String catalogName;

    /** 目录类型: SALES/CHANNEL/INTERNAL */
    private String catalogType;

    /** 生效日期 */
    private Date effectiveDate;

    /** 失效日期 */
    private Date expiryDate;

    /** 状态(0=正常 1=停用) */
    private String status;

    /** 删除标志(0=正常 2=删除) */
    @TableLogic(value = "0", delval = "2")
    private String delFlag;

    /** 子目录（非数据库字段） */
    @TableField(exist = false)
    private List<CpqProductCatalog> children = new ArrayList<>();
}
