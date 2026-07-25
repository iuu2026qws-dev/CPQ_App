package org.dromara.cpq.match.domain.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
public class MatchRequirements {
    private Map<String, BigDecimal> dimensions;
    private String usageType;
    private BigDecimal tempMin;
    private BigDecimal tempMax;
    private BigDecimal lifeCycleYears;
    private String sealLevel;
    private List<String> requiredCertifications;
    private String extraNotes;
}
