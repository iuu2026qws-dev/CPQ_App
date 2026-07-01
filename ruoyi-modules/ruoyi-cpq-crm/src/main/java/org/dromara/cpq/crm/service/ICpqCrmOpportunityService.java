package org.dromara.cpq.crm.service;

import org.dromara.cpq.crm.domain.bo.CpqCrmOpportunityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOpportunityVo;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;

import java.util.List;

/**
 * 商机 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqCrmOpportunityService {

    /** 按ID查询商机详情 */
    CpqCrmOpportunityVo queryById(Long id);

    /** 分页查询商机列表 */
    TableDataInfo<CpqCrmOpportunityVo> queryPageList(CpqCrmOpportunityBo bo, PageQuery pageQuery);

    /** 条件查询商机列表（不分页） */
    List<CpqCrmOpportunityVo> queryList(CpqCrmOpportunityBo bo);

    /** 新增商机 */
    Boolean insertByBo(CpqCrmOpportunityBo bo);

    /** 更新商机 */
    Boolean updateByBo(CpqCrmOpportunityBo bo);

    /** 软删除商机 */
    Boolean deleteWithValidByIds(List<Long> ids);

    /** 推进商机阶段 */
    Boolean advanceStage(Long id, String stage, String nextStep);

    /** 查询商机关联的报价单列表 */
    List<?> queryQuotesByOpportunityId(Long opportunityId);

    /** 查询商机关联的销售活动列表 */
    List<?> queryActivitiesByOpportunityId(Long opportunityId);
}
