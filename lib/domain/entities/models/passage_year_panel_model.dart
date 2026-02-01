import 'package:common/enums.dart';
import 'package:common/models/shen_sha.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../enums/enum_twelve_gong.dart';
import 'hua_yao.dart';
import 'star_angle_speed.dart';
import 'star_enter_info.dart';
import 'stars_angle.dart';

part 'passage_year_panel_model.g.dart';

@JsonSerializable()
class PassageYearPanelModel {
  // 1. 流年星体原始信息
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;
  // 2. 计算星体进入宫位信息
  final Map<EnumStars, EnteredInfo> enteredGongMapper;
  // 3. 计算五星运行状态
  final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper;

  // 6. 计算神煞位置
  final Map<EnumTwelveGong, List<ShenSha>> shenShaItemMapper;

  // 7. 计算化曜
  // final Map<HuaYao, EnumStars> huaYaoMapper;
  final Map<EnumStars, List<HuaYaoItem>> huaYaoItemMapper;

  // 8. 计算十二长生
  final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper;

  PassageYearPanelModel({
    required this.starAngleMapper,
    required this.enteredGongMapper,
    required this.fiveStarWalkingTypeMapper,
    required this.shenShaItemMapper,
    required this.huaYaoItemMapper,
    required this.twelveZhangShengGongMapper,
  });

  factory PassageYearPanelModel.fromJson(Map<String, dynamic> json) =>
      _$PassageYearPanelModelFromJson(json);

  Map<String, dynamic> toJson() => _$PassageYearPanelModelToJson(this);

  PassageYearPanelModel copyWith({
    Map<EnumStars, StarAngleSpeed>? starAngleMapper,
    Map<EnumStars, EnteredInfo>? enteredGongMapper,
    Map<EnumStars, BaseFiveStarWalkingInfo>? fiveStarWalkingTypeMapper,
    Map<EnumTwelveGong, EnumDestinyTwelveGong>? twelveGongMapper,
    Map<EnumTwelveGong, List<ShenSha>>? shenShaItemMapper,
    Map<EnumStars, List<HuaYaoItem>>? huaYaoItemMapper,
    Map<EnumTwelveGong, TwelveZhangSheng>? twelveZhangShengGongMapper,
  }) {
    return PassageYearPanelModel(
      starAngleMapper: starAngleMapper ?? this.starAngleMapper,
      enteredGongMapper: enteredGongMapper ?? this.enteredGongMapper,
      fiveStarWalkingTypeMapper:
          fiveStarWalkingTypeMapper ?? this.fiveStarWalkingTypeMapper,
      shenShaItemMapper: shenShaItemMapper ?? this.shenShaItemMapper,
      huaYaoItemMapper: huaYaoItemMapper ?? this.huaYaoItemMapper,
      twelveZhangShengGongMapper:
          twelveZhangShengGongMapper ?? this.twelveZhangShengGongMapper,
    );
  }
}
