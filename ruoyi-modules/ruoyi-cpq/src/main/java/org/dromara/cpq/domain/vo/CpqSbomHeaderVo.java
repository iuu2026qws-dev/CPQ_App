package org.dromara.cpq.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.domain.CpqSbomHeader;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * CPQ SBOM 头表 VO
 *
 * @author CPQ Team
 */
@Data
@AutoMapper(target = CpqSbomHeader.class, reverseConvertGenerate = true)
public class CpqSbomHeaderVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long sbomHeaderId;
    private Long modelId;
    private String sbomName;
    private String sbomVersion;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
