package org.dromara.cpq.quote.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.cpq.quote.domain.bo.CpqQuoteTemplateBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteTemplateVo;
import org.dromara.cpq.quote.domain.vo.TemplateFieldVo;
import org.dromara.cpq.quote.service.ICpqQuoteTemplateService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 报价模板管理 Controller
 * <p>
 * 提供模板 CRUD、模板设计器字段库、模板设计保存、预览和默认设置等接口。
 * 模板设计器使用 drag-drop 方式编排报价单的布局和字段绑定。
 * </p>
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/quote/template")
public class CpqQuoteTemplateController extends BaseController {
    private final ICpqQuoteTemplateService templateService;

    /** 查询模板列表（分页） */
    @GetMapping("/list")
    public TableDataInfo<CpqQuoteTemplateVo> list(CpqQuoteTemplateBo bo, PageQuery pageQuery) {
        return templateService.selectPageList(bo, pageQuery);
    }

    /** 获取模板详情（含 template_json 设计配置） */
    @GetMapping("/{templateId}")
    public R<CpqQuoteTemplateVo> getInfo(@PathVariable Long templateId) {
        return R.ok(templateService.selectById(templateId));
    }

    /** 新增模板 */
    @PostMapping
    public R<Void> add(@RequestBody CpqQuoteTemplateBo bo) {
        return toAjax(templateService.insert(bo));
    }

    /** 修改模板基本信息 */
    @PutMapping
    public R<Void> edit(@RequestBody CpqQuoteTemplateBo bo) {
        return toAjax(templateService.update(bo));
    }

    /** 删除模板 */
    @DeleteMapping("/{templateId}")
    public R<Void> remove(@PathVariable Long templateId) {
        return toAjax(templateService.deleteById(templateId));
    }

    /** 批量删除模板 */
    @DeleteMapping("/batch")
    public R<Void> removeBatch(@RequestBody Long[] templateIds) {
        return toAjax(templateService.deleteByIds(templateIds));
    }

    /** 获取模板字段库 — 报价模板设计器可用字段列表 */
    @GetMapping("/fields")
    public R<List<TemplateFieldVo>> getFieldLibrary() {
        return R.ok(templateService.getFieldLibrary());
    }

    /** 保存模板设计配置 — 存储 template_json 设计数据 */
    @PutMapping("/{templateId}/design")
    public R<Void> saveDesign(@PathVariable Long templateId, @RequestBody Map<String, String> body) {
        String templateJson = body.get("templateJson");
        return toAjax(templateService.saveDesign(templateId, templateJson));
    }

    /** 生成模板预览 HTML — STANDARD 类型用，返回填充了 mock 数据的完整 HTML */
    @GetMapping("/{templateId}/preview")
    public R<String> preview(@PathVariable Long templateId) {
        String html = templateService.generatePreview(templateId);
        return R.ok("操作成功", html);
    }

    /** 生成模板预览文件 — PDF/WORD 类型用，返回对应格式文件下载 */
    @GetMapping("/{templateId}/preview/file")
    public void previewFile(@PathVariable Long templateId, HttpServletResponse response) {
        try {
            CpqQuoteTemplateVo tpl = templateService.selectById(templateId);
            String type = tpl != null ? tpl.getTemplateType() : "STANDARD";
            String name = tpl != null ? tpl.getTemplateName() : "template";

            byte[] bytes;
            String contentType;
            String filename;

            if ("PDF".equalsIgnoreCase(type)) {
                bytes = templateService.generatePreviewPdf(templateId);
                contentType = "application/pdf";
                filename = URLEncoder.encode(name + "_预览.pdf", StandardCharsets.UTF_8);
            } else if ("WORD".equalsIgnoreCase(type)) {
                bytes = templateService.generatePreviewWord(templateId);
                contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                filename = URLEncoder.encode(name + "_预览.docx", StandardCharsets.UTF_8);
            } else if ("EXCEL".equalsIgnoreCase(type)) {
                bytes = templateService.generatePreviewExcel(templateId);
                contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                filename = URLEncoder.encode(name + "_预览.xlsx", StandardCharsets.UTF_8);
            } else {
                // STANDARD 或其他类型降级返回 HTML
                String html = templateService.generatePreview(templateId);
                bytes = html.getBytes(StandardCharsets.UTF_8);
                contentType = "text/html;charset=UTF-8";
                filename = URLEncoder.encode(name + "_预览.html", StandardCharsets.UTF_8);
            }

            response.setContentType(contentType);
            response.setHeader("Content-Disposition", "attachment; filename=" + filename);
            try (OutputStream os = response.getOutputStream()) {
                os.write(bytes);
            }
        } catch (Exception e) {
            throw new RuntimeException("生成预览文件失败: " + e.getMessage(), e);
        }
    }

    /** 设为默认模板 — 同类型其他模板的默认标记会被取消 */
    @PutMapping("/{templateId}/default")
    public R<Void> setDefault(@PathVariable Long templateId) {
        return toAjax(templateService.setDefault(templateId));
    }
}
