# Acceptance Test Cases: Star Chart Page UI Component Integration

Integration of 3 xuan-common widgets into `beauty_view_page.dart`:
1. **EditableFourZhuCardV3** (four pillars card)
2. **JieQiRiseSetCard** (solar term sunrise/sunset card)
3. **YunLiuTreeList** (DaYun/LiuNian tree list)

**Reference test data:**
- DateTime: 1990-01-01 12:00
- Location: Beijing (lat 39.9042, lng 116.4074), timezone `Asia/Shanghai`
- Four Pillars: year=GENG_WU (庚午), month=WU_ZI (戊子), day=JIA_XU (甲戌), hour=GENG_WU (庚午)
- Nearest JieQi: 冬至 (DONG_ZHI), approximately 1989-12-22
- isDayBirth: true (午时 is daytime)

---

## 1. Unit Tests — ViewModel Logic

### UT-001: buildYunLiuNodes generates correct DaYun tree structure
- **Priority:** P0
- **Preconditions:** ViewModel initialized; `basicLifePanel` calculated with reference test data.
- **Steps:**
  1. Call `vm.calculate(testObserver)` with the reference observer.
  2. Read `vm.yunLiuNodesNotifier.value`.
- **Expected Result:**
  - The list is non-empty (typically 8 DaYun periods).
  - Each top-level node has `type == YunLiuNodeType.daYun`.
  - Each DaYun node's `children` list contains 10 `YunLiuNode` entries with `type == YunLiuNodeType.liuNian`.
  - LiuNian children have titles containing year numbers.

### UT-002: buildYunLiuNodes returns empty list when basicLifePanel is null
- **Priority:** P1
- **Preconditions:** ViewModel initialized but `calculate()` not yet called.
- **Steps:**
  1. Create a fresh `QiZhengSiYuViewModel` instance.
  2. Read `yunLiuNodesNotifier.value`.
- **Expected Result:** Empty list.

### UT-003: onLiuNianSelected triggers calculateDaXian with correct DateTime
- **Priority:** P0
- **Preconditions:** ViewModel calculated with reference data; `yunLiuNodesNotifier` populated.
- **Steps:**
  1. Pick a LiuNian node for year 2000 from the tree.
  2. Call `vm.onLiuNianSelected(liuNianNode)`.
- **Expected Result:**
  - `calculateDaXian()` is invoked with a DateTime in year 2000.
  - `uiDaXianPanelNotifier.value` is updated (non-null).
  - `uiFateLifeStarsNotifier.value` is updated with 11 star entries.

### UT-004: onLiuNianSelected updates fateObserver with correct coordinates
- **Priority:** P1
- **Preconditions:** ViewModel calculated with reference data.
- **Steps:**
  1. Call `vm.onLiuNianSelected(liuNianNodeFor2005)`.
  2. Inspect `vm.fateObserver`.
- **Expected Result:**
  - `fateObserver.latitude == 39.9042`
  - `fateObserver.longitude == 116.4074`
  - `fateObserver.timezone == 'Asia/Shanghai'`
  - `fateObserver.dateTime.year == 2005`

### UT-005: JieQi info is correct for reference date
- **Priority:** P0
- **Preconditions:** ViewModel calculated with reference data.
- **Steps:** Read JieQi info from ViewModel.
- **Expected Result:** Nearest JieQi is 冬至 (1989-12-22).

### UT-006: sunrise/sunset times reasonable for Beijing winter
- **Priority:** P1
- **Preconditions:** ViewModel calculated with reference data.
- **Steps:** Read rise/set data.
- **Expected Result:**
  - Sunrise between 07:00-08:00 local.
  - Sunset between 16:30-17:30 local.

### UT-007: yunLiuNodesNotifier notifies listeners on rebuild
- **Priority:** P1
- **Preconditions:** Listener attached to `yunLiuNodesNotifier`.
- **Steps:** Call `vm.calculate(testObserver)`.
- **Expected Result:** Listener invoked with non-empty list.

---

## 2. Widget Tests — Individual Widget Rendering

### WT-001: EditableFourZhuCardV3 renders four pillars correctly
- **Priority:** P0
- **Preconditions:** Widget pumped with reference CardPayload (庚午/戊子/甲戌/庚午).
- **Expected Result:** Text "庚", "午", "戊", "子", "甲", "戌" all appear. No overflow.

### WT-002: EditableFourZhuCardV3 with default theme renders without errors
- **Priority:** P1
- **Expected Result:** Card renders with `EditableCardThemeBuilder.createDefaultTheme()`.

### WT-003: JieQiRiseSetCard renders solar term name and times
- **Priority:** P0
- **Preconditions:** `jieQi: TwentyFourJieQi.DONG_ZHI`, Beijing coordinates.
- **Expected Result:** "冬至" rendered. Rise/set times in HH:MM format. Blue accent color (winter).

### WT-004: JieQiRiseSetCard compact mode
- **Priority:** P2
- **Expected Result:** Card width ~120px, compact layout.

### WT-005: YunLiuTreeList renders expandable DaYun tiles
- **Priority:** P0
- **Steps:** Pump with 2 DaYun nodes (3 LiuNian children each). Tap to expand first.
- **Expected Result:** LiuNian children appear under first DaYun only.

### WT-006: YunLiuTreeList leaf node renders as ListTile
- **Priority:** P2
- **Expected Result:** Leaf nodes render as ListTile (no expand arrow).

### WT-007: onNodeTap callback fires on LiuNian tap
- **Priority:** P0
- **Steps:** Expand DaYun, tap LiuNian child.
- **Expected Result:** `onNodeTap` called once with correct node.

### WT-008: Custom header renders DaYunTreeTileHeader
- **Priority:** P1
- **Expected Result:** Pillar cell, year range, age range all visible.

### WT-009: Three widgets in correct order on star chart page
- **Priority:** P0
- **Expected Result:** Order: PanelWidget → FourZhuCard → JieQiCard → YunLiuTree → GeJuPanel → YuanLePanel → HuaYaoPanel.

---

## 3. Integration Tests — End-to-End Flow

### IT-001: Page load displays all three widgets
- **Priority:** P0
- **Expected Result:** Star chart renders. FourZhu shows 庚午/戊子/甲戌/庚午. JieQi shows 冬至. YunLiu shows DaYun nodes.

### IT-002: LiuNian selection triggers star chart recalculation
- **Priority:** P0
- **Steps:** Expand DaYun, tap LiuNian for year 2000.
- **Expected Result:** `calculateDaXian()` invoked. `uiDaXianPanelNotifier` updated. Star positions change.

### IT-003: LiuNian selection does not alter natal chart
- **Priority:** P0
- **Expected Result:** `uiBasePanelNotifier`, `uiBasicLifeStarsNotifier`, `baseObserverPositionNotifier` all unchanged.

### IT-004: Rapid LiuNian selections handle gracefully
- **Priority:** P1
- **Steps:** Rapidly tap years 2000, 2005, 2010.
- **Expected Result:** No exceptions. Final state reflects year 2010.

### IT-005: JieQiRiseSetCard data consistent with ViewModel
- **Priority:** P1
- **Expected Result:** Displayed JieQi matches ViewModel computed data.

### IT-006: FourZhuCard data consistent with ObserverPosition
- **Priority:** P0
- **Expected Result:** Card shows same GanZhi as `baseObserverPositionNotifier.value`.

---

## 4. Edge Cases

### EC-001: Null observer — widgets handle gracefully (P0)
- **Expected Result:** All three widgets show empty/placeholder state. No null exceptions.

### EC-002: Extreme old date (year 100 AD) (P2)
- **Expected Result:** No crash. Graceful empty/null handling.

### EC-003: Future date (year 2200) (P2)
- **Expected Result:** No crash. YunLiu nodes generated or empty.

### EC-004: Polar location — no sunrise/sunset (P2)
- **Expected Result:** JieQiRiseSetCard shows "--:--" for missing times.

### EC-005: Empty YunLiuTreeList nodes (P1)
- **Expected Result:** Empty widget, no errors.

### EC-006: JieQiRiseSetCard with altitude (P2)
- **Expected Result:** Renders without error. Sunrise slightly earlier at altitude.

### EC-007: ViewModel dispose releases ValueNotifiers (P1)
- **Expected Result:** dispose() completes. Post-dispose listener throws FlutterError.

### EC-008: onNodeTap on DaYun parent node (P1)
- **Expected Result:** Ignored or handled — no unintended recalculation.

### EC-009: JieQi boundary date (P1)
- **Expected Result:** Correct JieQi identified. No ambiguity.

### EC-010: Concurrent calculate and onLiuNianSelected (P1)
- **Expected Result:** No race condition. Consistent final state.
