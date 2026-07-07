import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

void main() {
  test('upsert → listAll 往返；softDelete 后不在列表', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
    );

    await db.userSchoolProfileDao.upsert(
      uuid: 'u1', name: '我的琴堂', school: '琴堂派',
      classicBook: '星学大成', config: cfg,
    );
    var list = await db.userSchoolProfileDao.listAll();
    expect(list.length, 1);
    expect(list.first.name, '我的琴堂');
    expect(list.first.panelConfig.celestialCoordinateSystem,
        CelestialCoordinateSystem.SkyEquatorial);

    await db.userSchoolProfileDao.softDelete('u1');
    list = await db.userSchoolProfileDao.listAll();
    expect(list, isEmpty);
  });
}
