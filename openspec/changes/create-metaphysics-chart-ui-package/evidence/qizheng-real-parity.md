# QiZhengSiYu real BeautyViewPage panel parity evidence

Date: 2026-06-21

Baseline: real `BeautyViewPage.panel()` production path.

Candidate: `BoardRenderer.qiZhengLegacy`, driven by `ChartBoard` layer inventory and Legacy ring components.

Viewport evidence:

- `qizheng-real-parity/old-400x700.png`
- `qizheng-real-parity/new-400x700.png`
- `qizheng-real-parity/diff-400x700.txt`
- `qizheng-real-parity/old-1200x900.png`
- `qizheng-real-parity/new-1200x900.png`
- `qizheng-real-parity/diff-1200x900.txt`

Diff metrics:

```text
400x700: channels=654 legacyDrift=0 maxDelta=2 bounds=(119,301)-(281,405)
1200x900: channels=420 legacyDrift=0 maxDelta=2 bounds=(563,291)-(636,364)
```

Validation commands run:

```text
flutter test test/presentation/chart_adapters/qizheng_parity_golden_test.dart test/presentation/chart_adapters/beauty_view_page_real_parity_test.dart test/presentation/chart_adapters/legacy_gstack_evidence_test.dart
flutter test
openspec validate create-metaphysics-chart-ui-package --strict --no-interactive
```

Result:

- Real old/new same-data parity passed at both 400x700 and 1200x900.
- Destiny-ring interaction parity passed by invoking the real `InkWell.onTap`.
- Full qizheng test suite passed: 493 passed, 11 skipped.
- OpenSpec strict validation passed.

Known gate still blocked:

- `flutter analyze` for the full qizheng workspace still fails on pre-existing unrelated `companion_system/` missing imports/types, so task checkboxes and commit are intentionally not completed.
