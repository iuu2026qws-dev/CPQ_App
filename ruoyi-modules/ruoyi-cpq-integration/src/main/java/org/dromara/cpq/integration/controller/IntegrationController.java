package org.dromara.cpq.integration.controller;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.integration.service.CrmConnector;
import org.dromara.cpq.integration.service.ErpConnector;
import org.dromara.cpq.integration.service.PlmConnector;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/integration") @RequiredArgsConstructor
public class IntegrationController {
    private final CrmConnector crmConnector;
    private final ErpConnector erpConnector;
    private final PlmConnector plmConnector;

    // CRM endpoints
    @PostMapping("/crm/opportunity")
    public R<Map<String, Object>> syncCrmOpportunity(@RequestBody Map<String, Object> params) {
        return crmConnector.syncOpportunity(params);
    }
    @PostMapping("/crm/quote-status/{quoteId}")
    public R<Void> pushQuoteStatus(@PathVariable Long quoteId, @RequestBody Map<String, String> body) {
        return crmConnector.pushQuoteStatus(quoteId, body.get("status"));
    }

    // ERP endpoints
    @PostMapping("/erp/order")
    public R<Map<String, Object>> createErpOrder(@RequestBody Map<String, Object> data) {
        return erpConnector.createOrder(data);
    }

    // PLM endpoints
    @PostMapping("/plm/product")
    public R<Map<String, Object>> syncPlmProduct(@RequestBody Map<String, Object> params) {
        return plmConnector.syncProductDefinition(params);
    }
    @PostMapping("/plm/ebom/{partNumber}")
    public R<Map<String, Object>> syncPlmEbom(@PathVariable String partNumber) {
        return plmConnector.syncEbom(partNumber);
    }
    @PostMapping("/plm/change")
    public R<Void> handlePlmChange(@RequestBody Map<String, Object> data) {
        return plmConnector.handleEngineeringChange(data);
    }
}
