package org.dromara.cpq.domain.bo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import io.github.linpeilie.annotations.AutoMapper;
import org.dromara.common.tenant.core.TenantEntity;
import org.dromara.cpq.domain.CpqSbomHeader;

import java.io.Serial;

/**
 * CPQ SBOM 头表 BO
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CpqSbomHeader.class, reverseConvertGenerate = false)
public class CpqSbomHeaderBo extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long sbomHeaderId;
    /** 所属产品ID */
    private Long modelId;
    /** SBOM名称 */
    private String sbomName;
    /** SBOM版本 */
    private String sbomVersion;
    /** 状态 */
    private String status;
}
