package org.dromara.cpq.quote.service.impl;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.xwpf.usermodel.*;
import org.dromara.cpq.quote.domain.CpqQuote;
import org.dromara.cpq.quote.domain.CpqQuoteLineItem;
import org.dromara.cpq.quote.domain.CpqQuoteTemplate;
import org.dromara.cpq.quote.mapper.CpqQuoteLineItemMapper;
import org.dromara.cpq.quote.mapper.CpqQuoteMapper;
import org.dromara.cpq.quote.mapper.CpqQuoteTemplateMapper;
import org.dromara.cpq.quote.service.IQuoteGenerateService;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.*;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 报价单生成服务实现
 * <p>
 * 核心功能：基于模板的报价单生成。
 * 模板使用双花括号占位符（如 {{quote.quoteName}}、{{lines.table}}），
 * 运行时替换为报价单实际数据，输出可直接打印的 HTML 文档。
 * </p>
 * <p>
 * PDF/Word 生成支持：当前阶段生成 HTML 输出，后续可扩
 * Apache POI（Word）和 iText（PDF）生成原生文档。
 * </p>
 *
 * @author CPQ Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuoteGenerateServiceImpl implements IQuoteGenerateService {

    private final CpqQuoteMapper quoteMapper;
    private final CpqQuoteLineItemMapper lineItemMapper;
    private final CpqQuoteTemplateMapper templateMapper;

    @Override
    public byte[] generatePdf(Long quoteId, Long templateId) {
        log.info("generatePdf: quoteId={}, templateId={}", quoteId, templateId);
        long startTime = System.currentTimeMillis();
        try {
            String html = fillTemplate(quoteId, templateId);
            if (StrUtil.isBlank(html)) {
                log.warn("generatePdf: fillTemplate 返回空内容");
                return new byte[0];
            }

            // 使用 openhtmltopdf（基于 PDFBox）将 HTML 转换为 PDF
            try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                PdfRendererBuilder builder = new PdfRendererBuilder();
                builder.useFastMode();
                builder.withHtmlContent(html, null);
                builder.toStream(baos);
                builder.run();

                byte[] pdfBytes = baos.toByteArray();
                log.info("generatePdf 完成: quoteId={}, PDF大小={} bytes, 耗时={}ms",
                    quoteId, pdfBytes.length, System.currentTimeMillis() - startTime);
                return pdfBytes;
            }
        } catch (Exception e) {
            log.error("generatePdf 异常: quoteId={}, 耗时={}ms", quoteId, System.currentTimeMillis() - startTime, e);
            throw new RuntimeException("生成PDF失败: " + e.getMessage(), e);
        }
    }

    @Override
    public byte[] generateWord(Long quoteId, Long templateId) {
        log.info("generateWord: quoteId={}, templateId={}", quoteId, templateId);
        long startTime = System.currentTimeMillis();
        try {
            CpqQuote quote = quoteMapper.selectById(quoteId);
            if (quote == null) {
                log.warn("generateWord: 报价单不存在 quoteId={}", quoteId);
                return new byte[0];
            }
            List<CpqQuoteLineItem> lineItems = loadLineItems(quoteId);

            // 使用 Apache POI XWPF 创建 .docx 文档
            try (XWPFDocument doc = new XWPFDocument();
                 ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

                // 标题
                XWPFParagraph titlePara = doc.createParagraph();
                titlePara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun titleRun = titlePara.createRun();
                titleRun.setText("报价单");
                titleRun.setBold(true);
                titleRun.setFontSize(22);
                titleRun.setFontFamily("Microsoft YaHei");

                // 报价编号和日期
                XWPFParagraph metaPara = doc.createParagraph();
                metaPara.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun metaRun = metaPara.createRun();
                metaRun.setText("编号: " + nvl(quote.getQuoteNumber())
                    + "    日期: " + (quote.getCreateTime() != null
                        ? DateUtil.format(quote.getCreateTime(), "yyyy-MM-dd HH:mm") : ""));
                metaRun.setFontSize(11);
                metaRun.setColor("666666");
                paraSpacing(metaPara, 0, 200, 200);

                // 报价单信息表格
                XWPFTable infoTable = doc.createTable(3, 4);
                setTableStyle(infoTable);
                fillInfoCell(infoTable, 0, 0, "客户名称", true);
                fillInfoCell(infoTable, 0, 1, nvl(quote.getAccountName()), false);
                fillInfoCell(infoTable, 0, 2, "报价类型", true);
                fillInfoCell(infoTable, 0, 3, nvl(quote.getQuoteType()), false);
                fillInfoCell(infoTable, 1, 0, "币种", true);
                fillInfoCell(infoTable, 1, 1, nvl(quote.getCurrency(), "CNY"), false);
                fillInfoCell(infoTable, 1, 2, "有效期至", true);
                fillInfoCell(infoTable, 1, 3, quote.getValidUntil() != null ? quote.getValidUntil().toString() : "", false);
                fillInfoCell(infoTable, 2, 0, "折扣率", true);
                fillInfoCell(infoTable, 2, 1, formatMoney(quote.getDiscountTotal(), "0.00"), false);
                fillInfoCell(infoTable, 2, 2, "状态", true);
                fillInfoCell(infoTable, 2, 3, nvl(quote.getStatus()), false);

                // 空行
                doc.createParagraph();

                // 行项目明细标题
                XWPFParagraph itemsTitle = doc.createParagraph();
                XWPFRun itemsTitleRun = itemsTitle.createRun();
                itemsTitleRun.setText("行项目明细");
                itemsTitleRun.setBold(true);
                itemsTitleRun.setFontSize(14);
                paraSpacing(itemsTitle, 0, 200, 100);

                // 行项目表格
                String[] headers = {"序号", "产品名称", "类型", "数量", "单价", "折扣(%)", "小计"};
                XWPFTable itemsTable = doc.createTable(lineItems.isEmpty() ? 2 : lineItems.size() + 1, headers.length);
                setTableStyle(itemsTable);
                for (int i = 0; i < headers.length; i++) {
                    fillInfoCell(itemsTable, 0, i, headers[i], true);
                }
                if (lineItems.isEmpty()) {
                    // 合并空行并显示提示
                    fillInfoCell(itemsTable, 1, 0, "暂无行项目", false);
                } else {
                    int rowIdx = 1;
                    for (CpqQuoteLineItem li : lineItems) {
                        fillInfoCell(itemsTable, rowIdx, 0, String.valueOf(rowIdx), false);
                        fillInfoCell(itemsTable, rowIdx, 1, nvl(li.getItemName()), false);
                        fillInfoCell(itemsTable, rowIdx, 2, nvl(li.getItemType()), false);
                        fillInfoCell(itemsTable, rowIdx, 3, li.getQuantity() != null ? li.getQuantity().toString() : "0", false);
                        fillInfoCell(itemsTable, rowIdx, 4, formatMoney(li.getUnitPrice()), false);
                        fillInfoCell(itemsTable, rowIdx, 5, li.getDiscountPct() != null ? li.getDiscountPct().toString() : "0.00", false);
                        fillInfoCell(itemsTable, rowIdx, 6, formatMoney(li.getLineTotal()), false);
                        rowIdx++;
                    }
                }

                // 汇总
                doc.createParagraph();
                BigDecimal subtotal = lineItems.stream()
                    .map(li -> li.getLineTotal() != null ? li.getLineTotal() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
                BigDecimal grandTotal = quote.getGrandTotal() != null ? quote.getGrandTotal() : subtotal;
                BigDecimal discount = subtotal.subtract(grandTotal);

                addSummaryLine(doc, "小计", formatMoney(subtotal));
                addSummaryLine(doc, "折扣", formatMoney(discount));
                XWPFParagraph totalPara = doc.createParagraph();
                totalPara.setAlignment(ParagraphAlignment.RIGHT);
                XWPFRun totalLabel = totalPara.createRun();
                totalLabel.setText("合计: ");
                totalLabel.setBold(true);
                totalLabel.setFontSize(14);
                XWPFRun totalValue = totalPara.createRun();
                totalValue.setText(formatMoney(grandTotal) + " " + nvl(quote.getCurrency(), "CNY"));
                totalValue.setBold(true);
                totalValue.setFontSize(14);
                totalValue.setColor("E6A23C");
                paraSpacing(totalPara, 0, 100, 0);

                // 页脚
                XWPFParagraph footer = doc.createParagraph();
                footer.setAlignment(ParagraphAlignment.CENTER);
                XWPFRun footerRun = footer.createRun();
                footerRun.setText("本报价单由 Smart CPQ 系统生成");
                footerRun.setFontSize(10);
                footerRun.setColor("999999");
                paraSpacing(footer, 400, 0, 0);

                doc.write(baos);
                byte[] wordBytes = baos.toByteArray();
                log.info("generateWord 完成: quoteId={}, Word大小={} bytes, 耗时={}ms",
                    quoteId, wordBytes.length, System.currentTimeMillis() - startTime);
                return wordBytes;
            }
        } catch (Exception e) {
            log.error("generateWord 异常: quoteId={}, 耗时={}ms", quoteId, System.currentTimeMillis() - startTime, e);
            throw new RuntimeException("生成Word失败: " + e.getMessage(), e);
        }
    }

    @Override
    public String fillTemplate(Long quoteId, Long templateId) {
        log.info("fillTemplate: quoteId={}, templateId={}", quoteId, templateId);

        CpqQuote quote = quoteMapper.selectById(quoteId);
        if (quote == null) {
            log.warn("报价单不存在: quoteId={}", quoteId);
            return "";
        }

        CpqQuoteTemplate template = templateMapper.selectById(templateId);
        String templateContent;
        if (template != null && StrUtil.isNotBlank(template.getTemplateContent())) {
            templateContent = template.getTemplateContent();
        } else {
            templateContent = getDefaultTemplate();
        }

        List<CpqQuoteLineItem> lineItems = loadLineItems(quoteId);

        // 替换占位符
        String result = templateContent;
        result = replaceQuoteFields(result, quote);
        result = replaceLineTable(result, lineItems);
        result = replaceSummary(result, quote, lineItems);

        log.info("fillTemplate 完成: quoteId={}, 内容长度={}", quoteId, result.length());
        return result;
    }

    /**
     * 加载报价行项目列表（按行号排序）
     */
    private List<CpqQuoteLineItem> loadLineItems(Long quoteId) {
        return lineItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CpqQuoteLineItem>()
                .eq(CpqQuoteLineItem::getQuoteId, quoteId)
                .orderByAsc(CpqQuoteLineItem::getLineNumber)
        );
    }

    /**
     * 替换报价单头部占位符
     * 支持的占位符：{{quote.quoteName}}、{{quote.quoteType}}、{{quote.accountName}}、
     * {{quote.currency}}、{{quote.status}}、{{quote.createTime}}、{{quote.grandTotal}}、
     * {{quote.discountRate}}、{{quote.validUntil}}、{{quote.remark}}
     */
    private String replaceQuoteFields(String content, CpqQuote quote) {
        Map<String, String> replacements = new LinkedHashMap<>();
        replacements.put("{{quote.quoteName}}", nvl(quote.getQuoteNumber()));
        replacements.put("{{quote.quoteType}}", nvl(quote.getQuoteType()));
        replacements.put("{{quote.accountName}}", nvl(quote.getAccountName()));
        replacements.put("{{quote.currency}}", nvl(quote.getCurrency(), "CNY"));
        replacements.put("{{quote.status}}", nvl(quote.getStatus()));
        replacements.put("{{quote.grandTotal}}", formatMoney(quote.getGrandTotal()));
        replacements.put("{{quote.discountRate}}", formatMoney(quote.getDiscountTotal(), "0.00"));
        replacements.put("{{quote.remark}}", "");
        if (quote.getCreateTime() != null) {
            replacements.put("{{quote.createTime}}",
                DateUtil.format(quote.getCreateTime(), "yyyy-MM-dd HH:mm"));
        } else {
            replacements.put("{{quote.createTime}}", "");
        }
        if (quote.getValidUntil() != null) {
            replacements.put("{{quote.validUntil}}",
                quote.getValidUntil().toString());
        } else {
            replacements.put("{{quote.validUntil}}", "");
        }

        for (Map.Entry<String, String> e : replacements.entrySet()) {
            content = content.replace(e.getKey(), e.getValue());
        }
        return content;
    }

    /**
     * 替换行项目表格占位符 {{lines.table}}
     * 生成 HTML 表格行
     */
    private String replaceLineTable(String content, List<CpqQuoteLineItem> lineItems) {
        if (lineItems.isEmpty()) {
            return content.replace("{{lines.table}}",
                "<tr><td colspan=\"7\" style=\"text-align:center;color:#999\">暂无行项目</td></tr>");
        }

        StringBuilder sb = new StringBuilder();
        int i = 1;
        for (CpqQuoteLineItem li : lineItems) {
            sb.append("<tr>");
            sb.append("<td>").append(i++).append("</td>");
            sb.append("<td>").append(nvl(li.getItemName())).append("</td>");
            sb.append("<td>").append(nvl(li.getItemType())).append("</td>");
            sb.append("<td>").append(li.getQuantity() != null ? li.getQuantity() : "0").append("</td>");
            sb.append("<td>").append(formatMoney(li.getUnitPrice())).append("</td>");
            sb.append("<td>").append(li.getDiscountPct() != null ? li.getDiscountPct() : "0.00").append("</td>");
            sb.append("<td>").append(formatMoney(li.getLineTotal())).append("</td>");
            sb.append("</tr>");
        }
        return content.replace("{{lines.table}}", sb.toString());
    }

    /**
     * 替换汇总占位符
     */
    private String replaceSummary(String content, CpqQuote quote, List<CpqQuoteLineItem> lineItems) {
        BigDecimal subtotal = lineItems.stream()
            .map(li -> li.getLineTotal() != null ? li.getLineTotal() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal grandTotal = quote.getGrandTotal() != null ? quote.getGrandTotal() : subtotal;
        BigDecimal discount = subtotal.subtract(grandTotal);

        content = content.replace("{{summary.subtotal}}", formatMoney(subtotal));
        content = content.replace("{{summary.discount}}", formatMoney(discount));
        content = content.replace("{{summary.grandTotal}}", formatMoney(grandTotal));
        content = content.replace("{{summary.lineCount}}", String.valueOf(lineItems.size()));
        return content;
    }

    /**
     * 获取默认报价单 HTML 模板
     */
    private String getDefaultTemplate() {
        return """
            <!DOCTYPE html>
            <html lang="zh-CN">
            <head>
                <meta charset="UTF-8">
                <title>报价单 - {{quote.quoteName}}</title>
                <style>
                    body { font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif; margin: 40px; color: #333; }
                    .header { text-align: center; margin-bottom: 30px; }
                    .header h1 { font-size: 24px; margin-bottom: 5px; }
                    .header .subtitle { color: #666; font-size: 14px; }
                    .info-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
                    .info-table td { padding: 8px 12px; border: 1px solid #ddd; font-size: 13px; }
                    .info-table .label { background: #f5f7fa; font-weight: bold; width: 15%; }
                    .items-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
                    .items-table th { background: #409eff; color: #fff; padding: 10px; font-size: 13px; }
                    .items-table td { padding: 8px 12px; border: 1px solid #ddd; font-size: 13px; text-align: center; }
                    .items-table tr:nth-child(even) { background: #f9f9f9; }
                    .summary { text-align: right; margin-bottom: 30px; }
                    .summary-table { float: right; border-collapse: collapse; }
                    .summary-table td { padding: 6px 20px; border: 1px solid #ddd; font-size: 13px; }
                    .summary-table .total { font-weight: bold; font-size: 16px; color: #e6a23c; }
                    .footer { margin-top: 60px; padding-top: 20px; border-top: 1px solid #eee; font-size: 12px; color: #999; text-align: center; }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>报价单</h1>
                    <p class="subtitle">报价编号：{{quote.quoteName}} &nbsp;|&nbsp; 日期：{{quote.createTime}}</p>
                </div>
                <table class="info-table">
                    <tr><td class="label">客户名称</td><td>{{quote.accountName}}</td><td class="label">报价类型</td><td>{{quote.quoteType}}</td></tr>
                    <tr><td class="label">币种</td><td>{{quote.currency}}</td><td class="label">有效期至</td><td>{{quote.validUntil}}</td></tr>
                    <tr><td class="label">折扣率</td><td>{{quote.discountRate}}</td><td class="label">状态</td><td>{{quote.status}}</td></tr>
                    <tr><td class="label">备注</td><td colspan="3">{{quote.remark}}</td></tr>
                </table>
                <h3>行项目明细</h3>
                <table class="items-table">
                    <thead>
                        <tr><th>序号</th><th>项目名称</th><th>类型</th><th>数量</th><th>单价</th><th>折扣</th><th>小计</th></tr>
                    </thead>
                    <tbody>
                        {{lines.table}}
                    </tbody>
                </table>
                <div class="summary">
                    <table class="summary-table">
                        <tr><td>小计</td><td>{{summary.subtotal}}</td></tr>
                        <tr><td>折扣</td><td>{{summary.discount}}</td></tr>
                        <tr><td class="total">合计</td><td class="total">{{summary.grandTotal}} {{quote.currency}}</td></tr>
                        <tr><td>行项目数</td><td>{{summary.lineCount}} 项</td></tr>
                    </table>
                    <div style="clear:both"></div>
                </div>
                <div class="footer">
                    <p>本报价单由 CPQ 系统自动生成 | 生成时间：{{quote.createTime}}</p>
                </div>
            </body>
            </html>
            """;
    }

    // ===== Word 生成辅助方法 =====

    /** 设置表格基础样式：边框、宽度 */
    private void setTableStyle(XWPFTable table) {
        table.setWidth("100%");
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

    /** 填充表格单元格 */
    private void fillInfoCell(XWPFTable table, int row, int col, String text, boolean isHeader) {
        XWPFTableCell cell = table.getRow(row).getCell(col);
        cell.removeParagraph(0);
        XWPFParagraph p = cell.getParagraphs().get(0);
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setText(text == null ? "" : text);
        run.setFontSize(10);
        run.setFontFamily("Microsoft YaHei");
        if (isHeader) {
            run.setBold(true);
            cell.setColor("F5F7FA");
        }
    }

    /** 添加汇总行 */
    private void addSummaryLine(XWPFDocument doc, String label, String value) {
        XWPFParagraph p = doc.createParagraph();
        p.setAlignment(ParagraphAlignment.RIGHT);
        XWPFRun labelRun = p.createRun();
        labelRun.setText(label + ": ");
        labelRun.setFontSize(11);
        XWPFRun valueRun = p.createRun();
        valueRun.setText(value);
        valueRun.setBold(true);
        valueRun.setFontSize(11);
        paraSpacing(p, 0, 80, 0);
    }

    /** 设置段落间距 */
    private void paraSpacing(XWPFParagraph p, int before, int after, int line) {
        CTP ctp = p.getCTP();
        CTPPr pr = ctp.getPPr() != null ? ctp.getPPr() : ctp.addNewPPr();
        CTSpacing spacing = pr.getSpacing() != null ? pr.getSpacing() : pr.addNewSpacing();
        spacing.setBefore(BigInteger.valueOf(before));
        spacing.setAfter(BigInteger.valueOf(after));
        if (line > 0) spacing.setLine(BigInteger.valueOf(line));
    }

    // ===== 通用工具方法 =====

    private String nvl(String val) { return nvl(val, ""); }
    private String nvl(String val, String def) { return StrUtil.isBlank(val) ? def : val; }
    private String formatMoney(BigDecimal val) { return formatMoney(val, "0.00"); }
    private String formatMoney(BigDecimal val, String def) {
        if (val == null) return def;
        return val.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }
}
