package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * CPQ 制造BOM行（SBOM→MBOM转换结果，对齐设计文档 cpq_mbom_line）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_mbom_line")
public class CpqMbomLine extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "mbom_line_id")
    private Long mbomLineId;

    private Long sbomLineId;
    private Long modelId;
    private Long parentMbomLineId;
    private Integer lineNumber;
    private String materialCode;
    private String materialDesc;
    private String materialType;
    private BigDecimal quantity;
    private String unit;
    private String plant;
    private String storageLocation;
    private String requirementType;
    private String substituteGroup;
    private Integer substitutePriority;
    private String costComponent;
    private Integer leadTimeDays;
    private BigDecimal moq;
    private Integer sortOrder;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
