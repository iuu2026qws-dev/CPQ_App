package org.dromara.system.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cpq_plant")
public class CpqPlant extends TenantEntity {
    @TableId
    private Long plantId;
    private String plantCode;
    private String plantName;
    private String location;
    private Integer capacityPerDay;
    private Integer workingDaysPerYear;
    private String qualityLevel;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
