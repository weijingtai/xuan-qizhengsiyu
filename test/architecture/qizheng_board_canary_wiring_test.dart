import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BeautyViewPage delegates board selection to QiZhengBoardSwitch', () {
    final source = File(
      'lib/presentation/pages/beauty_view_page.dart',
    ).readAsStringSync();

    expect(source, contains('QiZhengBoardSwitch('));
    expect(
      source,
      isNot(contains('if (renderer == BoardRenderer.production)')),
      reason: 'The page must not maintain a second renderer switch.',
    );
  });
}
