package org.dromara.cpq.approval.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.approval.domain.CpqApprovalRule;
import org.dromara.cpq.approval.domain.bo.CpqApprovalRuleBo;
import org.dromara.cpq.approval.domain.vo.CpqApprovalRuleVo;
import java.util.List;

public interface ICpqApprovalRuleService extends IService<CpqApprovalRule> {
    CpqApprovalRuleVo selectById(Long id);
    List<CpqApprovalRuleVo> selectList(CpqApprovalRuleBo bo);
    TableDataInfo<CpqApprovalRuleVo> selectPageList(CpqApprovalRuleBo bo, PageQuery pageQuery);
    int insert(CpqApprovalRuleBo bo);
    int update(CpqApprovalRuleBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);
}
