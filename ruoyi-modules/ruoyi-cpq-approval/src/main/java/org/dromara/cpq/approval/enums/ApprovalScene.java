package org.dromara.cpq.approval.enums;

/** CPQ 统一审批场景枚举 */
public enum ApprovalScene {
    QUOTE("报价审批"),
    PROCESS("工艺确认"),
    ECN("工程变更"),
    PRICING("定价变更"),
    CONFIG("配置审批"),
    CRM("CRM审批"),
    CUSTOMER("客户审批");

    private final String label;
    ApprovalScene(String label) { this.label = label; }
    public String getLabel() { return label; }
}
