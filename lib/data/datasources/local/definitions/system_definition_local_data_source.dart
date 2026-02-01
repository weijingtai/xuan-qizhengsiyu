import 'dart:convert';

import 'package:common/module.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';

/// 本地数据源，用于加载和解析存储在assets中的坐标系定义文件。
class SystemDefinitionLocalDataSource {
  /// 从assets加载指定的JSON定义文件并将其解析为 [ZhouTianModel]。
  ///
  /// @param fileName The name of the JSON file in the 'assets/historical_definitions/' directory.
  /// @return A [Future] that completes with the parsed [ZhouTianModel].
  Future<ZhouTianModel> getSystemDefinition(String fileName) async {
    try {
      // 构建完整的文件路径
      final path = 'assets/historical_definitions/$fileName';
      // 从assets中加载JSON字符串
      final jsonString = await rootBundle.loadString(path);
      // 解码JSON字符串为Map
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      // 将Map转换为ZhouTianModel对象
      return ZhouTianModel.fromJson(jsonMap);
    } catch (e) {
      // 如果文件加载或解析失败，可以进行错误处理
      logger.e('Error loading system definition: $e');
      rethrow;
    }
  }
}
