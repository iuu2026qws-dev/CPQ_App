package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.*;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteTemplate;
import org.dromara.cpq.quote.domain.bo.CpqQuoteTemplateBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteTemplateVo;
import org.dromara.cpq.quote.domain.vo.TemplateFieldVo;
import org.dromara.cpq.quote.mapper.CpqQuoteTemplateMapper;
import org.dromara.cpq.quote.service.ICpqQuoteTemplateService;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.util.*;

@Slf4j
@RequiredArgsConstructor
@Service
public class CpqQuoteTemplateServiceImpl extends ServiceImpl<CpqQuoteTemplateMapper, CpqQuoteTemplate> implements ICpqQuoteTemplateService {
    @Override public CpqQuoteTemplateVo selectById(Long id) { return BeanUtil.toBean(getById(id), CpqQuoteTemplateVo.class); }
    @Override public List<CpqQuoteTemplateVo> selectList(CpqQuoteTemplateBo bo) {
        LambdaQueryWrapper<CpqQuoteTemplate> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.isNotBlank(bo.getTemplateName()), CpqQuoteTemplate::getTemplateName, bo.getTemplateName());
        qw.eq(StringUtils.isNotBlank(bo.getTemplateType()), CpqQuoteTemplate::getTemplateType, bo.getTemplateType());
        return BeanUtil.copyToList(list(qw), CpqQuoteTemplateVo.class);
    }
    @Override public TableDataInfo<CpqQuoteTemplateVo> selectPageList(CpqQuoteTemplateBo bo, PageQuery pageQuery) { return TableDataInfo.build(BeanUtil.copyToList(page(pageQuery.build()).getRecords(), CpqQuoteTemplateVo.class)); }
    @Override @Transactional public int insert(CpqQuoteTemplateBo bo) { return save(BeanUtil.toBean(bo, CpqQuoteTemplate.class)) ? 1 : 0; }
    @Override @Transactional public int update(CpqQuoteTemplateBo bo) { return updateById(BeanUtil.toBean(bo, CpqQuoteTemplate.class)) ? 1 : 0; }
    @Override @Transactional public int deleteById(Long id) { return removeById(id) ? 1 : 0; }
    @Override @Transactional public int deleteByIds(Long[] ids) { return removeByIds(Arrays.asList(ids)) ? 1 : 0; }

    @Override
    public List<TemplateFieldVo> getFieldLibrary() {
        log.info("getFieldLibrary: 获取报价模板字段库");
        List<TemplateFieldVo> result = new ArrayList<>();

        // 报价单头部字段
        result.add(new TemplateFieldVo()
            .setCategory("quote")
            .setCategoryLabel("报价单信息")
            .setFields(Arrays.asList(
                new TemplateFieldVo.FieldItem().setBindField("quote.quoteNumber").setLabel("报价编号").setFieldType("text").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.quoteType").setLabel("报价类型").setFieldType("text").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.accountName").setLabel("客户名称").setFieldType("text").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.currency").setLabel("币种").setFieldType("text").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.status").setLabel("状态").setFieldType("text").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.createTime").setLabel("创建时间").setFieldType("date").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.validUntil").setLabel("有效期至").setFieldType("date").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.discountRate").setLabel("折扣率").setFieldType("number").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.grandTotal").setLabel("总金额").setFieldType("currency").setScope("header"),
                new TemplateFieldVo.FieldItem().setBindField("quote.remark").setLabel("备注").setFieldType("text").setScope("header")
            )));

        // 行项目字段
        result.add(new TemplateFieldVo()
            .setCategory("line")
            .setCategoryLabel("行项目明细")
            .setFields(Arrays.asList(
                new TemplateFieldVo.FieldItem().setBindField("line.index").setLabel("序号").setFieldType("number").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.itemCode").setLabel("产品编码").setFieldType("text").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.itemName").setLabel("产品名称").setFieldType("text").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.itemType").setLabel("类型").setFieldType("text").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.quantity").setLabel("数量").setFieldType("number").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.unit").setLabel("单位").setFieldType("text").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.unitPrice").setLabel("单价").setFieldType("currency").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.discountPct").setLabel("折扣(%)").setFieldType("number").setScope("line"),
                new TemplateFieldVo.FieldItem().setBindField("line.lineTotal").setLabel("小计").setFieldType("currency").setScope("line")
            )));

        // 汇总字段
        result.add(new TemplateFieldVo()
            .setCategory("summary")
            .setCategoryLabel("价格汇总")
            .setFields(Arrays.asList(
                new TemplateFieldVo.FieldItem().setBindField("summary.subtotal").setLabel("小计").setFieldType("currency").setScope("summary"),
                new TemplateFieldVo.FieldItem().setBindField("summary.discount").setLabel("折扣总额").setFieldType("currency").setScope("summary"),
                new TemplateFieldVo.FieldItem().setBindField("summary.grandTotal").setLabel("总金额").setFieldType("currency").setScope("summary"),
                new TemplateFieldVo.FieldItem().setBindField("summary.lineCount").setLabel("行项目数").setFieldType("number").setScope("summary")
            )));

        log.info("getFieldLibrary: 返回 {} 个分类", result.size());
        return result;
    }

    @Override
    @Transactional
    public int saveDesign(Long templateId, String templateJson) {
        log.info("saveDesign: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuoteTemplate entity = getById(templateId);
            if (entity == null) {
                log.warn("saveDesign: 模板不存在 templateId={}", templateId);
                return 0;
            }
            entity.setTemplateJson(templateJson);
            int result = updateById(entity) ? 1 : 0;
            log.info("saveDesign 完成: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime);
            return result;
        } catch (Exception e) {
            log.error("saveDesign 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw e;
        }
    }

    // ======================== 预览/导出核心逻辑（全部基于 templateJson 设计布局） ========================

    @Override
    public String generatePreview(Long templateId) {
        log.info("generatePreview: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuoteTemplate template = getById(templateId);
            if (template == null) {
                log.warn("generatePreview: 模板不存在 templateId={}", templateId);
                return "";
            }
            // 优先使用 templateJson（设计器布局）；无布局时降级到旧 templateContent
            String html;
            if (StrUtil.isNotBlank(template.getTemplateJson())) {
                html = renderLayoutHtml(template.getTemplateJson(), template.getTemplateName());
            } else if (StrUtil.isNotBlank(template.getTemplateContent())) {
                // 兼容旧模板（仅 templateContent，无设计布局）
                html = legacyPlaceholderFill(template.getTemplateContent());
            } else {
                html = renderDefaultHtml();
            }
            log.info("generatePreview 完成: templateId={}, 内容长度={}, 耗时={}ms",
                templateId, html.length(), System.currentTimeMillis() - startTime);
            return html;
        } catch (Exception e) {
            log.error("generatePreview 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw e;
        }
    }

    @Override
    public byte[] generatePreviewPdf(Long templateId) {
        log.info("generatePreviewPdf: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            String html = generatePreview(templateId);
            if (StrUtil.isBlank(html)) {
                log.warn("generatePreviewPdf: HTML 为空");
                return new byte[0];
            }
            try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                PdfRendererBuilder builder = new PdfRendererBuilder();
                builder.useFastMode();
                builder.withHtmlContent(html, null);
                builder.toStream(baos);
                builder.run();
                byte[] pdfBytes = baos.toByteArray();
                log.info("generatePreviewPdf 完成: templateId={}, 大小={} bytes, 耗时={}ms",
                    templateId, pdfBytes.length, System.currentTimeMillis() - startTime);
                return pdfBytes;
            }
        } catch (Exception e) {
            log.error("generatePreviewPdf 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw new RuntimeException("生成预览PDF失败: " + e.getMessage(), e);
        }
    }

    @Override
    public byte[] generatePreviewWord(Long templateId) {
        log.info("generatePreviewWord: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuoteTemplate template = getById(templateId);
            String templateName = template != null ? template.getTemplateName() : "报价模板";
            String json = template != null ? template.getTemplateJson() : null;
            String primaryColor = "#409EFF";
            String companyName = "Smart CPQ";
            String footerText = "";

            if (StrUtil.isNotBlank(json)) {
                JSONObject root = JSON.parseObject(json);
                JSONObject ps = root.getJSONObject("pageSettings");
                if (ps != null) {
                    primaryColor = ps.getString("primaryColor") != null ? ps.getString("primaryColor") : primaryColor;
                    companyName = ps.getString("companyName") != null ? ps.getString("companyName") : companyName;
                    footerText = ps.getString("footerText") != null ? ps.getString("footerText") : "本报价单由 CPQ 系统生成";
                }
            }

            try (XWPFDocument doc = new XWPFDocument();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

                // 标题
                XWPFParagraph titlePara = doc.createParagraph();
                titlePara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun titleRun = titlePara.createRun();
                titleRun.setText(companyName + " — 报价单（预览）");
                titleRun.setBold(true); titleRun.setFontSize(22); titleRun.setFontFamily("Microsoft YaHei");

                XWPFParagraph metaPara = doc.createParagraph();
                metaPara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun metaRun = metaPara.createRun();
                metaRun.setText("模板: " + templateName + "    日期: " + DateUtil.format(new Date(), "yyyy-MM-dd HH:mm"));
                metaRun.setFontSize(11); metaRun.setColor("666666");
                wordParaSpacing(metaPara, 0, 200, 200);

                if (StrUtil.isNotBlank(json)) {
                    buildWordFromLayout(doc, json);
                } else {
                    buildWordFallback(doc);
                }

                // 页脚
                if (StrUtil.isNotBlank(footerText)) {
                    XWPFParagraph footer = doc.createParagraph();
                    footer.setAlignment(ParagraphAlignment.CENTER);
                    XWPFRun footerRun = footer.createRun();
                    footerRun.setText(footerText);
                    footerRun.setFontSize(10); footerRun.setColor("999999");
                    wordParaSpacing(footer, 400, 0, 0);
                }

                doc.write(baos);
                byte[] wordBytes = baos.toByteArray();
                log.info("generatePreviewWord 完成: templateId={}, 大小={} bytes, 耗时={}ms",
                    templateId, wordBytes.length, System.currentTimeMillis() - startTime);
                return wordBytes;
            }
        } catch (Exception e) {
            log.error("generatePreviewWord 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw new RuntimeException("生成预览Word失败: " + e.getMessage(), e);
        }
    }

    @Override
    public byte[] generatePreviewExcel(Long templateId) {
        log.info("generatePreviewExcel: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuoteTemplate template = getById(templateId);
            if (template == null) {
                log.warn("generatePreviewExcel: 模板不存在 templateId={}", templateId);
                return new byte[0];
            }

            try (XSSFWorkbook wb = new XSSFWorkbook();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

                if (StrUtil.isNotBlank(template.getTemplateJson())) {
                    buildExcelFromLayout(wb, template.getTemplateJson());
                } else {
                    CellStyle hs = wb.createCellStyle();
                    Font hf = wb.createFont(); hf.setBold(true);
                    hs.setFont(hf);
                    hs.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex());
                    hs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
                    CellStyle ds = wb.createCellStyle();
                    buildExcelFallback(wb, hs, ds);
                }

                wb.write(baos);
                byte[] excelBytes = baos.toByteArray();
                log.info("generatePreviewExcel 完成: templateId={}, 大小={} bytes, 耗时={}ms",
                    templateId, excelBytes.length, System.currentTimeMillis() - startTime);
                return excelBytes;
            }
        } catch (Exception e) {
            log.error("generatePreviewExcel 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw new RuntimeException("生成预览Excel失败: " + e.getMessage(), e);
        }
    }

    // ======================== 核心：templateJson 布局 → HTML 渲染 ========================

    /**
     * 将设计器布局 JSON 渲染为完整的 HTML 文档（填充静态模拟数据）
     * @param templateJson 设计器保存的 JSON（包含 sections + pageSettings）
     * @param templateName 模板名称
     */
    private String renderLayoutHtml(String templateJson, String templateName) {
        JSONObject root = JSON.parseObject(templateJson);
        JSONArray sections = root.getJSONArray("sections");
        JSONObject pageSettings = root.getJSONObject("pageSettings");

        String companyName = "Smart CPQ";
        String footerText = "本报价单由 Smart CPQ 系统自动生成";
        String primaryColor = "#409EFF";

        if (pageSettings != null) {
            companyName = pageSettings.getString("companyName") != null ? pageSettings.getString("companyName") : companyName;
            footerText = pageSettings.getString("footerText") != null ? pageSettings.getString("footerText") : footerText;
            primaryColor = pageSettings.getString("primaryColor") != null ? pageSettings.getString("primaryColor") : primaryColor;
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html>\n<html lang=\"zh-CN\">\n<head>\n<meta charset=\"UTF-8\">\n");
        sb.append("<title>").append(templateName).append(" — 预览</title>\n");
        sb.append("<style>\n");
        sb.append("*{margin:0;padding:0;box-sizing:border-box}\n");
        sb.append("body{font-family:'Microsoft YaHei','PingFang SC',sans-serif;padding:40px 50px;color:#303133;font-size:13px}\n");
        sb.append(".company-header{text-align:center;margin-bottom:24px}\n");
        sb.append(".company-header h1{font-size:22px;color:").append(primaryColor).append(";margin-bottom:4px}\n");
        sb.append(".company-header .subtitle{font-size:16px;color:#909399}\n");
        sb.append(".company-header .meta{font-size:12px;color:#c0c4cc;margin-top:6px}\n");
        sb.append(".section{margin-bottom:28px}\n");
        sb.append(".section-title{font-size:15px;font-weight:600;color:#303133;border-bottom:2px solid ").append(primaryColor).append(";padding-bottom:6px;margin-bottom:12px}\n");
        // Grid 样式
        sb.append(".grid-section{display:grid;gap:0;border:1px solid #e4e7ed;border-radius:4px;overflow:hidden}\n");
        sb.append(".grid-field{display:flex;border-bottom:1px solid #ebeef5;min-height:38px}\n");
        sb.append(".grid-field:nth-last-child(-n+2){border-bottom:none}\n");
        sb.append(".grid-field .field-label{width:130px;background:#f5f7fa;padding:8px 14px;font-weight:500;font-size:12.5px;color:#606266;flex-shrink:0;border-right:1px solid #ebeef5;display:flex;align-items:center}\n");
        sb.append(".grid-field .field-value{padding:8px 14px;font-size:13px;color:#303133;display:flex;align-items:center}\n");
        // Table 样式
        sb.append(".table-section{width:100%;border-collapse:collapse}\n");
        sb.append(".table-section th{background:").append(primaryColor).append(";color:#fff;padding:9px 12px;font-size:12.5px;text-align:center;font-weight:500}\n");
        sb.append(".table-section td{padding:8px 12px;border:1px solid #e4e7ed;text-align:center;font-size:12.5px}\n");
        sb.append(".table-section tr:nth-child(even) td{background:#fafafa}\n");
        // Summary 样式
        sb.append(".summary-section{text-align:right}\n");
        sb.append(".summary-section table{float:right;border-collapse:collapse}\n");
        sb.append(".summary-section td{padding:6px 24px;border:1px solid #e4e7ed;font-size:13px}\n");
        sb.append(".summary-section .sum-label{text-align:right;font-weight:500;background:#f5f7fa}\n");
        sb.append(".summary-section .sum-total{font-weight:700;font-size:15px;color:").append(primaryColor).append("}\n");
        // Footer
        sb.append(".footer{margin-top:50px;padding-top:16px;border-top:1px solid #e4e7ed;text-align:center;font-size:11px;color:#c0c4cc}\n");
        sb.append("</style>\n</head>\n<body>\n");

        // 公司抬头
        sb.append("<div class=\"company-header\">\n");
        sb.append("  <h1>").append(companyName).append("</h1>\n");
        sb.append("  <div class=\"subtitle\">报价单（预览）</div>\n");
        sb.append("  <div class=\"meta\">模板: ").append(templateName)
          .append(" &nbsp;|&nbsp; 生成时间: ").append(DateUtil.format(new Date(), "yyyy-MM-dd HH:mm:ss")).append("</div>\n");
        sb.append("</div>\n");

        // 渲染每个 Section
        if (sections != null && !sections.isEmpty()) {
            for (int i = 0; i < sections.size(); i++) {
                JSONObject sec = sections.getJSONObject(i);
                String type = sec.getString("type");
                String label = sec.getString("label");
                JSONArray fields = sec.getJSONArray("fields");

                if (fields == null || fields.isEmpty()) continue;

                sb.append("<div class=\"section\">\n");
                sb.append("  <div class=\"section-title\">").append(label).append("</div>\n");

                if ("grid".equals(type)) {
                    renderGridHtml(sb, sec, fields);
                } else if ("table".equals(type)) {
                    renderTableHtml(sb, fields);
                } else if ("summary".equals(type)) {
                    renderSummaryHtml(sb, fields);
                }
                sb.append("</div>\n");
            }
        }

        sb.append("<div class=\"footer\"><p>").append(footerText).append("</p></div>\n");
        sb.append("</body>\n</html>");

        return sb.toString();
    }

    /** 渲染 grid 类型区域 → CSS Grid 的键值对展示 */
    private void renderGridHtml(StringBuilder sb, JSONObject sec, JSONArray fields) {
        int columns = sec.getIntValue("columns");
        if (columns < 1) columns = 2;

        sb.append("<div class=\"grid-section\" style=\"grid-template-columns:repeat(").append(columns).append(",1fr)\">\n");
        for (int i = 0; i < fields.size(); i++) {
            JSONObject f = fields.getJSONObject(i);
            String bindField = f.getString("bindField");
            String fieldLabel = f.getString("label");
            int colSpan = f.getIntValue("colSpan");
            if (colSpan < 1) colSpan = 1;
            String style = colSpan > 1 ? " style=\"grid-column:span " + colSpan + "\"" : "";

            sb.append("  <div class=\"grid-field\"").append(style).append(">\n");
            sb.append("    <div class=\"field-label\">").append(fieldLabel).append("</div>\n");
            sb.append("    <div class=\"field-value\">").append(getMockValue(bindField)).append("</div>\n");
            sb.append("  </div>\n");
        }
        sb.append("</div>\n");
    }

    /** 渲染 table 类型区域 → HTML 表格（含模拟行数据） */
    private void renderTableHtml(StringBuilder sb, JSONArray fields) {
        sb.append("<table class=\"table-section\"><thead><tr>\n");
        for (int i = 0; i < fields.size(); i++) {
            JSONObject f = fields.getJSONObject(i);
            sb.append("<th>").append(f.getString("label")).append("</th>\n");
        }
        sb.append("</tr></thead><tbody>\n");
        // 模拟 2 行数据
        List<Map<String, String>> mockLines = getMockLineData();
        for (Map<String, String> line : mockLines) {
            sb.append("<tr>");
            for (int i = 0; i < fields.size(); i++) {
                JSONObject f = fields.getJSONObject(i);
                String val = line.getOrDefault(f.getString("bindField"), "--");
                sb.append("<td>").append(val).append("</td>");
            }
            sb.append("</tr>\n");
        }
        sb.append("</tbody></table>\n");
    }

    /** 渲染 summary 类型区域 → 右对齐汇总表 */
    private void renderSummaryHtml(StringBuilder sb, JSONArray fields) {
        sb.append("<div class=\"summary-section\"><table>\n");
        for (int i = 0; i < fields.size(); i++) {
            JSONObject f = fields.getJSONObject(i);
            boolean isTotal = "summary.grandTotal".equals(f.getString("bindField"));
            sb.append("<tr>");
            sb.append("<td class=\"sum-label\">").append(f.getString("label")).append("</td>");
            sb.append("<td class=\"").append(isTotal ? "sum-total" : "").append("\">").append(getMockValue(f.getString("bindField"))).append("</td>");
            sb.append("</tr>\n");
        }
        sb.append("</table></div>\n<div style=\"clear:both\"></div>\n");
    }

    // ======================== 模拟数据 ========================

    /** 根据 bindField 返回模拟静态值 */
    private String getMockValue(String bindField) {
        switch (bindField) {
            case "quote.quoteNumber": return "QT-2026-0001";
            case "quote.quoteType": return "标准报价";
            case "quote.accountName": return "示例客户公司";
            case "quote.currency": return "CNY";
            case "quote.status": return "草稿";
            case "quote.createTime": return DateUtil.format(new Date(), "yyyy-MM-dd HH:mm");
            case "quote.validUntil": return "2026-07-13";
            case "quote.discountRate": return "0.00%";
            case "quote.grandTotal": return "158,000.00";
            case "quote.remark": return "示例备注信息";
            case "summary.subtotal": return "158,000.00";
            case "summary.discount": return "0.00";
            case "summary.grandTotal": return "158,000.00 CNY";
            case "summary.lineCount": return "2 项";
            default:
                // 未映射的字段返回占位提示
                if (bindField != null && bindField.startsWith("line.")) return "--";
                return "--";
        }
    }

    /** 模拟两行行项目数据 */
    private List<Map<String, String>> getMockLineData() {
        List<Map<String, String>> list = new ArrayList<>();

        Map<String, String> line1 = new LinkedHashMap<>();
        line1.put("line.index", "1");
        line1.put("line.itemCode", "ARC-200P");
        line1.put("line.itemName", "弧焊机器人主机");
        line1.put("line.itemType", "成品");
        line1.put("line.quantity", "1");
        line1.put("line.unit", "台");
        line1.put("line.unitPrice", "120,000.00");
        line1.put("line.discountPct", "0.00%");
        line1.put("line.lineTotal", "120,000.00");
        list.add(line1);

        Map<String, String> line2 = new LinkedHashMap<>();
        line2.put("line.index", "2");
        line2.put("line.itemCode", "LWS-300");
        line2.put("line.itemName", "激光焊缝跟踪系统");
        line2.put("line.itemType", "附件");
        line2.put("line.quantity", "1");
        line2.put("line.unit", "套");
        line2.put("line.unitPrice", "38,000.00");
        line2.put("line.discountPct", "0.00%");
        line2.put("line.lineTotal", "38,000.00");
        list.add(line2);

        return list;
    }

    // ======================== Word：基于 templateJson 布局生成 ========================

    private void buildWordFromLayout(XWPFDocument doc, String templateJson) {
        JSONObject root = JSON.parseObject(templateJson);
        JSONArray sections = root.getJSONArray("sections");

        if (sections == null || sections.isEmpty()) {
            buildWordFallback(doc);
            return;
        }

        for (int i = 0; i < sections.size(); i++) {
            JSONObject sec = sections.getJSONObject(i);
            String type = sec.getString("type");
            String label = sec.getString("label");
            JSONArray fields = sec.getJSONArray("fields");
            if (fields == null || fields.isEmpty()) continue;

            // 区域标题
            XWPFParagraph secTitle = doc.createParagraph();
            XWPFRun secTitleRun = secTitle.createRun();
            secTitleRun.setText(label);
            secTitleRun.setBold(true); secTitleRun.setFontSize(14);
            wordParaSpacing(secTitle, 200, 100, 0);

            int columns = sec.getIntValue("columns");
            if (columns < 1) columns = 2;

            if ("grid".equals(type)) {
                int rows = (int) Math.ceil((double) fields.size() / columns);
                // 每个 grid field 占 2 列（label + value），总共 2*columns 列
                XWPFTable table = doc.createTable(rows, columns * 2);
                setWordTableBorders(table);
                for (int r = 0; r < rows; r++) {
                    for (int c = 0; c < columns; c++) {
                        int idx = r * columns + c;
                        if (idx < fields.size()) {
                            JSONObject f = fields.getJSONObject(idx);
                            fillWordCell(table, r, c * 2, f.getString("label"), true);
                            fillWordCell(table, r, c * 2 + 1, getMockValue(f.getString("bindField")), false);
                        } else {
                            fillWordCell(table, r, c * 2, "", false);
                            fillWordCell(table, r, c * 2 + 1, "", false);
                        }
                    }
                }
            } else if ("table".equals(type)) {
                List<Map<String, String>> mockLines = getMockLineData();
                XWPFTable table = doc.createTable(mockLines.size() + 1, fields.size());
                setWordTableBorders(table);
                // 表头
                for (int j = 0; j < fields.size(); j++) {
                    fillWordCell(table, 0, j, fields.getJSONObject(j).getString("label"), true);
                }
                // 数据行
                for (int r = 0; r < mockLines.size(); r++) {
                    Map<String, String> line = mockLines.get(r);
                    for (int j = 0; j < fields.size(); j++) {
                        String val = line.getOrDefault(fields.getJSONObject(j).getString("bindField"), "--");
                        fillWordCell(table, r + 1, j, val, false);
                    }
                }
            } else if ("summary".equals(type)) {
                for (int j = 0; j < fields.size(); j++) {
                    JSONObject f = fields.getJSONObject(j);
                    XWPFParagraph p = doc.createParagraph();
                    p.setAlignment(ParagraphAlignment.RIGHT);
                    XWPFRun lr = p.createRun(); lr.setText(f.getString("label") + ": "); lr.setFontSize(11);
                    XWPFRun vr = p.createRun(); vr.setText(getMockValue(f.getString("bindField"))); vr.setBold(true); vr.setFontSize(11);
                    boolean isTotal = "summary.grandTotal".equals(f.getString("bindField"));
                    if (isTotal) { vr.setFontSize(14); vr.setColor("E6A23C"); }
                    wordParaSpacing(p, 0, 60, 0);
                }
            }
            wordParaSpacing(secTitle, 0, 0, 0); // 末尾间距（由下一个 section title 的段前间距撑开）
        }
    }

    /** Word 后备方案（无 templateJson 时） */
    private void buildWordFallback(XWPFDocument doc) {
        // 信息表格
        XWPFTable infoTable = doc.createTable(3, 4);
        setWordTableBorders(infoTable);
        fillWordCell(infoTable, 0, 0, "客户名称", true);
        fillWordCell(infoTable, 0, 1, "示例客户公司", false);
        fillWordCell(infoTable, 0, 2, "报价类型", true);
        fillWordCell(infoTable, 0, 3, "标准报价", false);
        fillWordCell(infoTable, 1, 0, "币种", true);
        fillWordCell(infoTable, 1, 1, "CNY", false);
        fillWordCell(infoTable, 1, 2, "有效期至", true);
        fillWordCell(infoTable, 1, 3, "2026-07-13", false);
        fillWordCell(infoTable, 2, 0, "折扣率", true);
        fillWordCell(infoTable, 2, 1, "0.00%", false);
        fillWordCell(infoTable, 2, 2, "状态", true);
        fillWordCell(infoTable, 2, 3, "草稿", false);
        doc.createParagraph();

        // 行项目标题
        XWPFParagraph itemsTitle = doc.createParagraph();
        XWPFRun itRun = itemsTitle.createRun();
        itRun.setText("行项目明细"); itRun.setBold(true); itRun.setFontSize(14);
        wordParaSpacing(itemsTitle, 0, 200, 100);

        // 行项目表格
        String[] headers = {"序号", "产品名称", "类型", "数量", "单价", "折扣(%)", "小计"};
        XWPFTable itemsTable = doc.createTable(3, headers.length);
        setWordTableBorders(itemsTable);
        for (int i = 0; i < headers.length; i++) fillWordCell(itemsTable, 0, i, headers[i], true);
        fillWordCell(itemsTable, 1, 0, "1", false); fillWordCell(itemsTable, 1, 1, "ARC-200P 弧焊机器人主机", false);
        fillWordCell(itemsTable, 1, 2, "成品", false); fillWordCell(itemsTable, 1, 3, "1", false);
        fillWordCell(itemsTable, 1, 4, "120,000.00", false); fillWordCell(itemsTable, 1, 5, "0.00%", false);
        fillWordCell(itemsTable, 1, 6, "120,000.00", false);
        fillWordCell(itemsTable, 2, 0, "2", false); fillWordCell(itemsTable, 2, 1, "激光焊缝跟踪系统", false);
        fillWordCell(itemsTable, 2, 2, "附件", false); fillWordCell(itemsTable, 2, 3, "1", false);
        fillWordCell(itemsTable, 2, 4, "38,000.00", false); fillWordCell(itemsTable, 2, 5, "0.00%", false);
        fillWordCell(itemsTable, 2, 6, "38,000.00", false);

        // 汇总
        doc.createParagraph();
        XWPFParagraph sp = doc.createParagraph(); sp.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun sl = sp.createRun(); sl.setText("小计: "); sl.setFontSize(11);
        XWPFRun sv = sp.createRun(); sv.setText("158,000.00"); sv.setBold(true); sv.setFontSize(11);
        wordParaSpacing(sp, 0, 60, 0);

        XWPFParagraph tp = doc.createParagraph(); tp.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun tl = tp.createRun(); tl.setText("合计: "); tl.setBold(true); tl.setFontSize(14);
        XWPFRun tv = tp.createRun(); tv.setText("158,000.00 CNY"); tv.setBold(true); tv.setFontSize(14);
        tv.setColor("E6A23C");
        wordParaSpacing(tp, 0, 60, 0);
    }

    // ======================== Excel：基于 templateJson 布局生成 ========================

    private void buildExcelFromLayout(XSSFWorkbook wb, String templateJson) {
        JSONObject root = JSON.parseObject(templateJson);
        JSONArray sections = root.getJSONArray("sections");

        CellStyle headerStyle = wb.createCellStyle();
        Font headerFont = wb.createFont(); headerFont.setBold(true); headerFont.setFontHeightInPoints((short) 11);
        headerStyle.setFont(headerFont);
        headerStyle.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setBorderBottom(BorderStyle.THIN);
        headerStyle.setBorderTop(BorderStyle.THIN);
        headerStyle.setBorderLeft(BorderStyle.THIN);
        headerStyle.setBorderRight(BorderStyle.THIN);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);

        CellStyle dataStyle = wb.createCellStyle();
        dataStyle.setBorderBottom(BorderStyle.THIN);
        dataStyle.setBorderTop(BorderStyle.THIN);
        dataStyle.setBorderLeft(BorderStyle.THIN);
        dataStyle.setBorderRight(BorderStyle.THIN);
        dataStyle.setAlignment(HorizontalAlignment.CENTER);

        CellStyle labelStyle = wb.createCellStyle();
        labelStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        labelStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        labelStyle.setBorderBottom(BorderStyle.THIN);
        labelStyle.setBorderTop(BorderStyle.THIN);
        labelStyle.setBorderLeft(BorderStyle.THIN);
        labelStyle.setBorderRight(BorderStyle.THIN);
        Font labelFont = wb.createFont(); labelFont.setBold(true);
        labelStyle.setFont(labelFont);

        if (sections == null || sections.isEmpty()) {
            buildExcelFallback(wb, headerStyle, dataStyle);
            return;
        }

        for (int i = 0; i < sections.size(); i++) {
            JSONObject sec = sections.getJSONObject(i);
            String type = sec.getString("type");
            String label = sec.getString("label");
            JSONArray fields = sec.getJSONArray("fields");
            if (fields == null || fields.isEmpty()) continue;

            Sheet sheet = wb.createSheet(label);
            int rowIdx = 0;

            if ("grid".equals(type)) {
                // grid 区域：每组字段占一行（label + value 交替列）
                int columns = sec.getIntValue("columns");
                if (columns < 1) columns = 2;
                int pairsPerRow = columns;
                for (int j = 0; j < fields.size(); j += pairsPerRow) {
                    Row row = sheet.createRow(rowIdx++);
                    int cellIdx = 0;
                    for (int k = 0; k < pairsPerRow && (j + k) < fields.size(); k++) {
                        JSONObject f = fields.getJSONObject(j + k);
                        Cell lc = row.createCell(cellIdx++); lc.setCellValue(f.getString("label")); lc.setCellStyle(labelStyle);
                        Cell vc = row.createCell(cellIdx++); vc.setCellValue(getMockValue(f.getString("bindField"))); vc.setCellStyle(dataStyle);
                    }
                }
            } else if ("table".equals(type)) {
                // 表头
                Row hRow = sheet.createRow(rowIdx++);
                for (int j = 0; j < fields.size(); j++) {
                    Cell c = hRow.createCell(j);
                    c.setCellValue(fields.getJSONObject(j).getString("label"));
                    c.setCellStyle(headerStyle);
                }
                // 模拟行数据
                List<Map<String, String>> mockLines = getMockLineData();
                for (Map<String, String> line : mockLines) {
                    Row dRow = sheet.createRow(rowIdx++);
                    for (int j = 0; j < fields.size(); j++) {
                        String val = line.getOrDefault(fields.getJSONObject(j).getString("bindField"), "--");
                        Cell c = dRow.createCell(j); c.setCellValue(val); c.setCellStyle(dataStyle);
                    }
                }
            } else if ("summary".equals(type)) {
                for (int j = 0; j < fields.size(); j++) {
                    JSONObject f = fields.getJSONObject(j);
                    Row row = sheet.createRow(rowIdx++);
                    Cell lc = row.createCell(0); lc.setCellValue(f.getString("label")); lc.setCellStyle(labelStyle);
                    Cell vc = row.createCell(1); vc.setCellValue(getMockValue(f.getString("bindField"))); vc.setCellStyle(dataStyle);
                }
            }
            // 自动列宽
            for (int c = 0; c < 10; c++) sheet.autoSizeColumn(c);
        }
    }

    private void buildExcelFallback(XSSFWorkbook wb, CellStyle headerStyle, CellStyle dataStyle) {
        Sheet sheet = wb.createSheet("报价单预览");
        int rowIdx = 0;

        // 信息区域
        String[][] info = {{"客户名称", "示例客户公司"}, {"报价类型", "标准报价"}, {"币种", "CNY"}, {"有效期至", "2026-07-13"}};
        CellStyle labelStyle = wb.createCellStyle();
        labelStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        labelStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        Font lf = wb.createFont(); lf.setBold(true);
        labelStyle.setFont(lf);
        for (String[] pair : info) {
            Row r = sheet.createRow(rowIdx++);
            Cell lc = r.createCell(0); lc.setCellValue(pair[0]); lc.setCellStyle(labelStyle);
            Cell vc = r.createCell(1); vc.setCellValue(pair[1]); vc.setCellStyle(dataStyle);
        }
        rowIdx++;

        // 行项目表头
        String[] headers = {"序号", "产品名称", "类型", "数量", "单价", "折扣(%)", "小计"};
        Row hRow = sheet.createRow(rowIdx++);
        for (int i = 0; i < headers.length; i++) {
            Cell c = hRow.createCell(i); c.setCellValue(headers[i]); c.setCellStyle(headerStyle);
        }
        String[][] lines = {{"1", "弧焊机器人主机", "成品", "1", "120,000.00", "0.00%", "120,000.00"}, {"2", "激光焊缝跟踪系统", "附件", "1", "38,000.00", "0.00%", "38,000.00"}};
        for (String[] ld : lines) {
            Row r = sheet.createRow(rowIdx++);
            for (int i = 0; i < ld.length; i++) { Cell c = r.createCell(i); c.setCellValue(ld[i]); c.setCellStyle(dataStyle); }
        }
        for (int c = 0; c < 10; c++) sheet.autoSizeColumn(c);
    }

    // ======================== Word 工具方法 ========================

    private void setWordTableBorders(XWPFTable table) {
        CTTbl ctTbl = table.getCTTbl();
        CTTblPr tblPr = ctTbl.getTblPr() != null ? ctTbl.getTblPr() : ctTbl.addNewTblPr();
        CTTblBorders borders = tblPr.addNewTblBorders();
        borders.addNewTop().setVal(STBorder.SINGLE); borders.getTop().setSz(BigInteger.valueOf(4));
        borders.addNewBottom().setVal(STBorder.SINGLE); borders.getBottom().setSz(BigInteger.valueOf(4));
        borders.addNewLeft().setVal(STBorder.SINGLE); borders.getLeft().setSz(BigInteger.valueOf(4));
        borders.addNewRight().setVal(STBorder.SINGLE); borders.getRight().setSz(BigInteger.valueOf(4));
        borders.addNewInsideH().setVal(STBorder.SINGLE); borders.getInsideH().setSz(BigInteger.valueOf(4));
        borders.addNewInsideV().setVal(STBorder.SINGLE); borders.getInsideV().setSz(BigInteger.valueOf(4));
    }

    private void fillWordCell(XWPFTable table, int row, int col, String text, boolean isHeader) {
        XWPFTableCell cell = table.getRow(row).getCell(col);
        if (cell.getParagraphs().size() > 0) cell.removeParagraph(0);
        XWPFParagraph p = cell.getParagraphs().get(0);
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setText(text == null ? "" : text);
        run.setFontSize(10); run.setFontFamily("Microsoft YaHei");
        if (isHeader) { run.setBold(true); cell.setColor("F5F7FA"); }
    }

    private void wordParaSpacing(XWPFParagraph p, int before, int after, int line) {
        CTP ctp = p.getCTP();
        CTPPr pr = ctp.getPPr() != null ? ctp.getPPr() : ctp.addNewPPr();
        CTSpacing sp = pr.getSpacing() != null ? pr.getSpacing() : pr.addNewSpacing();
        sp.setBefore(BigInteger.valueOf(before));
        sp.setAfter(BigInteger.valueOf(after));
        if (line > 0) sp.setLine(BigInteger.valueOf(line));
    }

    // ======================== 旧模板兼容（无 templateJson 时） ========================

    /** 降级方案：默认 HTML（无任何设计布局时） */
    private String renderDefaultHtml() {
        return "<!DOCTYPE html>\n<html lang=\"zh-CN\">\n<head>\n<meta charset=\"UTF-8\">\n" +
            "<title>报价单预览</title>\n" +
            "<style>body{font-family:'Microsoft YaHei',sans-serif;padding:40px}" +
            ".info-table{width:100%;border-collapse:collapse}" +
            ".info-table td{padding:8px;border:1px solid #ddd}" +
            ".info-table .label{background:#f5f7fa;font-weight:bold}" +
            ".items-table{width:100%;border-collapse:collapse;margin:20px 0}" +
            ".items-table th{background:#409eff;color:#fff;padding:8px}" +
            ".items-table td{padding:8px;border:1px solid #ddd;text-align:center}" +
            "</style>\n</head>\n<body>\n" +
            "<h2 style=\"text-align:center;color:#409eff\">Smart CPQ — 报价单预览</h2>\n" +
            "<table class=\"info-table\">" +
            "<tr><td class=\"label\">客户名称</td><td>示例客户公司</td><td class=\"label\">报价类型</td><td>标准报价</td></tr>" +
            "<tr><td class=\"label\">币种</td><td>CNY</td><td class=\"label\">有效期至</td><td>2026-07-13</td></tr>" +
            "<tr><td class=\"label\">折扣率</td><td>0.00%</td><td class=\"label\">状态</td><td>草稿</td></tr>" +
            "</table>\n" +
            "<h3>行项目明细</h3>\n" +
            "<table class=\"items-table\"><thead><tr><th>序号</th><th>产品名称</th><th>类型</th><th>数量</th><th>单价</th><th>折扣</th><th>小计</th></tr></thead><tbody>" +
            "<tr><td>1</td><td>弧焊机器人主机</td><td>成品</td><td>1</td><td>120,000.00</td><td>0.00%</td><td>120,000.00</td></tr>" +
            "<tr><td>2</td><td>激光焊缝跟踪系统</td><td>附件</td><td>1</td><td>38,000.00</td><td>0.00%</td><td>38,000.00</td></tr>" +
            "</tbody></table>\n" +
            "<p style=\"text-align:right;font-weight:bold\">合计: 158,000.00 CNY</p>\n" +
            "<p style=\"text-align:center;color:#999;margin-top:40px\">本报价单由 Smart CPQ 系统自动生成</p>\n" +
            "</body>\n</html>";
    }

    /** 旧版占位符模板兼容（仅 templateContent，无设计布局） */
    private String legacyPlaceholderFill(String content) {
        Map<String, String> sample = new LinkedHashMap<>();
        sample.put("{{quote.quoteNumber}}", "QT-2026-0001");
        sample.put("{{quote.quoteType}}", "标准报价");
        sample.put("{{quote.accountName}}", "示例客户公司");
        sample.put("{{quote.currency}}", "CNY");
        sample.put("{{quote.status}}", "草稿");
        sample.put("{{quote.createTime}}", DateUtil.format(new Date(), "yyyy-MM-dd HH:mm"));
        sample.put("{{quote.validUntil}}", "2026-07-13");
        sample.put("{{quote.discountRate}}", "0.00%");
        sample.put("{{quote.grandTotal}}", "158,000.00");
        StringBuilder lines = new StringBuilder();
        lines.append("<tr><td>1</td><td>ARC-200P</td><td>弧焊机器人主机</td><td>成品</td><td>1</td><td>120,000.00</td><td>0.00%</td><td>120,000.00</td></tr>");
        lines.append("<tr><td>2</td><td>LWS-300</td><td>激光焊缝跟踪系统</td><td>附件</td><td>1</td><td>38,000.00</td><td>0.00%</td><td>38,000.00</td></tr>");
        sample.put("{{lines.table}}", lines.toString());
        sample.put("{{summary.subtotal}}", "158,000.00");
        sample.put("{{summary.discount}}", "0.00");
        sample.put("{{summary.grandTotal}}", "158,000.00 CNY");
        sample.put("{{summary.lineCount}}", "2 项");
        for (Map.Entry<String, String> e : sample.entrySet()) {
            content = content.replace(e.getKey(), e.getValue());
        }
        return content.replaceAll("\\{\\{[^}]+\\}\\}", "--");
    }

    // ======================== 默认模板 & 业务方法 ========================

    @Override
    @Transactional
    public int setDefault(Long templateId) {
        log.info("setDefault: templateId={}", templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuoteTemplate target = getById(templateId);
            if (target == null) {
                log.warn("setDefault: 模板不存在 templateId={}", templateId);
                return 0;
            }
            LambdaUpdateWrapper<CpqQuoteTemplate> uw = new LambdaUpdateWrapper<>();
            uw.eq(CpqQuoteTemplate::getTemplateType, target.getTemplateType());
            uw.set(CpqQuoteTemplate::getIsDefault, "0");
            update(uw);
            target.setIsDefault("1");
            int result = updateById(target) ? 1 : 0;
            log.info("setDefault 完成: templateId={}, type={}, 耗时={}ms",
                templateId, target.getTemplateType(), System.currentTimeMillis() - startTime);
            return result;
        } catch (Exception e) {
            log.error("setDefault 异常: templateId={}, 耗时={}ms", templateId, System.currentTimeMillis() - startTime, e);
            throw e;
        }
    }
}
