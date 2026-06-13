package org.dromara.cpq.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;

/**
 * CPQ SBOM 头表（对齐设计文档 cpq_sbom_header）
 * D01 产品数据域
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_sbom_header")
public class CpqSbomHeader extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "sbom_header_id")
    private Long sbomHeaderId;

    /** 所属产品ID */
    private Long modelId;

    /** SBOM名称 */
    private String sbomName;

    /** SBOM版本 */
    private String sbomVersion;

    /** 状态 */
    private String status;

    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
