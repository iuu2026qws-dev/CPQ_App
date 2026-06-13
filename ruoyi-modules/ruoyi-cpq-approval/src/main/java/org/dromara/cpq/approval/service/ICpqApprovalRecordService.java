package org.dromara.cpq.approval.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalRecord;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRecordBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRecordVo;
import java.util.List;

public interface ICpqApprovalRecordService extends IService<CpqApprovalRecord> {
    CpqApprovalRecordVo selectById(Long id);
    List<CpqApprovalRecordVo> selectByChainId(Long chainId);
    TableDataInfo<CpqApprovalRecordVo> selectPageList(CpqApprovalRecordBo bo, PageQuery pageQuery);
    int insert(CpqApprovalRecordBo bo);
}
