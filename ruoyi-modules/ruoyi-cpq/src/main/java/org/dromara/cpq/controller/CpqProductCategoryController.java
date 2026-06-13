package org.dromara.cpq.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductCategoryBo;
import org.dromara.cpq.domain.vo.CpqProductCategoryVo;
import org.dromara.cpq.service.ICpqProductCategoryService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CPQ 产品分类管理（菜单 50085）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/category")
public class CpqProductCategoryController extends BaseController {

    private final ICpqProductCategoryService categoryService;

    /**
     * 获取分类树形结构
     */
    @GetMapping("/tree")
    public R<List<CpqProductCategoryVo>> tree(CpqProductCategoryBo bo) {
        return R.ok(categoryService.selectCategoryTree(bo));
    }

    /**
     * 获取分类扁平列表
     */
    @GetMapping("/list")
    public R<List<CpqProductCategoryVo>> list(CpqProductCategoryBo bo) {
        return R.ok(categoryService.selectCategoryList(bo));
    }

    /**
     * 按层级查询（1=产品线(L2), 2=产品族(L1), 3=产品系列(L3)）
     */
    @GetMapping("/byLevel/{level}")
    public R<List<CpqProductCategoryVo>> byLevel(@PathVariable Integer level) {
        return R.ok(categoryService.selectCategoryByLevel(level));
    }

    /**
     * 按父分类查询子分类（parentId为空时查L1）
     */
    @GetMapping("/byParent/{parentId}")
    public R<List<CpqProductCategoryVo>> byParent(@PathVariable(required = false) Long parentId) {
        return R.ok(categoryService.selectCategoryByParentId(parentId));
    }

    /**
     * 获取分类详情
     */
    @GetMapping("/{categoryId}")
    public R<CpqProductCategoryVo> getInfo(@PathVariable Long categoryId) {
        return R.ok(categoryService.selectCategoryById(categoryId));
    }

    /**
     * 新增分类
     */
    @Log(title = "CPQ产品分类", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductCategoryBo bo) {
        return toAjax(categoryService.insertCategory(bo));
    }

    /**
     * 修改分类
     */
    @Log(title = "CPQ产品分类", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductCategoryBo bo) {
        return toAjax(categoryService.updateCategory(bo));
    }

    /**
     * 删除分类
     */
    @Log(title = "CPQ产品分类", businessType = BusinessType.DELETE)
    @DeleteMapping("/{categoryId}")
    public R<Void> remove(@PathVariable Long categoryId) {
        return toAjax(categoryService.deleteCategory(categoryId));
    }
}
