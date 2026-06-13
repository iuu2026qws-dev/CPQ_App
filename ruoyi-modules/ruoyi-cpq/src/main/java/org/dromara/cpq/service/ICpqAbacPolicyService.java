package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqAbacPolicyBo;
import org.dromara.cpq.domain.vo.CpqAbacPolicyVo;

import java.util.List;

/**
 * CPQ ABAC策略 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqAbacPolicyService {

    List<CpqAbacPolicyVo> selectPolicyList(CpqAbacPolicyBo bo);

    CpqAbacPolicyVo selectPolicyById(Long policyId);

    int insertPolicy(CpqAbacPolicyBo bo);

    int updatePolicy(CpqAbacPolicyBo bo);

    int deletePolicy(Long policyId);
}
