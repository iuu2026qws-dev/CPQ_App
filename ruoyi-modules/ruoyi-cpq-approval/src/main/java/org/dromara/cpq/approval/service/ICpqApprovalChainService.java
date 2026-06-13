package org.dromara.cpq.approval.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalChain;
import org.dromara.cpq.approval.domain.bo.CpqApprovalChainBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalChainVo;
import java.util.List;

public interface ICpqApprovalChainService extends IService<CpqApprovalChain> {
    CpqApprovalChainVo selectById(Long id);
    List<CpqApprovalChainVo> selectList(CpqApprovalChainBo bo);
    TableDataInfo<CpqApprovalChainVo> selectPageList(CpqApprovalChainBo bo, PageQuery pageQuery);
    int insert(CpqApprovalChainBo bo);
    int update(CpqApprovalChainBo bo);
    int deleteById(Long id);
}
