# LunarDateInfoCardV2 Chrome Sample Design

## Goal

Provide one minimal Flutter sample that displays the existing
`LunarDateInfoCardV2` in Chrome. From the repository's `example` directory, the
acceptance command is:

```bash
flutter run -d chrome
```

The opened page must immediately show the card without navigating through
`BeautyViewPage` or initializing the full application.

## Scope

- Replace the current full-application bootstrap in `example/lib/main.dart`
  with a dedicated card sample.
- Keep `LunarDateInfoCardV2` and its production styling unchanged.
- Build a complete static `LunarDateInfoV2Data` fixture using the existing
  production domain models.
- Show all visible card sections: Gregorian and lunar date, time type, solar
  term and phenology, sunrise/sunset, moonrise/moonset, coordinates, and
  timezone.
- Initialize timezone data only because the astronomical section requires it
  when coordinates are present.
- Replace the stale counter widget test with a smoke test for the card sample.
- Document the sample's exact run command in `example/README.md`.

## Out of Scope

- Starting or repairing the complete `BeautyViewPage` application.
- Repairing unrelated database, dependency-injection, Sweph, navigation, or
  persistence code.
- Wiring `QiZhengSiYuViewModel.lunarDateInfoNotifier`, which is currently never
  populated.
- Changing the visual implementation of `LunarDateInfoCardV2`.
- Adding interactive controls, data entry, networking, or live astronomical
  calculations.

## Architecture

`example/lib/main.dart` becomes a small Flutter application with one
`MaterialApp`, one scrollable page, and one `LunarDateInfoCardV2`.

The sample constructs:

1. A deterministic `DateTime`.
2. A matching static `ChineseDateInfo` containing eight characters, lunar
   date, solar term, and phenology.
3. A `DateTimeDetailsBundleLogicModel` containing standard time, timezone, and
   coordinates.
4. A `LunarDateInfoV2Data` using `EnumDatetimeType.standard`.

The application initializes the timezone database before `runApp`, then passes
the fixture directly to the production card. It does not create Providers,
databases, repositories, or the production navigator.

## Dependency Boundary

The sample reuses dependencies already resolved by `example` and the root
package. It must not add new package families or copy the Card implementation.
If Dart's direct-dependency checks require an explicit dependency used by the
fixture, only the already-used `metaphysics_core` dependency may be declared
using the same source as the root package.

The implementation must not introduce a `xuan-` or `xuan_` prefix in any new
program identifier, package name, dependency key, or import filename.

## Error Handling

All sample data is deterministic and non-null for the selected standard-time
variant. The fixture must keep the displayed date inside the selected solar
term's start/end interval. Timezone initialization must complete before
building the card so `tz.getLocation` cannot fail.

The page uses `SafeArea` and `SingleChildScrollView` so the complete card
remains reachable at narrow Chrome viewport sizes.

## Verification

The implementation follows a red-green cycle:

1. Rewrite `example/test/widget_test.dart` to expect
   `LunarDateInfoCardV2` and representative text from every major section.
2. Run the test and confirm it fails against the old full-app bootstrap for the
   expected reason.
3. Implement the minimal sample.
4. Run the targeted widget test and confirm it passes.
5. Run `flutter build web` from `example` to prove Web compilation.
6. Run the exact acceptance command `flutter run -d chrome` from `example`,
   confirm the debug service starts, and visually inspect the rendered card.

Existing unrelated repository failures are not acceptance gates for this
sample, but any new failure caused by the changed files must be fixed.

## Files Expected to Change

- `example/lib/main.dart`
- `example/test/widget_test.dart`
- `example/README.md`
- `HANDOFF.md`
- `PLAN.md`

The production Card and model files are expected to remain unchanged.
