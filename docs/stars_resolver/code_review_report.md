# StarsResolver Code Review Report

**Date:** 2026-03-20
**Files reviewed:**
- `lib/presentation/pages/StarsResolver.dart` (860 lines)
- `lib/presentation/models/ui_star_model.dart` (564 lines)
- `test/ui_star_model_test.dart` (269 lines)

**Callers:**
- `qi_zheng_si_yu_viewmodel.dart` — `calculateMinSafeAngle()`, `resolveUIStars()`
- `beauty_page_viewmodel.dart` — `calculateMinSafeAngle()`, `resolveUIStars()`

---

## 1. Overall Purpose & Completed Work

### 1.1 What StarsResolver Does

`StarsResolver` is a **UI-layer collision resolver** for celestial bodies rendered on a circular astrology chart. When multiple stars occupy the same or overlapping angular positions on the chart ring, their labels/icons would overlap visually. StarsResolver adjusts their display angles so they spread out and remain readable, while staying as close to their true positions as possible.

### 1.2 Core Problem Domain

In a circular chart of radius R, each star occupies an angular "footprint" determined by:
- The physical size of the star icon (`starBodyRadius`)
- The ring geometry (`outerR`, `innerR`)

When two stars' angular footprints overlap, one or both must be nudged away. This is a **1D interval packing problem on a circular domain** (0-360 degrees).

### 1.3 Completed Algorithms

| Algorithm | Method | Status |
|-----------|--------|--------|
| Minimum safe angle calculation | `calculateMinSafeAngle()` | Complete |
| Two-star overlap resolution | `doResolve2Stars()` | Complete |
| Same-angle star spreading | `doResolveSameAngleStars()` | Complete |
| Multi-star constellation building | `doResolveConstellation()` | Complete |
| Constellation-to-single-star absorption | `doResolveConstellationWithStars()` | Complete |
| Constellation-to-constellation overlap | `handleTwoConstellationModel()` | Complete |
| Connected component detection (graph) | `GraphUtils.findConnectedComponents()` | Complete |
| Circular angle sorting | `sortCircularAngles()` / `sortCircularAnglesByGivenCenter()` | Complete |
| Priority-based star ordering | `sortInRangeStarsNoneSameAngleWithPriority()` | Complete (unused) |
| Full pipeline orchestration | `resolveUIStars()` | Complete |

---

## 2. Algorithm Descriptions

### 2.1 `calculateMinSafeAngle(outerR, innerR, r)` — Geometric Safety Angle

**Purpose:** Given a ring defined by `outerR`/`innerR` and a star icon of radius `r`, compute the minimum angular separation (in degrees) needed so two stars don't overlap.

**Algorithm:**
1. Compute the midpoint radius of the ring: `R = (outerR + innerR) / 2`
2. Compute the ratio of star radius to ring radius: `ratio = r / R`
3. If `ratio >= 1` (star as big as the ring), return 360 (impossible to fit two stars)
4. Otherwise, use the arc-sin formula: `2 * arcsin(ratio) * 180/pi`

**Math basis:** Two circles of radius `r` placed on a circle of radius `R` are tangent when the central angle between their centers equals `2 * arcsin(r/R)`. This is the standard circle packing formula.

**Edge cases handled:** `outerR <= innerR`, negative `innerR`, zero/negative `r`.

### 2.2 `resolveUIStars(stars)` — Full Pipeline Orchestrator

**Purpose:** The main entry point. Takes a list of `UIStarModel` (each with an original angle and a safety range) and returns the same list with adjusted display angles.

**Algorithm (pipeline):**
1. **Sort** stars by `originalAngle`
2. **Classify** into two buckets:
   - `needHandled`: stars that overlap with at least one other star (detected via `setupInRangeAngle()`)
   - `singleStar`: stars with no overlaps
3. **Build overlap graph** — each star maps to the set of stars it overlaps with
4. **Extract connected components** — using DFS graph traversal (`GraphUtils`)
5. **Resolve each component** — each connected set of overlapping stars becomes a "constellation" via `doResolveConstellation()`
6. **Absorb nearby singles** — for each constellation, check if any `singleStar` falls within its expanded edges; if so, absorb it into the constellation
7. **Resolve inter-constellation overlaps** — if multiple constellations exist, check for and resolve overlaps between them via `handleTwoConstellationModel()`
8. **Flatten and return** — merge all constellation-internal stars and remaining singles into one list

### 2.3 `doResolve2Stars(stars)` — Two-Star Overlap Resolution

**Purpose:** When exactly 2 stars overlap, push them apart symmetrically.

**Algorithm:**
1. If both have the same angle, delegate to `doResolveSameAngleStars()`
2. Sort stars by circular position (head/tail)
3. Check if head's range contains tail (`inRangeAngle`)
4. Compute half the overlap distance
5. Push head left and tail right by that half-distance

### 2.4 `doResolveSameAngleStars(stars)` — Same-Angle Fan-Out

**Purpose:** When N stars occupy the exact same angle, spread them evenly around that point.

**Algorithm:**
- **Odd count:** The highest-priority star stays at center. Others alternate left/right with increasing offset = `rangeAngleEachSide * position`
- **Even count:** Stars alternate left/right, each offset by `rangeAngleEachSide * position +/- rangeAngleEachSide/2`

This creates a symmetric fan around the original angle, respecting star priority (higher priority closer to center).

### 2.5 `doResolveConstellation(stars)` — Multi-Star Constellation

**Purpose:** Resolve a connected group of overlapping stars into a non-overlapping arrangement.

**Algorithm:**
1. If exactly 2 stars: use `doResolve2Stars()`
2. If all at same angle: use `doResolveSameAngleStars()`
3. Otherwise, group by angle and dispatch to:
   - `_processOddCircularAngles()` for odd-count groups
   - `_processEvenCircularAngles()` for even-count groups

**Odd case:**
1. Find the median angle group (center)
2. Build a center constellation from that group
3. Process left-side groups: each group's stars are pushed leftward from center
4. Process right-side groups: each group's stars are pushed rightward from center

**Even case:**
1. Find the two middle angle groups (left-middle and right-middle)
2. Build the center from these two groups (handling relative star counts)
3. Process remaining left/right groups outward from center

### 2.6 `handleTwoConstellationModel(constellations)` — Inter-Constellation Overlap

**Purpose:** After individual constellations are resolved, check if any two constellations overlap and push them apart.

**Algorithm:**
1. For each pair (i, j), check if constellation j's center falls within constellation i's edges
2. If the center overlaps both edges: throw (shouldn't happen in practice)
3. If left-overlap: push j leftward by the overlap amount
4. If right-overlap: push j rightward by the overlap amount

### 2.7 `GraphUtils.findConnectedComponents(graph)` — Graph DFS

**Purpose:** Standard connected-component extraction using depth-first search.

**Algorithm:** Classic DFS with visited set. For each unvisited node, traverse all reachable neighbors, collecting the component. Returns sorted sets.

### 2.8 `sortCircularAngles(angles)` — Circular Angle Sorting

**Purpose:** Sort angles in circular order around a chosen anchor point, so angles on both sides of the anchor are correctly ordered even when crossing the 0/360 boundary.

**Algorithm:**
1. Choose anchor (median of input)
2. For each other angle, compute distances to anchor going clockwise and counterclockwise
3. Classify each angle as "left of anchor" or "right of anchor" based on shortest path
4. Sort each side by distance from anchor
5. Combine: `[...left (far to near), anchor, ...right (near to far)]`

### 2.9 `checkAngleInRange(edges, otherAngle)` — Range Check

**Purpose:** Determine whether an angle falls within a given arc (defined by left/right edges), handling the 0-crossing case.

**Returns:** `Tuple3<inRange, leftDistance?, rightDistance?>`
- `inRange`: whether the angle is within the arc
- `leftDistance`: distance to left edge (non-null means closer to left edge)
- `rightDistance`: distance to right edge (non-null means closer to right edge)
- Both non-null: the angle is at the exact midpoint

### 2.10 `calculateMidpointAngle(angleA, angleB)` — Midpoint on Circle

**Purpose:** Find the midpoint angle between two angles, always taking the shorter arc.

**Algorithm:** Compute `diff = (B - A + 360) % 360`. If diff > 180, swap A/B (to take the short arc). Midpoint = `(A + diff/2) % 360`.

---

## 3. Data Model Summary

### 3.1 `UIStarModel`

| Field | Type | Purpose |
|-------|------|---------|
| `star` | `EnumStars` | Star identity (Sun, Moon, etc.) |
| `originalAngle` | `double` | True celestial position (0-360) |
| `rangeAngleEachSide` | `double` | Half the angular footprint (computed from icon size and ring geometry) |
| `priority` | `int` | Display priority (4=highest, determines center placement) |
| `adjustedAngle` | `double?` | Display position after collision resolution |
| `adjustCount` | `int` | Number of times adjusted |
| `previousAdjustedDirection` | `bool?` | Last adjustment direction |
| `originalEdges` | `Tuple3` | (leftEdge, rightEdge, center) of original range |
| `adjustedEdges` | `Tuple3?` | Edges after adjustment |
| `inRangeStar` | `Map` | Cached overlap information |

**Key property:** `angle` getter returns `adjustedAngle ?? originalAngle`, so all downstream calculations automatically use adjusted positions after mutation.

### 3.2 `UIConstellationModel`

A group of resolved stars treated as a single visual unit:
- `orderedStars`: stars sorted by circular position
- `edges`: computed from first/last star edges (scalable boundary)
- Methods: `addStar()`, `inRangeAngle()`, `adjustAngle()` (shifts all stars uniformly)

### 3.3 `Edge` mixin / `StarEdgeAngle` interface

Polymorphic interface shared by both `UIStarModel` and `UIConstellationModel`, providing:
- `edges` (left/right/center boundaries)
- `centerAngle`
- `inRangeAngle(other)` — range overlap check
- `addStar(star)` — absorb a star into the edge-holder

---

## 4. Known Defects (from test suite)

The test file `test/ui_star_model_test.dart` documents several known defects:

### Defect 3: `correctCircleAngle()` — Single-Wrap Bug
- **Issue:** Only performs one `+360` or `-360` correction
- **Impact:** Angles < -360 or >= 720 remain out of [0, 360) range
- **Example:** `correctCircleAngle(-400)` returns `-40` instead of `320`
- **Risk:** Low in practice (adjustments are typically small), but could cause errors with large accumulated adjustments

### Defect 4: `getMinDiffAngleOfTwoStar()` — Uses `max()` Instead of `sum()`
- **Issue:** Returns `max(star1.range, star2.range)` instead of `star1.range + star2.range`
- **Impact:** When two stars have different icon sizes, the computed safe distance is too small, potentially allowing overlap
- **Example:** Stars with ranges 3 and 5 return 5 instead of 8
- **Risk:** Medium — causes under-separation when star sizes differ

### Defect 5: (Documented but actually correct)
- `inRangeAngle()` correctly returns both distances when target is at exact center

### Defect 8: Cumulative `adjustAngle()` Calls
- **Issue:** `adjustAngle()` reads the `angle` getter (which returns `adjustedAngle` after first call), so consecutive calls compound
- **Impact:** Design decision rather than bug, but callers must be aware that adjustments are relative to current (possibly already adjusted) position
- **Risk:** Low if callers are aware; high if they assume adjustments are relative to original

### Defect 9: `compareTo()` Asymmetry
- **Issue:** Returns `0` if same star, `1` otherwise — never returns `-1`
- **Impact:** Violates `Comparable` contract: `a.compareTo(b)` should return `-b.compareTo(a)`
- **Also:** `compareTo() == 0` does not imply `== true` (Equatable uses `[star, originalAngle]`)
- **Risk:** Low for current usage (only used with `sort()` which may not rely on symmetry), but could cause subtle sort instability

---

## 5. Code Quality Issues

### 5.1 Mutable State Design

`UIStarModel` is heavily mutable — `adjustAngle()`, `toLeftAdjustAngle()`, `toRightAdjustAngle()` all modify internal state. This creates:
- **Side-effect coupling:** Calling `doResolve2Stars()` mutates the input stars
- **Re-run hazard:** Running `resolveUIStars()` twice on the same stars would compound adjustments
- **Testing difficulty:** Tests must create fresh instances for each scenario

**Recommendation:** Consider making adjustments return new models (immutable approach), or at minimum document that `resolveUIStars()` is destructive.

### 5.2 Code Duplication

`inRangeAngle()` is implemented **three times** with nearly identical logic:
1. `UIStarModel.inRangeAngle()` (line 122-186 in ui_star_model.dart)
2. `UIConstellationModel.inRangeAngle()` (line 470-531 in ui_star_model.dart)
3. `StarsResolver.checkAngleInRange()` (line 380-435 in StarsResolver.dart)

All three implement the same 0-crossing-aware range check. This violates DRY and creates divergence risk.

Similarly, `sortCircularAngles()` is implemented in both `StarsResolver` and `UIConstellationModel` with identical logic.

### 5.3 Commented-Out Debug Code

Multiple commented `print()` statements throughout `StarsResolver.dart` (lines 115-126, 137, 152-153) and `ui_star_model.dart` (lines 153, 160, 165, various). These should be removed or replaced with proper logging.

### 5.4 Typos and Naming

- `_scalebleEdges` should be `_scalableEdges`
- `caculateScalebleEdges` should be `calculateScalableEdges`
- `sortInRangeStarsNoneSameAngleWithPriority()` — overly long, and appears unused in the current pipeline
- File name `StarsResolver.dart` uses PascalCase (should be `stars_resolver.dart` per Dart convention)

### 5.5 Exception-Based Control Flow

Several methods throw generic `Exception` for conditions that could occur in normal operation:
- `doResolveConstellation()` throws when 2 stars "shouldn't cluster"
- `handleTwoConstellationModel()` throws on "center overlap"
- `_adjustStarAngle()` throws when star is out of range

These would crash the app in production. They should either be handled gracefully or the preconditions should be enforced upstream.

### 5.6 `Tuple` Usage

The codebase relies heavily on `Tuple2` and `Tuple3` from the `tuple` package. This reduces readability — `item1`, `item2`, `item3` are meaningless without context. Consider:
- Named records (Dart 3.0+): `({bool inRange, double? leftDist, double? rightDist})`
- Dedicated result classes

### 5.7 Unused Method

`sortInRangeStarsNoneSameAngleWithPriority()` (line 258-294) is defined but never called in the current pipeline. It handles priority-based sorting but `resolveUIStars()` doesn't use it.

---

## 6. Algorithmic Gaps & Missing Pieces

### 6.1 No Iterative Refinement

The current algorithm is single-pass: once a star is pushed, it never checks if that push created a new overlap. For dense charts with many stars at similar angles, a single pass may not fully resolve all overlaps.

**What's missing:** An iterative loop that re-checks for overlaps after each adjustment round, converging to a stable layout (or bailing after N iterations).

### 6.2 No Global Optimization

Each constellation is resolved independently, then inter-constellation overlaps are resolved pairwise. This greedy approach can produce suboptimal layouts where the total displacement is larger than necessary.

**What's missing:** A global pass that minimizes total angular displacement across all stars while satisfying all minimum-distance constraints (e.g., force-directed or constraint-solving approach).

### 6.3 No Boundary Constraints

Stars can be pushed arbitrarily far from their original positions. There's no limit on maximum displacement, which could place a star in a completely different chart region.

**What's missing:** A max-displacement cap, or visual indicators when a star has been significantly displaced.

### 6.4 Priority Not Fully Utilized

`UIStarModel.priority` (1-4 scale) is used in `doResolveSameAngleStars()` (center placement) but not consistently in the general pipeline. The unused `sortInRangeStarsNoneSameAngleWithPriority()` method suggests this was planned but not integrated.

### 6.5 No Multi-Ring Support

The algorithm operates on a single ring. If the chart has multiple rings (e.g., natal ring + transit ring), each ring must be resolved independently. Cross-ring label collision is not addressed.

### 6.6 `_createStarMap` Key Collision

`_createStarMap()` (line 495-501) maps `angle → star`. If two stars share the same angle, the second silently overwrites the first. This would lose data. The method is used in `doResolveConstellationWithStars()` and sorting methods.

---

## 7. Test Coverage Assessment

### 7.1 What's Tested (ui_star_model_test.dart)

- `correctCircleAngle` — normalization, boundary cases, known wrap bug
- `getMinDiffAngleOfTwoStar` — same/different ranges, known max-vs-sum bug
- `adjustAngle` — state mutation, edge recalculation, cumulative behavior
- `inRangeAngle` — non-crossing-0, crossing-0, exact-center cases
- `compareTo` — asymmetry bug, `==` semantic mismatch
- `addStar` — same angle, out of range, in-range push

### 7.2 What's NOT Tested

- **`StarsResolver` methods**: `resolveUIStars()`, `doResolve2Stars()`, `doResolveConstellation()`, `handleTwoConstellationModel()`, `sortCircularAngles()`, `calculateMinSafeAngle()` — none have direct unit tests
- **`UIConstellationModel`**: `addStar()`, `inRangeAngle()`, `adjustAngle()`, `caculateScalebleEdges()` — untested
- **`GraphUtils.findConnectedComponents()`** — untested
- **Edge cases**: 0/360 boundary crossing in full pipeline, 3+ overlapping stars, inter-constellation overlap resolution
- **Integration**: End-to-end test with real star data (e.g., mock 11 stars at known positions, verify all output angles are non-overlapping)

### 7.3 Recommended Test Additions

1. **StarsResolver.calculateMinSafeAngle** — boundary inputs, geometry validation
2. **StarsResolver.resolveUIStars** — integration test with mock stars covering:
   - All stars separated (no adjustment needed)
   - 2 stars overlapping
   - 3+ stars at same angle
   - Stars near 0/360 boundary
   - All 11 stars clustered in one region
3. **GraphUtils** — simple graph connectivity verification
4. **sortCircularAngles** — crossing-0 sorting correctness

---

## 8. Architecture Observations

### 8.1 Layer Violation

`StarsResolver` lives in `lib/presentation/pages/` but is a pure algorithm with no UI dependency. It should be in a utility or domain layer (e.g., `lib/presentation/utils/` or `lib/domain/utils/`).

### 8.2 Model Location

`UIStarModel` is correctly in `lib/presentation/models/` as it's a UI-specific model. However, it contains significant business logic (range checking, star addition) that could be separated from the data model.

### 8.3 Dependency

The code depends on the `tuple` package. With Dart 3.0+ records available, this dependency could be eliminated.

---

## 9. Summary

### What Works Well
- The overall pipeline design (classify → graph → components → resolve → merge) is sound
- Circular angle handling (0/360 boundary) is consistently addressed throughout
- Priority-based center placement for same-angle stars is a good UX choice
- Graph-based connected component detection is the right approach for finding overlap clusters

### Key Risks
1. **Mutable state** makes the system fragile and hard to test
2. **No iterative refinement** may leave overlaps unresolved in dense charts
3. **Exception-throwing** in normal paths could crash the app
4. **No test coverage** on `StarsResolver` itself
5. **Known defects** in `correctCircleAngle` and `getMinDiffAngleOfTwoStar` could cause edge-case bugs

### Recommended Priority Actions
1. Add integration tests for `resolveUIStars()` with various star configurations
2. Fix `correctCircleAngle()` to use modular arithmetic (`((angle % 360) + 360) % 360`)
3. Fix `getMinDiffAngleOfTwoStar()` to sum ranges instead of taking max
4. Remove or gate exception-throwing code paths
5. Extract duplicated `inRangeAngle` logic into a single shared utility
