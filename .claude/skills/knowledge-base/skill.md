# Knowledge Base Search

Search the local knowledge base for relevant information before answering technical questions.

## When to Use

Trigger this skill when:
- User asks about a project, framework, or tool we've worked with before
- User asks "how do I..." about something we've documented
- User references past work or conversations
- Answering would benefit from documented experience or best practices

## How to Search

```bash
bash ~/knowledge-base/kb.sh search "<query>" -f inline -k 3
```

### Search Options

| Flag | Description |
|------|-------------|
| `-c <collection>` | Search specific collection: `project-experience`, `framework-knowledge`, `work-summary`, `general` |
| `-k N` | Number of results (default 5) |
| `-f inline` | Plain text output (best for context injection) |
| `-f markdown` | Formatted markdown output |
| `-f json` | JSON output for programmatic use |

### Collections

| Collection | What's in it |
|---|---|
| `project-experience` | 项目经验、踩坑记录、最佳实践 |
| `framework-knowledge` | 开源框架使用经验、配置技巧、API 参考 |
| `work-summary` | 工作总结、方法论、流程文档 |
| `general` | 通用知识、环境配置、工具链 |

## How to Ingest

When the user shares valuable knowledge (经验总结、框架技巧、配置方案), proactively ask if they want to save it:

```bash
# Ingest a file
bash ~/knowledge-base/kb.sh ingest <file> -c <collection>

# Ingest a directory
bash ~/knowledge-base/kb.sh ingest <dir> -c <collection>

# Preview without inserting
bash ~/knowledge-base/kb.sh ingest <path> -c <collection> --dry-run
```

## How to Check Stats

```bash
bash ~/knowledge-base/kb.sh stats
```

## Integration Rules

1. **Search before answering**: When a question relates to past projects or documented knowledge, search the KB first
2. **Proactive saving**: After completing a significant task or solving a complex problem, ask the user if they want to save the learnings
3. **Cross-reference**: When KB results are used in an answer, mention which collection and document they came from
4. **Keep current**: If old information is found that contradicts new learnings, suggest updating it
