package org.dromara.cpq.quote.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.dromara.cpq.quote.service.IQuoteGenerateService;
import org.dromara.common.core.domain.R;
import org.springframework.web.bind.annotation.*;

import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 报价单生成控制器
 * <p>
 * 提供报价单 PDF/Word/HTML 生成接口。
 * 基于报价模板 + 报价数据进行占位符替换生成。
 * </p>
 *
 * @author CPQ Team
 */
@RestController
@RequestMapping("/cpq/quote/generate")
@RequiredArgsConstructor
public class QuoteGenerateController {

    private final IQuoteGenerateService quoteGenerateService;

    /**
     * 生成报价单 PDF
     */
    @GetMapping("/pdf")
    public void generatePdf(@RequestParam Long quoteId,
                            @RequestParam Long templateId,
                            HttpServletResponse response) {
        try {
            byte[] pdfBytes = quoteGenerateService.generatePdf(quoteId, templateId);
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition",
                "attachment; filename=" + URLEncoder.encode("报价单_" + quoteId + ".pdf", StandardCharsets.UTF_8));
            try (OutputStream os = response.getOutputStream()) {
                os.write(pdfBytes);
            }
        } catch (Exception e) {
            throw new RuntimeException("生成PDF失败", e);
        }
    }

    /**
     * 生成报价单 Word
     */
    @GetMapping("/word")
    public void generateWord(@RequestParam Long quoteId,
                             @RequestParam Long templateId,
                             HttpServletResponse response) {
        try {
            byte[] wordBytes = quoteGenerateService.generateWord(quoteId, templateId);
            response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
            response.setHeader("Content-Disposition",
                "attachment; filename=" + URLEncoder.encode("报价单_" + quoteId + ".docx", StandardCharsets.UTF_8));
            try (OutputStream os = response.getOutputStream()) {
                os.write(wordBytes);
            }
        } catch (Exception e) {
            throw new RuntimeException("生成Word失败", e);
        }
    }

    /**
     * 填充模板，返回 HTML（用于前端预览/打印）
     */
    @GetMapping("/html")
    public R<String> fillTemplate(@RequestParam Long quoteId, @RequestParam Long templateId) {
        String html = quoteGenerateService.fillTemplate(quoteId, templateId);
        return R.ok(html);
    }
}
