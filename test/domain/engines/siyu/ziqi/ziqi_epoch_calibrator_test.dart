import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart';

void main() {
  test('方式一：直接采用箕宿0°黄经并归一化', () {
    expect(ZiqiEpochCalibrator.fromConstellationPipeline(
        jiXiuStartLongitude: 371.5), closeTo(11.5, 1e-9));
  });

  test('方式二：参考盘反解历元黄经（与平行公式自洽）', () {
    const daily = 0.0352;
    // 若历元黄经=100，历元后 50 日参考黄经应为 101.76
    final epochLon = ZiqiEpochCalibrator.fromReferenceChart(
      refLongitude: 100 + daily * 50,
      refJulianDay: 1050,
      epochJulianDay: 1000,
      dailyMotionDegrees: daily,
    );
    expect(epochLon, closeTo(100, 1e-6));
  });

  test('支持 365.25 天赤道体系归一化', () {
    expect(ZiqiEpochCalibrator.fromConstellationPipeline(
        jiXiuStartLongitude: 370.25, totalDegree: 365.25), closeTo(5.0, 1e-9));
  });
}
