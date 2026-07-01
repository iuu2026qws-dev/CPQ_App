package org.dromara.cpq.crm.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.crm.domain.bo.CpqCrmActivityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmActivityVo;
import org.dromara.cpq.crm.service.ICpqCrmActivityService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;

/**
 * 销售活动 Controller（简单 CRUD）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/crm/activity")
public class CpqCrmActivityController extends BaseController {

    private final ICpqCrmActivityService activityService;

    /** 分页查询销售活动列表（可按商机ID筛选） */
    @GetMapping("/list")
    public TableDataInfo<CpqCrmActivityVo> list(CpqCrmActivityBo bo, PageQuery pageQuery) {
        return activityService.queryPageList(bo, pageQuery);
    }

    /** 获取销售活动详情 */
    @GetMapping("/{id}")
    public R<CpqCrmActivityVo> getById(@PathVariable Long id) {
        return R.ok(activityService.queryById(id));
    }

    /** 新增销售活动 */
    @Log(title = "销售活动管理", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@RequestBody CpqCrmActivityBo bo) {
        return toAjax(activityService.insertByBo(bo));
    }

    /** 更新销售活动 */
    @Log(title = "销售活动管理", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@RequestBody CpqCrmActivityBo bo) {
        return toAjax(activityService.updateByBo(bo));
    }

    /** 删除销售活动 */
    @Log(title = "销售活动管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(activityService.deleteWithValidByIds(Arrays.asList(ids)));
    }
}
