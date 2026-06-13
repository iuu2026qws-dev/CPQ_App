package org.dromara.cpq.service;

import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.domain.bo.CpqProductModelBo;
import org.dromara.cpq.domain.vo.CpqProductModelVo;

import java.util.List;

/**
 * CPQ 产品模型 Service 接口
 *
 * @author CPQ Team
 */
public interface ICpqProductModelService {

    TableDataInfo<CpqProductModelVo> selectPageModelList(CpqProductModelBo bo, PageQuery pageQuery);

    List<CpqProductModelVo> selectModelList(CpqProductModelBo bo);

    CpqProductModelVo selectModelById(Long modelId);

    CpqProductModelVo selectModelByCode(String modelCode);

    int insertModel(CpqProductModelBo bo);

    int updateModel(CpqProductModelBo bo);

    int deleteModel(Long modelId);

    int deleteModelByIds(Long[] modelIds);

    boolean checkModelCodeUnique(CpqProductModelBo bo);

    List<CpqProductModelVo> searchModels(String keyword, String lifecycleStatus, String configType);
}
