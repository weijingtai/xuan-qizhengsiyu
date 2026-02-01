import 'package:common/datamodel/location.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:flutter/widgets.dart';
import 'package:qizhengsiyu/enums/enum_panel_ring.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

/// 命盘配置视图模型
///
/// 负责管理七政四余命盘配置的状态和逻辑
class PanelConfigViewModel extends ChangeNotifier {
  // 配置类型

  EnumQueryType _configType = EnumQueryType.destiny;

  // 基本人物信息（用于命理运势）
  BasicPersonInfo? _basicPersonInfo;

  // 占卜信息（用于占卜事情）
  BasicDivination? _divinationInfo;

  // 位置信息
  Address? _location;

  // 自定义配置
  late PanelConfig _customConfig;
  BuildContext context;

  /// 构造函数
  ///
  /// [initialConfig] 初始配置，用于恢复上次的设置
  PanelConfigViewModel(this.context) {
    _customConfig = PanelConfigViewModel.getPreviousPanelConfig();
    // 如果没有位置信息，设置一个默认地址，避免校验阻塞
    _location ??= Address.defualtAddress;
    // if (initialConfig != null) {
    //   _configType = initialConfig.configType;
    //   _customConfig = initialConfig.customConfig;
    //   _location = initialConfig.location;

    //   if (initialConfig.queryType == EnumQueryType.destiny) {
    //     _basicPersonInfo = initialConfig.basicPersonInfo;
    //   } else {
    //     _divinationInfo = initialConfig.divinationInfo;
    //   }
    // } else {
    //   // 设置默认值
    //   _basicPersonInfo = BasicPersonInfo(
    //       name: null,
    //       gender: Gender.unknown,
    //       birthTime,
    //       birthLocation,
    //       trueSolarTime,
    //       bazi: BaZi.defualtBaZi,
    //       hasDaylightSaving,
    //       isTrueSolarTime);

    //   _divinationInfo = BasicDivination(
    //     question: "",
    //     divinationAt: DateTime.now(),
    //     details: null,
    //     divinationPerson: null,
    //   );

    //   _location = Location(
    //     country: '中国',
    //     province: '北京',
    //     city: '北京',
    //     timezone: 'Asia/Shanghai',
    //     // hasDaylightSaving: false,
    //     // isTrueSolarTime: false,
    //     coordinates: Coordinates(latitude: 39.9042, longitude: 116.4074),
    //   );
    // }
  }

  /// 获取配置类型
  EnumQueryType get configType => _configType;

  /// 获取基本人物信息
  BasicPersonInfo? get basicPersonInfo => _basicPersonInfo;

  /// 获取占卜信息
  BasicDivination? get divinationInfo => _divinationInfo;

  /// 获取位置信息
  Address? get location => _location;

  /// 获取自定义配置
  PanelConfig get customConfig => _customConfig;

  /// 更新配置类型
  void updateQueryType(EnumQueryType configType) {
    _configType = configType;
    notifyListeners();
  }

  /// 更新基本信息
  void updateBasicInfo(dynamic info) {
    if (info is BasicPersonInfo) {
      _basicPersonInfo = info;
    } else if (info is BasicDivination) {
      _divinationInfo = info;
    }
  }

  /// 更新位置信息
  void updateLocation(Address location) {
    _location = location;
  }

  /// 更新自定义配置
  void updateCustomConfig(PanelConfig customConfig) {
    _customConfig = customConfig;
  }

  /// 更新流派类型
  void updateSchoolType(EnumSchoolType schoolType) {
    // 根据流派类型更新默认配置
    // _customConfig = _customConfig.copyWith(schoolType: schoolType);

    // 根据不同流派设置默认值
    // switch (schoolType) {
    //   case EnumSchoolType.QinTang:
    //     _customConfig = _customConfig.copyWith(
    //       coordinateSystem: CelestialCoordinateSystem.equatorial,
    //       classicBooks: ['星学大成'],
    //     );
    //     break;
    //   case EnumSchoolType.GuoLao:
    //     _customConfig = _customConfig.copyWith(
    //       coordinateSystem: CoordinateSystemType.Ecliptic,
    //       classicBooks: ['果老星宗'],
    //     );
    //     break;
    //   case EnumSchoolType.TianGuan:
    //     _customConfig = _customConfig.copyWith(
    //       coordinateSystem: CoordinateSystemType.Ecliptic,
    //       classicBooks: ['天官星经'],
    //     );
    //     break;
    //   case EnumSchoolType.Customerized:
    //     // 自定义流派保持当前设置
    //     break;
    // }
  }

  /// 构建完整的配置对象
  PanelConfig buildConfig() {
    // 如果位置信息为空，使用默认地址
    if (_location == null) {
      _location = Address.defualtAddress;
    }

    if (_configType == EnumQueryType.destiny && _basicPersonInfo == null) {
      throw Exception('命理运势模式下，基本人物信息不能为空');
    }

    if (_configType == EnumQueryType.divination && _divinationInfo == null) {
      throw Exception('占卜事情模式下，占卜信息不能为空');
    }

    // 当前版本仅返回自定义配置，后续可融合其他字段
    return _customConfig;
  }

  /// 验证配置是否完整
  bool validateConfig() {
    try {
      buildConfig();
      return true;
    } catch (e) {
      return false;
    }
  }

  static PanelConfig getPreviousPanelConfig() {
    // TODO: 从数据库恢复用户上次配置；当前返回默认配置
    return PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.tropical,
      constellationSystemType: ConstellationSystemType.classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
    );
  }

  PanelConfig getCustomConfig() {
    return _customConfig;
  }

  //   return PanelConfig(
  //       queryType: EnumQueryType.destiny,
  //       coordinateSystem: CoordinateSystemType.Ecliptic,
  //       starInnSystem: PanelSystem.Tropical,
  //       starInnType: StarInnType.Mordern,
  //       schoolType: EnumSchoolType.GuoLao,
  //       settleLifeType: EnumSettleLifeType.Mao,
  //       settleBodyType: EnumSettleBodyType.moon,
  //       withAscendant: false,
  //       huaYaoType: EnumHuaYaoType.Both,
  //       uiPanelRingOrder: UIEnumPanelRing.moria,
  //       classicBooks: ["1.《果老星宗》"]);
  // }
}
