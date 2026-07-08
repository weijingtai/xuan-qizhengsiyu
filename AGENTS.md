> **注意**：本文件中的所有规则同等适用于从 `xuan-migration/` 根目录启动的 AI agents。详见根目录 AGENTS.md「启动约定」。

     1|     1|
     2|
     3|## 铁律：禁止在程序标识符中使用 xuan- / xuan_ 前缀
     4|
     5|`xuan-` / `xuan_` 前缀仅用于给人区分项目（目录名、仓库名），不得出现在程序标识符中。
     6|禁止：pubspec name、library 声明、import 文件名、依赖 key 中使用 `xuan_` 前缀。
     7|例外：`XuanLogger` 等功能品牌名、`tai_xuan` 等玄学术语、Git URL/目录名。
     8|详见根目录 AGENTS.md 铁律 #6。
     9|     2|




## 铁律：主分支代码操作
当需要进行操作的时候，只有人类下达命令让他们操作的时候，才可以进行操作。

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **xuan-qizhengsiyu** (19526 symbols, 48206 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/xuan-qizhengsiyu/context` | Codebase overview, check index freshness |
| `gitnexus://repo/xuan-qizhengsiyu/clusters` | All functional areas |
| `gitnexus://repo/xuan-qizhengsiyu/processes` | All execution flows |
| `gitnexus://repo/xuan-qizhengsiyu/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
