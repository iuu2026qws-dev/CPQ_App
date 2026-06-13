package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqMbomLine;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * CPQ MBOM 行 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqMbomLine.class, reverseConvertGenerate = true)
public class CpqMbomLineVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

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
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
