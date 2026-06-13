package org.dromara.cpq.service;

import org.dromara.cpq.domain.bo.CpqSystemConfigBo;
import org.dromara.cpq.domain.vo.CpqSystemConfigVo;

import java.util.List;

/**
 * CPQ 系统参数 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqSystemConfigService {

    List<CpqSystemConfigVo> selectConfigList(CpqSystemConfigBo bo);

    CpqSystemConfigVo selectConfigById(Long configId);

    /**
     * 按 config_key 查询配置值
     */
    CpqSystemConfigVo selectConfigByKey(String configKey);

    int insertConfig(CpqSystemConfigBo bo);

    int updateConfig(CpqSystemConfigBo bo);

    int deleteConfig(Long configId);
}
