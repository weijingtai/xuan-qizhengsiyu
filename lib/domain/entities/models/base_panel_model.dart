import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../enums/enum_twelve_gong.dart';
import 'body_life_model.dart';
import 'hua_yao.dart';
import 'star_angle_speed.dart';
import 'star_enter_info.dart';
import 'stars_angle.dart';

part 'base_panel_model.g.dart';

@JsonSerializable()
class BasePanelModel {
  // 1. 星体原始信息
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;
  // 2. 计算星体进入宫位信息
  final Map<EnumStars, EnteredInfo> enteredGongMapper;
  // 3. 计算五星运行状态
  final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper;

  // 4. 计算四主（命宫主、身宫主、命度主、身度主）
  final BodyLifeModel bodyLifeModel;

  // 5. 计算命理十二宫
  final Map<EnumTwelveGong, EnumDestinyTwelveGong> twelveGongMapper;
  // 6. 计算神煞位置
  final Map<EnumTwelveGong, List<ShenSha>> shenShaItemMapper;

  // 7. 计算化曜 - 改写为按星体分组的化曜映射
  final Map<EnumStars, List<HuaYaoItem>> huaYaoItemMapper;

  // 8. 计算十二长生
  final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper;

  BasePanelModel({
    required this.starAngleMapper,
    required this.enteredGongMapper,
    required this.fiveStarWalkingTypeMapper,
    required this.bodyLifeModel,
    required this.twelveGongMapper,
    required this.shenShaItemMapper,
    required this.huaYaoItemMapper,
    required this.twelveZhangShengGongMapper,
  });

  factory BasePanelModel.fromJson(Map<String, dynamic> json) =>
      _$BasePanelModelFromJson(json);

  Map<String, dynamic> toJson() => _$BasePanelModelToJson(this);

  BasePanelModel copyWith({
    Map<EnumStars, StarAngleSpeed>? starAngleMapper,
    Map<EnumStars, EnteredInfo>? enteredGongMapper,
    Map<EnumStars, BaseFiveStarWalkingInfo>? fiveStarWalkingTypeMapper,
    BodyLifeModel? bodyLifeModel,
    Map<EnumTwelveGong, EnumDestinyTwelveGong>? twelveGongMapper,
    Map<EnumTwelveGong, List<ShenSha>>? shenShaItemMapper,
    Map<EnumStars, List<HuaYaoItem>>? huaYaoItemMapper,
    Map<EnumTwelveGong, TwelveZhangSheng>? twelveZhangShengGongMapper,
  }) {
    return BasePanelModel(
      starAngleMapper: starAngleMapper ?? this.starAngleMapper,
      enteredGongMapper: enteredGongMapper ?? this.enteredGongMapper,
      fiveStarWalkingTypeMapper:
          fiveStarWalkingTypeMapper ?? this.fiveStarWalkingTypeMapper,
      bodyLifeModel: bodyLifeModel ?? this.bodyLifeModel,
      twelveGongMapper: twelveGongMapper ?? this.twelveGongMapper,
      shenShaItemMapper: shenShaItemMapper ?? this.shenShaItemMapper,
      huaYaoItemMapper: huaYaoItemMapper ?? this.huaYaoItemMapper,
      twelveZhangShengGongMapper:
          twelveZhangShengGongMapper ?? this.twelveZhangShengGongMapper,
    );
  }

  // 辅助方法：从旧的List<HuaYaoStarPair>转换为新的Map<EnumStars, List<HuaYao>>
  static Map<EnumStars, List<HuaYao>> convertHuaYaoStarPairListToMap(
      List<HuaYaoStarPair> huaYaoStarPairList) {
    final Map<EnumStars, List<HuaYao>> huaYaoItemMapper = {};

    for (final pair in huaYaoStarPairList) {
      if (huaYaoItemMapper.containsKey(pair.star)) {
        huaYaoItemMapper[pair.star]!.add(pair.huaYao);
      } else {
        huaYaoItemMapper[pair.star] = [pair.huaYao];
      }
    }

    return huaYaoItemMapper;
  }

  // 辅助方法：从新的Map<EnumStars, List<HuaYao>>转换为旧的List<HuaYaoStarPair>
  static List<HuaYaoStarPair> convertHuaYaoMapToStarPairList(
      Map<EnumStars, List<HuaYao>> huaYaoItemMapper) {
    final List<HuaYaoStarPair> huaYaoStarPairList = [];

    huaYaoItemMapper.forEach((star, huaYaoList) {
      for (final huaYao in huaYaoList) {
        huaYaoStarPairList.add(HuaYaoStarPair(huaYao, star));
      }
    });

    return huaYaoStarPairList;
  }
}
