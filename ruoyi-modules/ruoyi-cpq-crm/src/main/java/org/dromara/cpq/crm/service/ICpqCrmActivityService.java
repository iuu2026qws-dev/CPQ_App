package org.dromara.cpq.crm.service;

import org.dromara.cpq.crm.domain.bo.CpqCrmActivityBo;
import org.dromara.cpq.crm.domain.vo.CpqCrmActivityVo;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;

import java.util.List;

/**
 * 销售活动 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqCrmActivityService {

    /** 按ID查询活动详情 */
    CpqCrmActivityVo queryById(Long id);

    /** 分页查询活动列表 */
    TableDataInfo<CpqCrmActivityVo> queryPageList(CpqCrmActivityBo bo, PageQuery pageQuery);

    /** 新增销售活动 */
    Boolean insertByBo(CpqCrmActivityBo bo);

    /** 更新销售活动 */
    Boolean updateByBo(CpqCrmActivityBo bo);

    /** 软删除销售活动 */
    Boolean deleteWithValidByIds(List<Long> ids);
}
