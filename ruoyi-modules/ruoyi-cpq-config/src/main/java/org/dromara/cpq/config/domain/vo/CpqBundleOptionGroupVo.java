package org.dromara.cpq.config.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.config.domain.CpqBundleOptionGroup;

import java.io.Serial;
import java.io.Serializable;

@Data
@AutoMapper(target = CpqBundleOptionGroup.class, reverseConvertGenerate = true)
public class CpqBundleOptionGroupVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long optionGroupId;
    private Long bundleId;
    private String groupName;
    private String groupCode;
    private Integer minSelections;
    private Integer maxSelections;
    private String isRequired;
    private Integer sortOrder;
    private String status;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
