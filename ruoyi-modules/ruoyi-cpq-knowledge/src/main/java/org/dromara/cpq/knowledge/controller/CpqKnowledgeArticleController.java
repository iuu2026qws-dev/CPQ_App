package org.dromara.cpq.knowledge.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.cpq.knowledge.domain.CpqKnowledgeArticle;
import org.dromara.cpq.knowledge.mapper.CpqKnowledgeArticleMapper;
import org.springframework.web.bind.annotation.*;

@Slf4j @RestController @RequestMapping("/cpq/knowledge/article") @RequiredArgsConstructor
public class CpqKnowledgeArticleController {
    private final CpqKnowledgeArticleMapper mapper;
    @GetMapping("/list")
    public R<List<CpqKnowledgeArticle>> list(CpqKnowledgeArticle entity) {
        return R.ok(mapper.selectList(new LambdaQueryWrapper<CpqKnowledgeArticle>()
            .like(entity.getTitle() != null, CpqKnowledgeArticle::getTitle, entity.getTitle())
            .eq(entity.getArticleType() != null, CpqKnowledgeArticle::getArticleType, entity.getArticleType())
            .eq(entity.getCategory() != null, CpqKnowledgeArticle::getCategory, entity.getCategory())
            .orderByDesc(CpqKnowledgeArticle::getCreateTime)));
    }
    @GetMapping("/{id}") public R<CpqKnowledgeArticle> get(@PathVariable Long id) { return R.ok(mapper.selectById(id)); }
    @PostMapping public R<Void> add(@RequestBody CpqKnowledgeArticle e) { mapper.insert(e); return R.ok(); }
    @PutMapping public R<Void> edit(@RequestBody CpqKnowledgeArticle e) { mapper.updateById(e); return R.ok(); }
    @DeleteMapping("/{ids}") public R<Void> remove(@PathVariable Long[] ids) { for (Long id : ids) mapper.deleteById(id); return R.ok(); }
}
