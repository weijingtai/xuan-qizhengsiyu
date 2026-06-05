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
    10|     3|## 铁律：主分支代码保护
    11|     4|
    12|     5|**所有 AI agents 绝对禁止在主分支（main/master）上直接编写、修改、删除任何代码。**
    13|     6|
    14|     7|1. 禁止在 main/master 上执行任何代码变更
    15|     8|2. 所有代码修改必须在独立功能分支上进行（`feat/xxx`、`fix/xxx`、`refactor/xxx`）
    16|     9|3. 分支从 main/master 创建，最终通过 PR/MR 合并回 main/master
    17|    10|4. 合并操作由人类用户执行，AI agents 只负责创建分支、提交代码、发起 PR
    18|    11|
    19|    12|### 检查流程
    20|    13|1. `git branch --show-current` 确认当前分支
    21|    14|2. main/master → **立即停止**，提示用户创建分支
    22|    15|3. 功能分支 → 正常执行
    23|    16|
    24|    17|### 例外
    25|    18|- 只读操作（git log、git diff、cat、grep）允许在任何分支
    26|    19|- git pull / git fetch 等同步操作允许