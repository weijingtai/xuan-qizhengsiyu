import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart';

const double kEquTotal = 365.25;

void main() {
  late ZhouTianModel model;
  late ChiDaoXiuMapper mapper;

  setUp(() {
    final file = File(
        'example/assets/qizhengsiyu/yuan_shoushi_chidao_hengxin.json');
    final jsonMap = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    model = ZhouTianModel.fromJson(jsonMap);
    mapper = ChiDaoXiuMapper(model);
  });

  test('验证 Moira 四点在元授时天赤道恒星下的拟合残差 < 0.65 古度', () {
    // 周期 (Moira 实测)：10237.7 日
    const periodDays = 10237.7;
    const daily = kEquTotal / periodDays;

    // 历元冬至 JD: 1280-12-14 01:29:36
    const epochJd = 2188925.5622222223;

    // 点④ 2026-07-04 15:15 (格里历)
    const jd4 = 2461226.1354166665;
    // 翼宿 04°38'36'' -> 绝对赤经
    final l4 = mapper.xiuStartLongitude(Enum28Constellations.Yi_Huo_She) +
        4.0 +
        38 / 60 +
        36 / 3600;

    // 反解历元黄经 (epochLon)
    final epochLon = ZiqiEpochCalibrator.fromReferenceChart(
      refLongitude: l4,
      refJulianDay: jd4,
      epochJulianDay: epochJd,
      dailyMotionDegrees: daily,
      totalDegree: kEquTotal,
    );

    // 必须与我们计算的 calibrated value 一致
    expect(epochLon, closeTo(1.884975, 1e-5));

    final algo = GuoLaoZiQiAlgorithm(
      totalDegree: kEquTotal,
      periodDays: periodDays,
      epochJulianDay: epochJd,
      epochLongitude: epochLon,
    );

    // 验证点① (1340-02-24 08:26 UT, 儒略历)
    const jd1 = 2210546.851388889;
    final l1Expected =
        mapper.xiuStartLongitude(Enum28Constellations.Shi_Huo_Zhu) +
            8.0 +
            53 / 60 +
            42 / 3600;
    final l1Actual =
        algo.computeLongitude(julianDay: jd1, datetime: DateTime.utc(1340));
    final diff1 =
        ((l1Actual - l1Expected + 1.5 * kEquTotal) % kEquTotal) - 0.5 * kEquTotal;
    expect(diff1.abs(), lessThan(0.65), reason: '点①残差过大');

    // 验证点② (1350-03-23 20:18 UT, 儒略历)
    const jd2 = 2214227.345833333;
    final l2Expected =
        mapper.xiuStartLongitude(Enum28Constellations.Jing_Mu_Han) +
            30.0 +
            14 / 60 +
            24 / 3600;
    final l2Actual =
        algo.computeLongitude(julianDay: jd2, datetime: DateTime.utc(1350));
    final diff2 =
        ((l2Actual - l2Expected + 1.5 * kEquTotal) % kEquTotal) - 0.5 * kEquTotal;
    expect(diff2.abs(), lessThan(0.65), reason: '点②残差过大');

    // 验证点③ (1325-05-27 06:10 UT, 儒略历)
    const jd3 = 2205160.7569444445;
    final l3Expected =
        mapper.xiuStartLongitude(Enum28Constellations.Yi_Huo_She) +
            0.0 +
            50 / 60;
    final l3Actual =
        algo.computeLongitude(julianDay: jd3, datetime: DateTime.utc(1325));
    final diff3 =
        ((l3Actual - l3Expected + 1.5 * kEquTotal) % kEquTotal) - 0.5 * kEquTotal;
    expect(diff3.abs(), lessThan(0.65), reason: '点③残差过大');
  });
}
