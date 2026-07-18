import 'package:timezone/timezone.dart' as tz;
import 'package:metaphysics_core/adapters/lunar_adapter.dart';
import 'package:metaphysics_core/enums.dart';

/// 干支计算用例 — 原 QiZhengSiYuViewModel 内联的 _calculate*GanZhi 方法群上移。
final class ComputeGanZhiUseCase {
  /// 计算年干支
  JiaZi calculateYearGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!;
  }

  /// 计算月干支
  JiaZi calculateMonthGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getMonthInGanZhi())!;
  }

  /// 计算日干支
  JiaZi calculateDayGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
  }

  /// 计算时辰干支
  JiaZi calculateTimeGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getTimeInGanZhi())!;
  }
}
