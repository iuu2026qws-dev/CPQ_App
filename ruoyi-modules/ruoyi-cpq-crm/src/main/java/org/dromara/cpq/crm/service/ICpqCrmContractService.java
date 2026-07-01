package org.dromara.cpq.crm.service;

import org.dromara.cpq.crm.domain.bo.CpqCrmContractBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmContractVo;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;

import java.util.List;
import java.util.Map;

/**
 * 合同 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqCrmContractService {

    /** 按ID查询合同详情 */
    CpqCrmContractVo queryById(Long id);

    /** 分页查询合同列表 */
    TableDataInfo<CpqCrmContractVo> queryPageList(CpqCrmContractBo bo, PageQuery pageQuery);

    /** 新增合同 */
    Boolean insertByBo(CpqCrmContractBo bo);

    /** 更新合同 */
    Boolean updateByBo(CpqCrmContractBo bo);

    /** 软删除合同 */
    Boolean deleteWithValidByIds(List<Long> ids);

    /** 从商机生成合同 */
    Boolean fromOpportunity(Map<String, Object> params);

    /** 变更合同状态 */
    Boolean advanceStatus(Long id, String status);

    /** 查询合同关联的订单列表 */
    List<?> queryOrdersByContractId(Long contractId);
}
