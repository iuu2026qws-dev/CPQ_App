package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductCatalog;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ 产品目录 VO（对齐设计文档 cpq_product_catalog）
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductCatalog.class, reverseConvertGenerate = true)
public class CpqProductCatalogVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long catalogId;
    private String catalogName;
    private String catalogType;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
    private String tenantId;

    /** 创建时间 */
    private Date createTime;
    /** 更新时间 */
    private Date updateTime;
    /** 备注 */
    private String remark;
}
