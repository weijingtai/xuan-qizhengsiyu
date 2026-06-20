# Create Metaphysics Chart UI Package

## Summary

Create an independent Flutter package for reusable metaphysics chart-board rendering. The package will provide one neutral data model, four first-class renderers, a shared theme/YAML system, and module adapters so QiZhengSiYu, TaiYiShenShu, ZiWeiDouShu, DaLiuRen, and QiMenDunJia can render chart boards without reimplementing layout, hit-testing, hover/selection, or styling.

The package is not a QiZhengSiYu-only painter extraction. QiZhengSiYu is the first migration consumer because it already has complex circular Canvas rings, 360-degree tick rings, non-uniform 28-constellation arcs, and angle-positioned stars. QiMenDunJia and DaLiuRen supply the rectangular/widget-grid counterexamples that prevent the abstraction from becoming circular-only.

## Problem

Current chart-board UI code is duplicated and module-specific:

- QiZhengSiYu circular chart rendering is assembled in `lib/presentation/pages/beauty_view_page.dart` and mixes `CustomPaint`, `RingLayer`, `StarRingLayer`, ViewModel listenables, domain models, style tokens, and module-specific enums.
- QiZhengSiYu Canvas painters depend on module types such as `UIStarModel`, `EnumStars`, `EnumTwelveGong`, `ZhouTianModel`, and `BodyLifeModel`, so copying painters into a new package would drag product/domain dependencies with them.
- QiZhengSiYu rings are not all 12 equal sectors. Some layers are 360-degree tick scales, 28 non-uniform arcs, or point/angle item layers.
- Some domain coordinate systems are not 360 degrees (for example QiZhengSiYu equatorial `365.25`), while some rings intentionally paint only sparse ranges such as `0..60` or `58..72` for Zhu-Luo-San-Xian. Domain normalization belongs to the consuming adapter; sparse display coverage belongs to the neutral layout model. Because those example ranges overlap, they are separate ordered overlays sharing one radial band, not two ranges in one sparse layer.
- QiMenDunJia already has a widget-grid style (`SmartQiMenGrid`) that uses Row/Column/Grid composition and token-like theme lookup.
- DaLiuRen uses Row/Column/Table/Grid layouts for rectangular board-like views and may also need a circular 12-sector representation.
- ZiWeiDouShu can be circular 12 sectors or a rounded-rectangle perimeter with 12 palace cells.
- TaiYiShenShu needs circular boards with 16 sectors.
- Canvas board interaction is currently not a common primitive. Hover, selected state, click hit-testing, tooltips, shadows, and future drag/focus behavior would otherwise be rewritten per module.
- Theme/YAML ownership is unclear: global board tokens, renderer tokens, module palettes, and per-instance overrides need explicit precedence.

## Goals

- Create a package whose program identifiers do not use the banned `xuan_` or `xuan-` prefix.
- Provide four reusable renderers:
  - `CircularCanvasBoard`
  - `CircularWidgetBoard`
  - `RectGridCanvasBoard`
  - `RectGridWidgetBoard`
- Support equal sector layers, non-uniform full-circle and sparse partial-arc layers, 360-degree tick layers, point/angle item layers, matrix grid layouts, and rounded-rectangle perimeter layouts.
- Provide shared interaction state for Canvas and Widget renderers: hover, selected, pressed, focus, disabled, and semantic labels.
- Provide Canvas hit-testing through generated `BoardHitRegion` geometry, not ad hoc pointer math inside each painter.
- Provide ThemeExtension and YAML loading with explicit precedence:
  1. package fallback tokens
  2. theme file tokens
  3. module tokens
  4. renderer tokens
  5. chart-board instance overrides
- Keep module data ownership outside the package. Each module adapts its domain model into neutral `ChartBoard` data and keeps `moduleId` + `instanceId`.
- Require consuming adapters to normalize non-360 domain coordinates into integer display millidegrees before calling the package; package core validates but never projects source-domain coordinates.
- Preserve current visual behavior during migration with golden tests and characterization fixtures before replacing existing module UI.
- Make future interactive Canvas palace features possible without changing every module adapter.

## Non-Goals

- Do not move QiZhengSiYu calculation, ZhouTian, star collision/avoidance, ephemeris, ShenSha, GeJu, TaiYi, ZiWei, DaLiuRen, or QiMen algorithms into the UI package.
- Do not force all modules to use Canvas. Widget renderers remain first-class because some palace content is easier and more accessible as normal Flutter widgets.
- Do not force all circular boards to have 12 sectors.
- Do not force all rectangular boards to be 3x3.
- Do not introduce a generic business model for "palace meaning." The UI package knows only sectors, cells, layers, items, geometry, style, and interaction.
- Do not replace all module UI in the first implementation phase.
- Do not encode business palettes as generic semantic colors. Module palettes stay separate from global UI semantic tokens.
- Do not place source coordinate spans, ephemeris units, or `365.25 -> 360` mapping tables in package core.

## Current Evidence

- QiZhengSiYu painter and Canvas entry points are listed in `docs/superpowers/specs/2026-06-17-qizhengsiyu-chart-theme-token-migration-plan.md`.
- QiZhengSiYu `beauty_view_page.panel()` is the current circular board assembly root and includes circular rings, ValueListenable ViewModel bindings, `CustomPaint`, and center content.
- QiZhengSiYu `QiZhengChartStyle` and `QiZhengStarPalette` already prove that style/palette separation is viable, but `QiZhengStarPalette` still depends on `EnumStars` and belongs in a module adapter/submodule, not in generic core.
- QiMenDunJia `SmartQiMenGrid` proves the need for a rectangular widget renderer and palace content layout slots.
- DaLiuRen pages/widgets show Row/Column/Table/Grid board-like composition and should be treated as a rectangular renderer migration source.

## Proposed Package Shape

```text
metaphysics_chart_ui/
  lib/
    metaphysics_chart_ui.dart
    src/core/
      board_data.dart
      board_layer.dart
      board_item.dart
      board_geometry.dart
      board_interaction.dart
      board_theme.dart
      board_yaml_loader.dart
    src/layouts/
      circular_ring_layout_engine.dart
      rect_grid_layout_engine.dart
      rect_perimeter_layout_engine.dart
    src/renderers/
      circular_canvas_board.dart
      circular_widget_board.dart
      rect_grid_canvas_board.dart
      rect_grid_widget_board.dart
    src/adapters/
      adapter_contracts.dart
    src/testing/
      board_golden_harness.dart
      board_hit_test_harness.dart
```

Module adapters may live either in the consuming module first or in package subdirectories after the core stabilizes:

```text
lib/src/modules/qizhengsiyu/
lib/src/modules/taiyishenshu/
lib/src/modules/ziwei/
lib/src/modules/daliuren/
lib/src/modules/qimen/
```

The first production migration should keep adapters in consuming modules until their contracts are proven stable.

## Approval State

This proposal is ready for design review and external agent risk discovery. It is not approval to implement production package code until the OpenSpec design, task plan, and acceptance package are reviewed.
