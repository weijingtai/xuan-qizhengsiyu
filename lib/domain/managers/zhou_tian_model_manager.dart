import 'dart:convert';
import 'dart:io';
import 'package:xuan_logger/xuan_logger.dart';

import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import '../../xing_xian/gong_constellation_mapping.dart';
import '../entities/models/panel_config.dart';
import '../entities/models/zhou_tian_model.dart';
import 'zhou_tian_calculator.dart';

class ZhouTianModelManager {
  final QiZhengZhouTianModelRepository _repository;

  ZhouTianModelManager({required QiZhengZhouTianModelRepository repository})
      : _repository = repository;

  // 使用Map存储加载的ZhouTianModel
  final Map<String, ZhouTianModel> _mapper = {};
  bool _isLoaded = false;

  Future<Map<String, ZhouTianModel>> loadFromFiles(
      List<String> filePaths) async {
    if (_mapper.isNotEmpty) {
      clear();
    }
    for (String filePath in filePaths) {
      File file = File(filePath);
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      ZhouTianModel model = ZhouTianModel.fromJson(jsonMap);
      String key = _createMapperKey(model.systemType, model.panelSystemType,
          model.constellationSystemType);
      _mapper[key] = model;
    }
    _isLoaded = true;
    return _mapper; // Return the mapper as the resul
  }

  /// 异步加载周天模型数据（通过注入的 repository）
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final models = await _repository.loadBuiltInZhouTianModels();
      for (final contract in models) {
        final model = ZhouTianModel.fromJson(contract.raw);
        _addModelToMapper(model);
      }
      
      await loadUserSchemes();

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load ZhouTianModel data: $e');
    }
  }

  Future<void> loadUserSchemes() async {
    try {
      // 假设用户预设存放在应用文档目录的 user_schemes/ 文件夹下
      // 在 CLI 环境中，我们可以检查本地目录
      final userSchemesDir = Directory('user_schemes');
      if (await userSchemesDir.exists()) {
        final List<FileSystemEntity> entities = await userSchemesDir.list().toList();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.json')) {
            final String content = await entity.readAsString();
            final model = ZhouTianModel.fromJson(json.decode(content));
            _addModelToMapper(model);
            logger.i("Loaded user scheme: ${entity.path}");
          }
        }
      }
    } catch (e) {
      logger.w("Failed to load user schemes: $e");
    }
  }

  void _addModelToMapper(ZhouTianModel model) {
    final key = _createMapperKey(model.systemType, model.panelSystemType,
        model.constellationSystemType);
    _mapper[key] = model;
  }

  /// 根据PanelConfig获取对应的ZhouTianModel
  ZhouTianModel getZhouTianModelBy(BasePanelConfig config) {
    if (!_isLoaded) {
      throw StateError(
          'ZhouTianModelManager has not been loaded yet. Call load() first.');
    }

    final key = _createMapperKey(config.celestialCoordinateSystem,
        config.panelSystemType, config.constellationSystemType);

    if (!_mapper.containsKey(key)) {
      throw UnimplementedError(
          'No ZhouTianModel found for the given PanelConfig.');
    }
    return _mapper[key]!;
  }

  /// 创建映射器的键
  String _createMapperKey(
      CelestialCoordinateSystem systemType,
      PanelSystemType panelSystemType,
      ConstellationSystemType constellationSystemType) {
    return '${systemType.name}_${panelSystemType.name}_${constellationSystemType.name}';
  }

  /// 获取所有已加载的模型
  Map<String, ZhouTianModel> get allModels {
    if (!_isLoaded) {
      throw StateError(
          'ZhouTianModelManager has not been loaded yet. Call load() first.');
    }
    return Map.unmodifiable(_mapper);
  }

  /// 检查是否已加载
  bool get isLoaded => _isLoaded;

  /// 获取可用的系统类型列表
  List<CelestialCoordinateSystem> get availableSystemTypes {
    if (!_isLoaded) return [];
    return _mapper.values.map((model) => model.systemType).toSet().toList();
  }

  /// 获取可用的星盘制式列表
  List<PanelSystemType> get availablePanelSystemTypes {
    if (!_isLoaded) return [];
    return _mapper.values
        .map((model) => model.panelSystemType)
        .toSet()
        .toList();
  }

  /// 获取可用的星宿类型列表
  List<ConstellationSystemType> get availableConstellationSystemTypes {
    if (!_isLoaded) return [];
    return _mapper.values
        .map((model) => model.constellationSystemType)
        .toSet()
        .toList();
  }

  /// 重新加载数据
  Future<void> reload() async {
    clear();
    await load();
  }

  /// 根据条件查询模型
  List<ZhouTianModel> queryModels({
    CelestialCoordinateSystem? systemType,
    PanelSystemType? panelSystemType,
    ConstellationSystemType? constellationSystemType,
  }) {
    if (!_isLoaded) return [];

    return _mapper.values.where((model) {
      if (systemType != null && model.systemType != systemType) return false;
      if (panelSystemType != null && model.panelSystemType != panelSystemType) {
        return false;
      }
      if (constellationSystemType != null &&
          model.constellationSystemType != constellationSystemType) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ConstellationMappingResult> calculateZhouTianMapper(
      ZhouTianModel zhouTian) {
    if (zhouTian.starInnOrder.first !=
        zhouTian.zeroPointAtConstellation.constellation) {
      throw Exception("起始星宿必须与0°星宿一致");
    }
    if (zhouTian.gongOrder.first != zhouTian.zeroPointAtGong.gong) {
      throw Exception("起始宫位必须与0°宫位一致");
    }

    return ZhouTianCalculator(zhouTianModel: zhouTian)
        .mapConstellationsToPalaces();
  }

  /// 清空数据
  void clear() {
    _mapper.clear();
    _isLoaded = false;
  }

  /// 用于测试：从外部设置 `Map<String, ZhouTianModel>`
  void setModelsForTesting(Map<String, ZhouTianModel> models) {
    _mapper.clear();
    _mapper.addAll(models);
    _isLoaded = true;
  }

  /// 用于测试：直接添加单个模型
  void addModelForTesting(ZhouTianModel model) {
    final key = _createMapperKey(
        model.systemType, model.panelSystemType, model.constellationSystemType);
    _mapper[key] = model;
    _isLoaded = true;
  }

  /// 用于测试：获取内部mapper的副本
  Map<String, ZhouTianModel> getMapperForTesting() {
    return Map.from(_mapper);
  }
}
