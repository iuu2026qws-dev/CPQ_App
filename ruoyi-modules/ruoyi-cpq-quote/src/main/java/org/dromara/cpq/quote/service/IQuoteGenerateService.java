package org.dromara.cpq.quote.service;

/**
 * 报价单生成服务接口
 * <p>
 * 负责报价单 PDF/Word 文档生成，基于模板 + 配置数据填充。
 * 模板使用 {{config.*}} 占位符，运行时替换为报价单的实际数据。
 * </p>
 *
 * @author CPQ Team
 */
public interface IQuoteGenerateService {

    /**
     * 基于报价模板生成 PDF 报价单
     *
     * @param quoteId 报价单ID
     * @param templateId 模板ID
     * @return PDF 文件的字节数组
     */
    byte[] generatePdf(Long quoteId, Long templateId);

    /**
     * 基于报价模板生成 Word 报价单
     *
     * @param quoteId 报价单ID
     * @param templateId 模板ID
     * @return Word 文件的字节数组
     */
    byte[] generateWord(Long quoteId, Long templateId);

    /**
     * 使用模板填充数据，返回填充后的文档内容
     *
     * @param quoteId 报价单ID
     * @param templateId 模板ID
     * @return 填充后的 HTML 内容字符串
     */
    String fillTemplate(Long quoteId, Long templateId);
}
