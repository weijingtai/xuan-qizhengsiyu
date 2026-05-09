# AI Collaboration Docs Framework

A reusable, project-agnostic framework for AI-assisted software development. Built on **SPEC-Driven Development** — every non-trivial change starts with an approved design document before any code is written.

## What This Provides

- **12-module AI Constitution** (`docs/ai/`) — rules that all AI tools MUST follow: principles, phases, delivery pipeline, code style, git rules, and more
- **SPEC-Driven Workflow** — Part A (SPEC lifecycle A1-A4) + Part B (Delivery B1-B3), with entry/exit gates at every step
- **Multi-AI Workspace Isolation** — each `<developer>-<Model>` gets their own directory; reads are global, writes are scoped
- **Task Board Protocol** — shared `TASKS.md` / `PROGRESS.md` with a strict W1-W5 write channel (AI must ask permission)
- **Trivial Change Exemption** — ≤5 lines, typos, formatting skip the SPEC process entirely

## Quick Start

```bash
git clone https://github.com/weijingtai/docs.git docs/
```

Then read [`ONBOARDING.md`](ONBOARDING.md) — a 5-minute guide that covers everything.

For AI tools joining the project:

```
Please read AI_README.md and all 12 modules under docs/ai/ before writing any code.
```

## Directory Structure

```
docs/
  ONBOARDING.md           ← First-stop guide (5 min)
  README.md               ← This file
  Plans.md                ← Project plan (replace with yours)
  README_zh.md            ← 中文说明

  ai/                     ← AI Constitution (reuse as-is)
    CONSTITUTION.md       ← Version matrix for all 12 modules
    board-protocol.md     ← Task board protocol + permission matrix
    glossary.md           ← Methodology terminology
    principles.md         ← 7 non-negotiable principles
    phases.md             ← SPEC Coding stage definitions
    delivery-pipeline.md  ← Code delivery pipeline (5 steps)
    code-style.md         ← Code style guide (replace per language)
    directory-structure.md← Directory conventions
    git-rules.md          ← Branch / commit conventions
    doc-standards.md      ← Document format & naming rules
    toolchain.md          ← SDK / toolchain config (replace per stack)
    project-context-guide.md ← AI context-reading rules

  board/                  ← Shared task board (empty templates)
  project/                ← Project content (PRDs, ADRs, changelogs)
  superpowers/            ← SPEC archive (design docs & plans)
```

## Adapting to Your Project

| File | Action |
|------|--------|
| `Plans.md` | Replace with your project plan |
| `ai/code-style.md` | Replace if not using Dart/Flutter |
| `ai/toolchain.md` | Replace with your SDK/toolchain |
| `ai/directory-structure.md` | Update `lib/` example to match your structure |
| `project/README.md` | Update naming examples |

Everything else is methodology — language and stack agnostic.

## Core Principles

1. **SPEC First** — No code without an approved SPEC
2. **Think Before Coding** — Surface assumptions, tradeoffs, and alternatives
3. **Simplicity First** — Minimum code, no premature abstractions
4. **Surgical Changes** — Touch only what you must, match existing style
5. **Goal-Driven** — Define success criteria, loop until verified
6. **Chinese-First** — Comments and commit messages in Chinese
7. **Context-Aware** — Read actual source files, never guess

Full details: [`docs/ai/principles.md`](docs/ai/principles.md)

## License

MIT
