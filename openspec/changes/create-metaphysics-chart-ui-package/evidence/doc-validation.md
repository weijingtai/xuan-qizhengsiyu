# Document Validation: create-metaphysics-chart-ui-package

## Scope

This evidence validates the documentation package for the reusable metaphysics chart UI package before implementation begins. It does not claim implementation, renderer behavior, screenshots, or runtime QA have passed.

## Artifacts Checked

- `openspec/changes/create-metaphysics-chart-ui-package/proposal.md`
- `openspec/changes/create-metaphysics-chart-ui-package/design.md`
- `openspec/changes/create-metaphysics-chart-ui-package/tasks.md`
- `openspec/changes/create-metaphysics-chart-ui-package/specs/metaphysics-chart-ui/spec.md`
- `openspec/changes/create-metaphysics-chart-ui-package/acceptance.md`
- `openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-risk-review.md`
- `docs/superpowers/plans/2026-06-19-metaphysics-chart-ui-package.md`

## Commands Run

Initial commands created the feature branch, ran OpenSpec strict validation, scanned for unfinished markers, checked OpenSpec status/show output, and counted documentation lines.

Re-validation after the P0 risk-review revisions:

```bash
openspec validate create-metaphysics-chart-ui-package --strict
openspec status --change create-metaphysics-chart-ui-package
rg stale point-layer and stale approval phrases across the change directory
wc -l openspec/changes/create-metaphysics-chart-ui-package/proposal.md openspec/changes/create-metaphysics-chart-ui-package/design.md openspec/changes/create-metaphysics-chart-ui-package/tasks.md openspec/changes/create-metaphysics-chart-ui-package/specs/metaphysics-chart-ui/spec.md openspec/changes/create-metaphysics-chart-ui-package/acceptance.md openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-risk-review.md openspec/changes/create-metaphysics-chart-ui-package/evidence/doc-validation.md docs/superpowers/plans/2026-06-19-metaphysics-chart-ui-package.md
```

## Results

- Branch was created successfully: `codex/metaphysics-chart-ui-openspec`.
- OpenSpec strict validation passed: `Change 'create-metaphysics-chart-ui-package' is valid`.
- Documentation unfinished-marker scan returned no actionable matches.
- OpenSpec status passed: `Progress: 4/4 artifacts complete`.
- OpenSpec show rendered the change proposal successfully.
- P0 risk review recorded twelve original blockers and a Resolution Log mapping each blocker to its resolved or gated artifact.
- Re-validation found no stale old point-layer API wording and no stale "external review still pending" approval wording.
- Line counts:
  - proposal: 106
  - design: 634
  - tasks: 219
  - spec: 215
  - acceptance: 170
  - P0 risk review: 235
  - document validation: 90
  - SuperPowers plan: 491
- total after this validation refresh: 2160

## 2026-06-20 Supplemental Validation

The coordinate and sparse-coverage revision updated the Superpowers geometry
spec and implementation plan plus OpenSpec proposal, design, tasks, normative
spec, acceptance, and P0 risk evidence.

Validated decisions:

- `365.25 -> 360` normalization is owned by the QiZhengSiYu consuming adapter,
  using deterministic fixed-point cumulative-boundary mapping; package core
  accepts normalized integer millidegrees only.
- Circular coverage distinguishes exact full-circle closure from legal sparse
  partial arcs; blank angles remain unpainted/unaddressable and the complete
  radial band remains reserved.
- Overlap, wrap, caps, seams, fragmented logical identity, semantics ownership,
  validation severity, renderer parity, Legacy rollback, and false-completion
  evidence all have normative rules and executable gates.
- The schema-v1 production evidence manifest has a closed 17-ID catalog,
  including `p0-go-no-go`, and a
  verifier contract tied to exact commit SHA and artifact hashes.

Commands rerun:

```bash
openspec validate create-metaphysics-chart-ui-package --strict --no-interactive
openspec status --change create-metaphysics-chart-ui-package
git diff --check -- docs/superpowers openspec/changes/create-metaphysics-chart-ui-package
rg placeholder and stale-contract patterns across all revised artifacts
```

OpenSpec strict validation passed. `4/4 artifacts complete` is interpreted only
as document presence; it is explicitly forbidden as runtime or production
completion evidence.

## SuperPowers Validation

- `brainstorming` was used before design decisions.
- `writing-plans` was used to create the implementation plan.
- The implementation plan includes task-by-task execution, tests, gates, and commits.
- The implementation plan requires `subagent-driven-development` or `executing-plans` before code execution.

## OpenSpec Validation

- Proposal, design, tasks, and spec delta are present.
- Acceptance package is present as an additional review artifact.
- The strict OpenSpec validator reports the change as valid.
- The status command reports all required artifacts complete.

## gStack Validation

gStack was included as the product-visible validation layer in the design and acceptance package. At the original documentation-only review baseline, no example app or renderer implementation existed from which browser screenshots and hover/tap QA could truthfully be collected.

The required gStack gates are explicitly defined:

- desktop screenshot for all four renderers
- narrow/mobile screenshot for all four renderers
- hover evidence for `CircularCanvasBoard`
- hover evidence for `RectGridCanvasBoard`
- tap/selected evidence for all four renderers
- theme/YAML switch evidence
- accessibility/keyboard smoke evidence for selectable regions
- sparse Canvas/Widget evidence for blank angles, caps, ordered overlap,
  disabled pass-through, semantics, and responsive clipping
- Legacy rollback failure-injection evidence
- commit-SHA production evidence manifest verification

These gates are mandatory before production replacement or readiness claims.

## Current Approval State

The documentation package is structurally valid. The external P0 architecture/risk review is recorded in `evidence/P0-risk-review.md`, and its documentation-level blockers are resolved or converted into explicit phase gates.

This historical validation authorized continued P0 work only. P0 has since
closed through the evidence matrix in `P0-go-no-go.md`, which authorizes
controlled reconciliation of the already-existing package against P1 and later
tasks. Production replacement remains blocked until package/adapter tests,
renderer and sparse conformance, center and track/body parity, geometry and
Legacy parity, reproducible hit-test budget, accessibility traversal, gStack
evidence, rollback injection, and manifest verification all pass against one
production candidate commit.

## Known Remaining Work After P0

- Runtime evidence items from `evidence/P0-risk-review.md` must pass before public API stabilization or user-facing board replacement.
- Candidate board examples from ZiWei, TaiYi, QiMen, and DaLiuRen are recorded as source-shape proof; real adapters remain required before public API stabilization.
- Package code must not start on `main` or `master`.

## P0 Closure Rerun (2026-06-20)

- QiZheng evidence baseline: `f130449`.
- Package implementation baseline: `ea37cd7c85fd`.
- Executable migration-gate fix: `977211ac98fe`.
- `openspec validate create-metaphysics-chart-ui-package --strict --no-interactive`: pass.
- Package `flutter analyze`: no issues.
- Package `flutter test`: 134 tests passed.
- QiZheng adapter and parity suites: 62 tests passed.
- Gate test reads the real barrel and sibling pubspec dependency graph; three
  negative fixtures reject missing annotation, a second consumer without a
  suite, and an empty suite.
- Final tracked-file and unfinished-marker scans are required immediately
  before the QiZheng P0 commit; their results are recorded in that commit's
  verification history rather than asserted from an earlier working tree.
