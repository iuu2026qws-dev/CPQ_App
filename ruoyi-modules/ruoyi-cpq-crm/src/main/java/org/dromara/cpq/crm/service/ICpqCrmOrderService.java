package org.dromara.cpq.crm.service;

import org.dromara.cpq.crm.domain.bo.CpqCrmOrderBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderLineVo;
import org.dromara.cpq.crm.domain.vo.CpqCrmOrderVo;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;

import java.util.List;
import java.util.Map;

/**
 * 订单 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqCrmOrderService {

    /** 按ID查询订单详情（含明细） */
    CpqCrmOrderVo queryById(Long id);

    /** 分页查询订单列表 */
    TableDataInfo<CpqCrmOrderVo> queryPageList(CpqCrmOrderBo bo, PageQuery pageQuery);

    /** 新增订单 */
    Boolean insertByBo(CpqCrmOrderBo bo);

    /** 更新订单 */
    Boolean updateByBo(CpqCrmOrderBo bo);

    /** 软删除订单 */
    Boolean deleteWithValidByIds(List<Long> ids);

    /** 从报价生成订单 */
    Boolean fromQuote(Map<String, Object> params);

    /** 变更订单状态 */
    Boolean advanceStatus(Long id, String status);

    /** 新增订单明细行 */
    Boolean addLine(Long orderId, CpqCrmOrderLineVo line);

    /** 更新订单明细行 */
    Boolean updateLine(Long orderId, CpqCrmOrderLineVo line);

    /** 删除订单明细行 */
    Boolean deleteLine(Long orderId, Long lineId);

    /** 查询订单明细列表 */
    List<CpqCrmOrderLineVo> queryLinesByOrderId(Long orderId);
}
