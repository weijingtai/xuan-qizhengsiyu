import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/widgets/config/si_yu_profile_selector.dart';

void main() {
  testWidgets('选择档案回调其 id', (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      SiYuProfileSelector(selectedId: 'guolao_ecliptic', onChanged: (id) => picked = id))));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('琴堂·天赤道').last);
    await tester.pumpAndSettle();
    expect(picked, 'qintang_chidao');
  });
}
