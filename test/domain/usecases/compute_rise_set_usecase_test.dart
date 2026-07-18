import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';

ObserverPosition buildShanghaiObserver() {
  final loc = tz.getLocation('Asia/Shanghai');
  final dateTime = tz.TZDateTime(loc, 2026, 3, 20, 12, 0);
  return ObserverPosition(
    dateTime: dateTime,
    latitude: 31.23,
    longitude: 121.47,
    altitude: 0,
    timezone: 'Asia/Shanghai',
    isDayBirth: true,
    yearGanZhi: JiaZi.JIA_ZI,
    monthGanZhi: JiaZi.JIA_ZI,
    dayGanZhi: JiaZi.JIA_ZI,
    timeGanZhi: JiaZi.JIA_ZI,
  );
}

void main() {
  setUpAll(() => tz_data.initializeTimeZones());

  test('ComputeRiseSetUseCase 可构造并调用不抛异常', () {
    final observer = buildShanghaiObserver();
    // sweph FFI 在 flutter test 环境不可用,返回 null 是预期行为;
    // 关键验证:调用不抛异常,签名匹配。
    final r = ComputeRiseSetUseCase().execute(observer, locationName: '上海');
    // sweph 不可用时 r 为 null;sweph 可用时 r 非空
    expect(r == null || r.sunRise != null, isTrue);
  });
}
