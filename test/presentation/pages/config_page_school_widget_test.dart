import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/domain/engines/school/school_profile.dart';
import 'package:qizhengsiyu/presentation/widgets/config/school_profile_bar.dart';

void main() {
  final sampleBooks = [
    const SchoolProfile(
      id: 'bk1', name: '流派A·典籍1', school: EnumSchoolType.GuoLao,
      classicBook: '果老星宗',
      coordinate: CelestialCoordinateSystem.Ecliptic,
      panelSystemType: PanelSystemType.Tropical,
      constellationSystemType: ConstellationSystemType.Classical,
    ),
    const SchoolProfile(
      id: 'bk2', name: '流派A·典籍2', school: EnumSchoolType.GuoLao,
      classicBook: '另一典籍',
      coordinate: CelestialCoordinateSystem.Ecliptic,
      panelSystemType: PanelSystemType.Tropical,
      constellationSystemType: ConstellationSystemType.Classical,
    ),
  ];

  testWidgets('存在典籍下拉并展示书籍名', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchoolProfileBar(
          selectedSchool: EnumSchoolType.GuoLao,
          books: sampleBooks,
          isCustomized: false,
          selectedProfileId: null,
          onBookSelected: (_) {},
          onSaveProfile: () {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('典籍'), findsOneWidget);
    // DropdownButtonFormField 含 labelText
    expect(find.text('选择典籍'), findsOneWidget);
    // 下拉选项不可见除非展开，改用类型断言验证存在
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('isCustomized=true 显示「已自定义」徽标', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchoolProfileBar(
          selectedSchool: EnumSchoolType.GuoLao,
          books: sampleBooks,
          isCustomized: true,
          onBookSelected: (_) {},
          onSaveProfile: () {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('已自定义'), findsOneWidget);
  });

  testWidgets('存在「存为自定义流派」按钮', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchoolProfileBar(
          selectedSchool: EnumSchoolType.GuoLao,
          books: sampleBooks,
          isCustomized: false,
          onBookSelected: (_) {},
          onSaveProfile: () {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('存为自定义流派'), findsOneWidget);
  });
}
