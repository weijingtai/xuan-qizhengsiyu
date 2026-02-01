import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';

// --- 主函数：示例用法 ---
void main() {
  test('Zi Qi Shou Shi Li Calculation', () {
    // 当前时间 (根据上下文是 2025-04-29 10:21:51 PM EDT)
    // EDT = UTC-4, 所以 UTC 时间是 2025-04-30 02:21:51
    final DateTime now = DateTime.utc(2025, 4, 30, 2, 21, 51);

    print('--- 紫气 (Zǐ Qì) "笨办法" 计算 (可变圆周度数) ---');
    print('参考时间 (UTC): ${GenerateBasePanelService.referenceDateTimeUtc}');
    print(
        '参考位置 (估算的女宿二度, 标准度): ${GenerateBasePanelService.referencePositionDegrees}');
    print('日速率 (标准度/天): ${GenerateBasePanelService.dailyRateDegrees}');
    print('');
    print('当前计算时间 (UTC): $now');

    // --- 示例 1: 使用默认 360 度圆周 ---
    final double ziQiNow360 =
        GenerateBasePanelService.shouShiLiCalculateZiQiPosition(
            now); // 不传参数，使用默认值 360.0
    print('');
    print('圆周度数: 360.0 (默认)');
    print('计算出的紫气位置: ${ziQiNow360.toStringAsFixed(4)} 度');

    expect(ziQiNow360, isA<double>());

    // --- 示例 2: 使用 365.25 度圆周 (周天度数) ---
    final double ziQiNow365 =
        GenerateBasePanelService.shouShiLiCalculateZiQiPosition(now,
            circleDegrees: 365.25);
    print('');
    print('圆周度数: 365.25 (周天度数)');
    print('计算出的紫气位置: ${ziQiNow365.toStringAsFixed(4)} 周天度');

    // --- 示例 3: 使用其他自定义圆周度数 (例如 400) ---
    final double ziQiNow400 =
        GenerateBasePanelService.shouShiLiCalculateZiQiPosition(now,
            circleDegrees: 400.0);
    print('');
    print('圆周度数: 400.0 (自定义)');
    print('计算出的紫气位置: ${ziQiNow400.toStringAsFixed(4)} 单位');

    // --- 示例 4: 计算历史时间点，使用 365.25 度圆周 ---
    final DateTime historicalDate =
        DateTime.utc(1280, 12, 14, 1, 29, 36); // 参考时间点本身
    final double ziQiHistorical365 =
        GenerateBasePanelService.shouShiLiCalculateZiQiPosition(historicalDate,
            circleDegrees: 365.25);
    print('');
    print('历史计算时间 (UTC): $historicalDate');
    print('圆周度数: 365.25 (周天度数)');
    // 结果应该非常接近 referencePositionDegrees % 365.25
    print('计算出的紫气位置: ${ziQiHistorical365.toStringAsFixed(4)} 周天度');
    print(
        '(预期接近 ${GenerateBasePanelService.referencePositionDegrees % 365.25})'); // 284.0 % 365.25 = 284.0

    // 2013-04-09 02:57
    final DateTime historical2013Date =
        DateTime.utc(2013, 04, 09, 2, 57, 00); // 参考时间点本身
    final double ziQiHistorical2013 =
        GenerateBasePanelService.shouShiLiCalculateZiQiPosition(
            historical2013Date,
            circleDegrees: 360);

    print('计算出的紫气位置: ${ziQiHistorical2013.toStringAsFixed(4)} 周天度');
  });
}
