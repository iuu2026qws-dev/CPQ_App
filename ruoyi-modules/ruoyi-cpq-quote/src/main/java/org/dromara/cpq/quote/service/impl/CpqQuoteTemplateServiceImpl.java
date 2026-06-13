package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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

            String content;
            if (StrUtil.isNotBlank(template.getTemplateContent())) {
                content = template.getTemplateContent();
            } else {
                content = getDefaultTemplateHtml();
            }

            // 用示例数据替换占位符
            Map<String, String> sample = getSampleData();
            for (Map.Entry<String, String> e : sample.entrySet()) {
                content = content.replace(e.getKey(), e.getValue());
            }
            // 兜底：清除所有未替换的 {{xxx}} 占位符
            content = cleanRemainingPlaceholders(content);

            log.info("generatePreview 完成: templateId={}, 内容长度={}, 耗时={}ms",
                templateId, content.length(), System.currentTimeMillis() - startTime);
            return content;
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

            try (XWPFDocument doc = new XWPFDocument();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

                // 标题
                XWPFParagraph titlePara = doc.createParagraph();
                titlePara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun titleRun = titlePara.createRun();
                titleRun.setText("报价单（预览）");
                titleRun.setBold(true);
                titleRun.setFontSize(22);
                titleRun.setFontFamily("Microsoft YaHei");

                XWPFParagraph metaPara = doc.createParagraph();
                metaPara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun metaRun = metaPara.createRun();
                metaRun.setText("模板: " + templateName + "    日期: " + DateUtil.format(new Date(), "yyyy-MM-dd HH:mm"));
                metaRun.setFontSize(11);
                metaRun.setColor("666666");
                paraSpacingP(metaPara, 0, 200, 200);

                // 信息表格
                XWPFTable infoTable = doc.createTable(3, 4);
                setTableBorders(infoTable);
                fillCell(infoTable, 0, 0, "客户名称", true);
                fillCell(infoTable, 0, 1, "示例客户公司", false);
                fillCell(infoTable, 0, 2, "报价类型", true);
                fillCell(infoTable, 0, 3, "标准报价", false);
                fillCell(infoTable, 1, 0, "币种", true);
                fillCell(infoTable, 1, 1, "CNY", false);
                fillCell(infoTable, 1, 2, "有效期至", true);
                fillCell(infoTable, 1, 3, "2026-07-13", false);
                fillCell(infoTable, 2, 0, "折扣率", true);
                fillCell(infoTable, 2, 1, "0.00%", false);
                fillCell(infoTable, 2, 2, "状态", true);
                fillCell(infoTable, 2, 3, "草稿", false);

                doc.createParagraph();

                // 行项目标题
                XWPFParagraph itemsTitle = doc.createParagraph();
                XWPFRun itemsTitleRun = itemsTitle.createRun();
                itemsTitleRun.setText("行项目明细");
                itemsTitleRun.setBold(true);
                itemsTitleRun.setFontSize(14);
                paraSpacingP(itemsTitle, 0, 200, 100);

                // 行项目表格
                String[] headers = {"序号", "产品名称", "类型", "数量", "单价", "折扣(%)", "小计"};
                XWPFTable itemsTable = doc.createTable(3, headers.length);
                setTableBorders(itemsTable);
                for (int i = 0; i < headers.length; i++) fillCell(itemsTable, 0, i, headers[i], true);
                fillCell(itemsTable, 1, 0, "1", false); fillCell(itemsTable, 1, 1, "ARC-200P 弧焊机器人主机", false);
                fillCell(itemsTable, 1, 2, "成品", false); fillCell(itemsTable, 1, 3, "1", false);
                fillCell(itemsTable, 1, 4, "120,000.00", false); fillCell(itemsTable, 1, 5, "0.00", false);
                fillCell(itemsTable, 1, 6, "120,000.00", false);
                fillCell(itemsTable, 2, 0, "2", false); fillCell(itemsTable, 2, 1, "激光焊缝跟踪系统", false);
                fillCell(itemsTable, 2, 2, "附件", false); fillCell(itemsTable, 2, 3, "1", false);
                fillCell(itemsTable, 2, 4, "38,000.00", false); fillCell(itemsTable, 2, 5, "0.00", false);
                fillCell(itemsTable, 2, 6, "38,000.00", false);

                // 汇总
                doc.createParagraph();
                addSummaryLineP(doc, "小计", "158,000.00");
                addSummaryLineP(doc, "折扣", "0.00");
                XWPFParagraph totalPara = doc.createParagraph();
                totalPara.setAlignment(ParagraphAlignment.RIGHT);
                XWPFRun totalLabel = totalPara.createRun();
                totalLabel.setText("合计: "); totalLabel.setBold(true); totalLabel.setFontSize(14);
                XWPFRun totalVal = totalPara.createRun();
                totalVal.setText("158,000.00 CNY"); totalVal.setBold(true); totalVal.setFontSize(14);
                totalVal.setColor("E6A23C");
                paraSpacingP(totalPara, 0, 100, 0);

                // 页脚
                XWPFParagraph footer = doc.createParagraph();
                footer.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun footerRun = footer.createRun();
                footerRun.setText("本报价单为预览示例，由 Smart CPQ 系统生成");
                footerRun.setFontSize(10); footerRun.setColor("999999");
                paraSpacingP(footer, 400, 0, 0);

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

    // ===== Word 文档辅助方法（预览用） =====
    private void setTableBorders(XWPFTable table) {
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
    private void fillCell(XWPFTable table, int row, int col, String text, boolean isHeader) {
        XWPFTableCell cell = table.getRow(row).getCell(col);
        cell.removeParagraph(0);
        XWPFParagraph p = cell.getParagraphs().get(0);
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setText(text == null ? "" : text);
        run.setFontSize(10); run.setFontFamily("Microsoft YaHei");
        if (isHeader) { run.setBold(true); cell.setColor("F5F7FA"); }
    }
    private void addSummaryLineP(XWPFDocument doc, String label, String value) {
        XWPFParagraph p = doc.createParagraph();
        p.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun lr = p.createRun(); lr.setText(label + ": "); lr.setFontSize(11);
        XWPFRun vr = p.createRun(); vr.setText(value); vr.setBold(true); vr.setFontSize(11);
        paraSpacingP(p, 0, 80, 0);
    }
    private void paraSpacingP(XWPFParagraph p, int before, int after, int line) {
        CTP ctp = p.getCTP();
        CTPPr pr = ctp.getPPr() != null ? ctp.getPPr() : ctp.addNewPPr();
        CTSpacing sp = pr.getSpacing() != null ? pr.getSpacing() : pr.addNewSpacing();
        sp.setBefore(BigInteger.valueOf(before));
        sp.setAfter(BigInteger.valueOf(after));
        if (line > 0) sp.setLine(BigInteger.valueOf(line));
    }

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

            // 取消同类型其他模板的默认标记
            LambdaUpdateWrapper<CpqQuoteTemplate> uw = new LambdaUpdateWrapper<>();
            uw.eq(CpqQuoteTemplate::getTemplateType, target.getTemplateType());
            uw.set(CpqQuoteTemplate::getIsDefault, "0");
            update(uw);

            // 设置当前模板为默认
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

    /** 获取默认模板 HTML（用于无 template_content 时的后备） */
    private String getDefaultTemplateHtml() {
        return "<!DOCTYPE html>\n<html lang=\"zh-CN\">\n<head>\n<meta charset=\"UTF-8\">\n" +
            "<title>报价单 - {{quote.quoteNumber}}</title>\n" +
            "<style>body{font-family:'Microsoft YaHei',sans-serif;margin:40px;color:#333}" +
            ".header{text-align:center;margin-bottom:30px}.header h1{font-size:24px}" +
            ".info-table{width:100%;border-collapse:collapse;margin-bottom:30px}" +
            ".info-table td{padding:8px 12px;border:1px solid #ddd;font-size:13px}" +
            ".info-table .label{background:#f5f7fa;font-weight:bold;width:15%}" +
            ".items-table{width:100%;border-collapse:collapse;margin-bottom:30px}" +
            ".items-table th{background:#409eff;color:#fff;padding:10px;font-size:13px}" +
            ".items-table td{padding:8px 12px;border:1px solid #ddd;font-size:13px;text-align:center}" +
            ".items-table tr:nth-child(even){background:#f9f9f9}" +
            ".summary{text-align:right}.summary-table{float:right;border-collapse:collapse}" +
            ".summary-table td{padding:6px 20px;border:1px solid #ddd;font-size:13px}" +
            ".summary-table .total{font-weight:bold;font-size:16px;color:#e6a23c}" +
            ".footer{margin-top:60px;padding-top:20px;border-top:1px solid #eee;font-size:12px;color:#999;text-align:center}" +
            "</style>\n</head>\n<body>\n" +
            "<div class=\"header\"><h1>报价单</h1><p>报价编号：{{quote.quoteNumber}} | 日期：{{quote.createTime}}</p></div>\n" +
            "<table class=\"info-table\">" +
            "<tr><td class=\"label\">客户名称</td><td>{{quote.accountName}}</td><td class=\"label\">报价类型</td><td>{{quote.quoteType}}</td></tr>" +
            "<tr><td class=\"label\">币种</td><td>{{quote.currency}}</td><td class=\"label\">有效期至</td><td>{{quote.validUntil}}</td></tr>" +
            "<tr><td class=\"label\">折扣率</td><td>{{quote.discountRate}}</td><td class=\"label\">状态</td><td>{{quote.status}}</td></tr>" +
            "</table>\n" +
            "<h3>行项目明细</h3>\n" +
            "<table class=\"items-table\"><thead><tr><th>序号</th><th>产品名称</th><th>类型</th><th>数量</th><th>单价</th><th>折扣</th><th>小计</th></tr></thead><tbody>{{lines.table}}</tbody></table>\n" +
            "<div class=\"summary\"><table class=\"summary-table\">" +
            "<tr><td>小计</td><td>{{summary.subtotal}}</td></tr>" +
            "<tr><td>折扣</td><td>{{summary.discount}}</td></tr>" +
            "<tr><td class=\"total\">合计</td><td class=\"total\">{{summary.grandTotal}} {{quote.currency}}</td></tr>" +
            "<tr><td>行项目数</td><td>{{summary.lineCount}} 项</td></tr>" +
            "</table><div style=\"clear:both\"></div></div>\n" +
            "<div class=\"footer\"><p>本报价单由 CPQ 系统自动生成</p></div>\n</body>\n</html>";
    }

    /** 示例数据 — 用于模板预览（补充所有可能的占位符，兜底替换未识别占位符为有意义的示例值） */
    private Map<String, String> getSampleData() {
        Map<String, String> data = new LinkedHashMap<>();
        // quote.* 占位符（含标准字段 + 常见扩展字段）
        data.put("{{quote.quoteNumber}}", "QT-2026-0001");
        data.put("{{quote.quoteName}}", "示例报价单");
        data.put("{{quote.quoteType}}", "标准报价");
        data.put("{{quote.accountName}}", "示例客户公司");
        data.put("{{quote.currency}}", "CNY");
        data.put("{{quote.status}}", "草稿");
        data.put("{{quote.createTime}}", DateUtil.format(new Date(), "yyyy-MM-dd HH:mm"));
        data.put("{{quote.validUntil}}", "2026-07-13");
        data.put("{{quote.discountRate}}", "0.00");
        data.put("{{quote.grandTotal}}", "158,000.00");
        data.put("{{quote.remark}}", "示例备注信息");
        data.put("{{quote.subtotal}}", "158,000.00");
        data.put("{{quote.discountTotal}}", "0.00");
        data.put("{{quote.taxTotal}}", "0.00");

        // lines.table — 行项目表格示例
        StringBuilder lines = new StringBuilder();
        lines.append("<tr><td>1</td><td>ARC-200P</td><td>弧焊机器人主机</td><td>成品</td><td>1</td><td>120,000.00</td><td>0.00</td><td>120,000.00</td></tr>");
        lines.append("<tr><td>2</td><td>LWS-300</td><td>激光焊缝跟踪系统</td><td>附件</td><td>1</td><td>38,000.00</td><td>0.00</td><td>38,000.00</td></tr>");
        data.put("{{lines.table}}", lines.toString());

        // summary.* 占位符
        data.put("{{summary.subtotal}}", "158,000.00");
        data.put("{{summary.discount}}", "0.00");
        data.put("{{summary.grandTotal}}", "158,000.00 CNY");
        data.put("{{summary.lineCount}}", "2 项");
        return data;
    }

    /** 清理所有未替换的占位符（兜底：将 {{xxx}} 替换为空或示例文本） */
    private String cleanRemainingPlaceholders(String html) {
        if (StrUtil.isBlank(html)) return html;
        // 将所有残留的 {{xxx.yyy}} 占位符替换为 "--"
        return html.replaceAll("\\{\\{[^}]+\\}\\}", "--");
    }
}
