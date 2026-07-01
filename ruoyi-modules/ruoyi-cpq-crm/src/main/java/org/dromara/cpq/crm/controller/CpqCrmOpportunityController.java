package org.dromara.cpq.crm.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.crm.domain.bo.CpqCrmOpportunityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOpportunityVo;
import org.dromara.cpq.crm.service.ICpqCrmOpportunityService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 商机 Controller
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/crm/opportunity")
public class CpqCrmOpportunityController extends BaseController {

    private final ICpqCrmOpportunityService opportunityService;

    /** 分页查询商机列表 */
    @GetMapping("/list")
    public TableDataInfo<CpqCrmOpportunityVo> list(CpqCrmOpportunityBo bo, PageQuery pageQuery) {
        return opportunityService.queryPageList(bo, pageQuery);
    }

    /** 获取商机详情 */
    @GetMapping("/{id}")
    public R<CpqCrmOpportunityVo> getById(@PathVariable Long id) {
        return R.ok(opportunityService.queryById(id));
    }

    /** 新增商机 */
    @Log(title = "商机管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@RequestBody CpqCrmOpportunityBo bo) {
        return toAjax(opportunityService.insertByBo(bo));
    }

    /** 更新商机 */
    @Log(title = "商机管理", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@RequestBody CpqCrmOpportunityBo bo) {
        return toAjax(opportunityService.updateByBo(bo));
    }

    /** 推进商机阶段 */
    @Log(title = "商机管理", businessType = BusinessType.UPDATE)
    @PutMapping("/{id}/stage")
    public R<Void> advanceStage(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return toAjax(opportunityService.advanceStage(id, body.get("stage"), body.get("nextStep")));
    }

    /** 删除商机 */
    @Log(title = "商机管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(opportunityService.deleteWithValidByIds(Arrays.asList(ids)));
    }

    /** 获取商机关联的报价单列表 */
    @GetMapping("/{id}/quotes")
    public R<List<?>> getQuotes(@PathVariable Long id) {
        return R.ok(opportunityService.queryQuotesByOpportunityId(id));
    }

    /** 获取商机关联的销售活动列表 */
    @GetMapping("/{id}/activities")
    public R<List<?>> getActivities(@PathVariable Long id) {
        return R.ok(opportunityService.queryActivitiesByOpportunityId(id));
    }
}
