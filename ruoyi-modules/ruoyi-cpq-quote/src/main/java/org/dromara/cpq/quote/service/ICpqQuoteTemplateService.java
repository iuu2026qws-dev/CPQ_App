package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqQuoteTemplate;
import org.dromara.cpq.quote.domain.bo.CpqQuoteTemplateBo;
import org.dromara.cpq.quote.domain.vo.CpqQuoteTemplateVo;
import org.dromara.cpq.quote.domain.vo.TemplateFieldVo;
import java.util.List;
import java.util.Map;

public interface ICpqQuoteTemplateService extends IService<CpqQuoteTemplate> {
    CpqQuoteTemplateVo selectById(Long id);
    List<CpqQuoteTemplateVo> selectList(CpqQuoteTemplateBo bo);
    TableDataInfo<CpqQuoteTemplateVo> selectPageList(CpqQuoteTemplateBo bo, PageQuery pageQuery);
    int insert(CpqQuoteTemplateBo bo);
    int update(CpqQuoteTemplateBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);

    /** 获取模板字段库 — 报价模板设计器可用字段列表 */
    List<TemplateFieldVo> getFieldLibrary();

    /** 保存模板设计配置 (template_json) */
    int saveDesign(Long templateId, String templateJson);

    /** 生成模板预览 HTML — 用示例数据填充模板生成预览（STANDARD 类型） */
    String generatePreview(Long templateId);

    /** 生成模板预览 PDF — 用示例数据填充模板，输出 PDF 字节（PDF 类型） */
    byte[] generatePreviewPdf(Long templateId);

    /** 生成模板预览 Word — 用示例数据生成 .docx 文档（WORD 类型） */
    byte[] generatePreviewWord(Long templateId);

    /** 设置默认模板 — 将该模板设为默认，取消其他同类型模板的默认标记 */
    int setDefault(Long templateId);
}
