# P0 Go/No-Go

- Change: `create-metaphysics-chart-ui-package`
- QiZheng evidence baseline: `f130449`
- Package implementation baseline: `ea37cd7c85fd`
- Package gate fix: `977211ac98fe`
- Decision: **GO for controlled P1 reconciliation**

## Recovery Meaning

The package was implemented before this P0 gate was closed. This GO does not
retroactively approve P1-P7 and does not mean those tasks are complete. It
authorizes comparing the existing package against each later task, retaining
verified work and repairing missing behavior under the existing gates.

## Evidence Matrix

| Item | Status | Evidence |
| --- | --- | --- |
| P0.1 | Complete | `evidence/P0-risk-review.md` |
| P0.2 | Complete | Concentric-ring geometry spec, source-derived Legacy inventory |
| P0.3 | Complete | `evidence/P0.3-qimen-grid-baseline.md` |
| P0.4 | Complete | `evidence/P0.4-daliuren-grid-baseline.md` |
| P0.5 | Complete | `evidence/P0.5-ziwei-taiyi-layout-baseline.md` |
| P0.6 | Complete | `evidence/P0.6-neutral-model-validation.md`; proof levels explicitly separated |
| P0.7 | Complete | `evidence/P0.7-package-location-name.md` |
| P0.8 | Complete | `evidence/doc-validation.md`; closure rerun appended |
| P0.9 | Complete | This file |
| P0.10 | Complete | Design M0 and Theme/YAML ownership sections |
| P0.11 | Complete | `evidence/P0.11-five-module-adapters.md`; package gate `977211ac98fe` |
| P0.12 | Complete | Adapter-owned fixed-point `365.25 -> 360` normalization contract |
| P0.13 | Complete | Sparse coverage and ordered-overlay acceptance matrices |
| P0.14 | Complete | Center/zero-width/track-body contracts propagated; later implementation tasks remain unchecked |

## Stop-The-Line Results

| Condition | Result |
| --- | --- |
| A required board family has no neutral representation | PASS: five-module matrix records one without renderer module branches |
| Package name violates identifier governance | PASS: `metaphysics_chart_ui` |
| Architecture review leaves a blocking public-core flaw | PASS for P0 design; later runtime tasks remain gated |
| API is stabilized from QiZheng plus synthetic examples | PASS: API remains `@experimental`; executable gate permits only the real QiZheng consumer |

## Required Verification

```bash
# In xuan-qizhengsiyu
openspec validate create-metaphysics-chart-ui-package --strict --no-interactive
git diff --check
git status --short -- openspec/changes/create-metaphysics-chart-ui-package

# In metaphysics-chart-ui at package commit 977211ac98fe
flutter analyze
flutter test
```

The P0 evidence files must be tracked in the final QiZheng commit. A dirty or
untracked P0 evidence file invalidates this GO.
