package org.dromara.cpq.quote.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.cpq.quote.domain.CpqConfigSnapshot;
import org.dromara.cpq.quote.domain.bo.CpqConfigSnapshotBo;
import org.dromara.cpq.quote.domain.vo.CpqConfigSnapshotVo;
import java.util.List;

public interface ICpqConfigSnapshotService extends IService<CpqConfigSnapshot> {
    CpqConfigSnapshotVo selectById(Long id);
    List<CpqConfigSnapshotVo> selectList(CpqConfigSnapshotBo bo);
    TableDataInfo<CpqConfigSnapshotVo> selectPageList(CpqConfigSnapshotBo bo, PageQuery pageQuery);
    int insert(CpqConfigSnapshotBo bo);
    int update(CpqConfigSnapshotBo bo);
    int deleteById(Long id);
    int deleteByIds(Long[] ids);
}
