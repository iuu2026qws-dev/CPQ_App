package org.dromara.cpq.controller;

import cn.hutool.core.util.ObjectUtil;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqSystemConfigBo;
import org.dromara.cpq.domain.vo.CpqSystemConfigVo;
import org.dromara.cpq.service.ICpqSystemConfigService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 系统参数管理
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/system/config")
public class CpqSystemConfigController extends BaseController {

    private final ICpqSystemConfigService configService;

    @GetMapping("/list")
    public R<List<CpqSystemConfigVo>> list(CpqSystemConfigBo bo) {
        return R.ok(configService.selectConfigList(bo));
    }

    @GetMapping("/{configId}")
    public R<CpqSystemConfigVo> getInfo(@PathVariable Long configId) {
        return R.ok(configService.selectConfigById(configId));
    }

    @GetMapping("/byKey/{configKey}")
    public R<CpqSystemConfigVo> byKey(@PathVariable String configKey) {
        CpqSystemConfigVo vo = configService.selectConfigByKey(configKey);
        return ObjectUtil.isNotNull(vo) ? R.ok(vo) : R.fail("配置项不存在");
    }

    @Log(title = "CPQ系统参数", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqSystemConfigBo bo) {
        return toAjax(configService.insertConfig(bo));
    }

    @Log(title = "CPQ系统参数", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqSystemConfigBo bo) {
        return toAjax(configService.updateConfig(bo));
    }

    @Log(title = "CPQ系统参数", businessType = BusinessType.DELETE)
    @DeleteMapping("/{configId}")
    public R<Void> remove(@PathVariable Long configId) {
        return toAjax(configService.deleteConfig(configId));
    }
}
