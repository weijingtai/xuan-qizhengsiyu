import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/star_inn_gong_degree.dart';

void main() {
  group('QiZhengSiYuConstantResources 数据序列化测试', () {
    //   test('将星宿系统数据序列化到JSON文件', () async {
    //     // 创建输出目录
    //     final outputDir = Directory(
    //         '/Users/jingtaiwei/Git/Public/xuan/qizhengsiyu/test/output');
    //     if (!await outputDir.exists()) {
    //       await outputDir.create(recursive: true);
    //     }

    //     // 序列化黄道回归古宿数据
    //     await _serializeStarInnMapToJson(
    //       QiZhengSiYuConstantResources
    //           .ZodiacTropicalOriginalClassicStarsInnSystemMapper,
    //       '${outputDir.path}/zodiac_tropical_original_classic.json',
    //       'ZodiacTropicalOriginalClassicStarsInnSystemMapper',
    //     );

    //     // 序列化黄道回归古宿矫正数据
    //     await _serializeStarInnMapToJson(
    //       QiZhengSiYuConstantResources
    //           .ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
    //       '${outputDir.path}/zodiac_tropical_corrected_classic.json',
    //       'ZodiacTropicalCorrectedClassicStarsInnSystemMapper',
    //     );

    //     // 序列化黄道回归今宿数据
    //     await _serializeStarInnMapToJson(
    //       QiZhengSiYuConstantResources.ZodiacTropicalModernStarsInnSystemMapper,
    //       '${outputDir.path}/zodiac_tropical_modern.json',
    //       'ZodiacTropicalModernStarsInnSystemMapper',
    //     );

    //     // 序列化黄道恒星制数据
    //     await _serializeStarInnMapToJson(
    //       QiZhengSiYuConstantResources.ZodiacSiderealStarsInnSystemMapper,
    //       '${outputDir.path}/zodiac_sidereal.json',
    //       'ZodiacSiderealStarsInnSystemMapper',
    //     );

    //     // 验证文件是否已创建
    //     expect(
    //         File('${outputDir.path}/zodiac_tropical_original_classic.json')
    //             .existsSync(),
    //         true);
    //     expect(
    //         File('${outputDir.path}/zodiac_tropical_corrected_classic.json')
    //             .existsSync(),
    //         true);
    //     expect(File('${outputDir.path}/zodiac_tropical_modern.json').existsSync(),
    //         true);
    //     expect(File('${outputDir.path}/zodiac_sidereal.json').existsSync(), true);
    //   });
  });
  group("二十八心宿宿度", () {
    test("推黄术转换，三辰通载赤道恒星制到黄道恒星制", () {
      Map<String, double> mapper = {
        "角": 12.75,
        "亢": 9.75,
        "氐": 16.25,
        "房": 5.75,
        "心": 6.0,
        "尾": 18.0,
        "箕": 9.5,
        "斗": 22.75,
        "牛": 7.0,
        "女": 11.0,
        "虚": 9.25,
        "危": 16.0,
        "室": 18.25,
        "壁": 9.75,
        "奎": 18.0,
        "娄": 12.75,
        "胃": 15.25,
        "昴": 11.0,
        "毕": 16.5,
        "觜": 0.5,
        "参": 9.5,
        "井": 30.25,
        "鬼": 2.5,
        "柳": 13.5,
        "星": 6.75,
        "张": 17.75,
        "翼": 20.25,
        "轸": 18.75
      };
      mapper.forEach((key, value) {
        // EquatorialToEcliptic.equatorialToEcliptic();
      });
    });
  });
}

/// 将星宿映射表序列化为JSON文件
Future<void> _serializeStarInnMapToJson(
  Map<Enum28Constellations, ConstellationGongDegreeInfo> starInnMap,
  String filePath,
  String mapName,
) async {
  // 将Map转换为可序列化的格式
  final Map<String, dynamic> serializableMap = {};

  starInnMap.forEach((starInn, info) {
    serializableMap[starInn.starName] = info.toJson();
  });

  // 添加元数据
  final Map<String, dynamic> jsonData = {
    'metadata': {
      'name': mapName,
      'count': starInnMap.length,
      'exportTime': DateTime.now().toIso8601String(),
    },
    'data': serializableMap,
  };

  // 格式化JSON并写入文件
  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
  final file = File(filePath);
  await file.writeAsString(jsonString);

  print('已将 $mapName 数据序列化到: $filePath');
}
