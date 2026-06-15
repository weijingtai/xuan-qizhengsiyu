// T-Q4-BEAUTY-01: BeautyPageViewModel characterization test.
//
// Documents current BeautyPageViewModel behavior and tracks
// rootBundle/data-layer violations against the baseline.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeautyPageViewModel Characterization (T-Q4-BEAUTY-01)', () {
    test('BeautyPageViewModel source has rootBundle calls documented in baseline', () {
      final file = File('lib/presentation/pages/beauty_page_viewmodel.dart');
      expect(file.existsSync(), isTrue, reason: 'beauty_page_viewmodel.dart must exist');

      final content = file.readAsStringSync();

      // After refactoring: rootBundle calls have been moved to data layer.
      // This test verifies the ViewModel no longer directly accesses rootBundle.
      final rootBundleMatches =
          RegExp(r'rootBundle\.loadString').allMatches(content).length;

      // After refactoring: 0 rootBundle.loadString calls (moved to data layer)
      expect(rootBundleMatches, equals(0),
          reason:
              'rootBundle.loadString found in ViewModel. '
              'Data loading should be delegated to the data layer.');
    });

    test('BeautyPageViewModel source has data-layer imports documented in baseline', () {
      final file = File('lib/presentation/pages/beauty_page_viewmodel.dart');
      final lines = file.readAsLinesSync();

      final dataImports = lines
          .where((l) => l.contains("import") && l.contains("data/"))
          .toList();

      // After refactoring: 0 data-layer imports (ViewModel only depends on domain layer)
      expect(dataImports.length, equals(0),
          reason:
              'BeautyPageViewModel still has data-layer imports. '
              'Found: ${dataImports.join(", ")}');
    });

    test('BeautyPageViewModel delegates to SaveCalculatedPanelUseCase', () {
      final file = File('lib/presentation/pages/beauty_page_viewmodel.dart');
      final content = file.readAsStringSync();

      expect(content, contains('SaveCalculatedPanelUseCase'),
          reason: 'BeautyPageViewModel must reference SaveCalculatedPanelUseCase');
    });

    test('BeautyPageViewModel is a ChangeNotifier', () {
      final file = File('lib/presentation/pages/beauty_page_viewmodel.dart');
      final content = file.readAsStringSync();

      expect(content, contains('extends ChangeNotifier'),
          reason: 'BeautyPageViewModel must extend ChangeNotifier');
    });
  });
}
