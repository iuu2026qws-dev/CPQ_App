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
import java.util.List;

/**
 * CPQ 产品分类（层级树，替代产品模型中的 L1/L2/L3 字符串字段）
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_product_category")
public class CpqProductCategory extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 分类ID */
    @TableId(value = "category_id")
    private Long categoryId;

    /** 父分类ID（自引用FK，NULL=根节点/L1产品族） */
    private Long parentCategoryId;

    /** 层级: 1=产品族, 2=产品线, 3=产品系列 */
    private Integer categoryLevel;

    /** 分类编码 */
    private String categoryCode;

    /** 分类名称 */
    private String categoryName;

    /** 排序号 */
    private Integer sortOrder;

    /** 状态(0正常 1停用) */
    private String status;

    /** 删除标志(0=正常 2=删除) */
    @TableLogic(value = "0", delval = "2")
    private String delFlag;

    /** 子分类（非数据库字段，树形展示用） */
    @TableField(exist = false)
    private List<CpqProductCategory> children = new ArrayList<>();
}
