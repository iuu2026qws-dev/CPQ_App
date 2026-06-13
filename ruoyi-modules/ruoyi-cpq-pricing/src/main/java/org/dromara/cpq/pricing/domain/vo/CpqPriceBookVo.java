package org.dromara.cpq.pricing.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.dromara.cpq.pricing.domain.CpqPriceBook;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

@Data
@AutoMapper(target = CpqPriceBook.class, reverseConvertGenerate = true)
public class CpqPriceBookVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private Long priceBookId;
    private String bookName;
    private String bookType;
    private String currency;
    private Date effectiveDate;
    private Date expiryDate;
    private Integer priority;
    private String status;
    private String tenantId;
    private Date createTime;
    private Date updateTime;
    private String remark;
}
