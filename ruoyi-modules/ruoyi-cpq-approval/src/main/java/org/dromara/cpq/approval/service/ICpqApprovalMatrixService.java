package org.dromara.cpq.approval.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalMatrix;
import org.dromara.cpq.approval.domain.bo.CpqApprovalMatrixBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalMatrixVo;
import java.util.List;

public interface ICpqApprovalMatrixService extends IService<CpqApprovalMatrix> {
    CpqApprovalMatrixVo selectById(Long id);
    List<CpqApprovalMatrixVo> selectList(CpqApprovalMatrixBo bo);
    TableDataInfo<CpqApprovalMatrixVo> selectPageList(CpqApprovalMatrixBo bo, PageQuery pageQuery);
    int insert(CpqApprovalMatrixBo bo);
    int update(CpqApprovalMatrixBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);
}
