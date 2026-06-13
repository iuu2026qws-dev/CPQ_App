package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqProductCategory;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * CPQ 产品分类 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqProductCategory.class, reverseConvertGenerate = true)
public class CpqProductCategoryVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private Long parentCategoryId;
    private Integer categoryLevel;
    private String categoryCode;
    private String categoryName;
    private Integer sortOrder;
    private String status;
    private String tenantId;

    /** 父分类名称（展示用） */
    private String parentCategoryName;

    /** 子分类列表（树形展示用） */
    private List<CpqProductCategoryVo> children = new ArrayList<>();

    /** 创建时间 */
    private Date createTime;
    /** 更新时间 */
    private Date updateTime;
    /** 备注 */
    private String remark;
}
