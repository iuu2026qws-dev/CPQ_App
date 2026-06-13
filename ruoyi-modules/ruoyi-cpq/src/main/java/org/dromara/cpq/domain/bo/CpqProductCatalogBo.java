package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqProductCatalog;

import java.io.Serial;
import java.util.Date;

/**
 * CPQ 产品目录 BO（对齐设计文档 cpq_product_catalog）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqProductCatalog.class, reverseConvertGenerate = false)
public class CpqProductCatalogBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long catalogId;
    private String catalogName;
    private String catalogType;
    private Date effectiveDate;
    private Date expiryDate;
    private String status;
}
