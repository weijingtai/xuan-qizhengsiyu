import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';

import '../../../enums/enum_twelve_gong.dart';
import 'eleven_stars_info.dart';

part 'gong_model.g.dart';

@JsonSerializable()
class GongModel {
  EnumTwelveGong gong;
  EnumDestinyTwelveGong destinyGong;
  List<ElevenStarsInfo> enteredStars;
  ElevenStarsInfo masterStars;

  TwelveZhangSheng zhangSheng;
  EnumBeforeTaiSuiShenSha beforeTaiSuiCirclingSha;
  EnumAfterTaiSuiShenSha afterTaiSuiCirclingSha;
  Set<TianGanShenSha> tianGanShenShaSet;
  Set<DiZhiShenSha> diZhiShenShaSet;
  Set<ShenSha> otherShenShaSet;
  GongModel(
      {required this.gong,
      required this.destinyGong,
      required this.enteredStars,
      required this.masterStars,
      required this.zhangSheng,
      required this.beforeTaiSuiCirclingSha,
      required this.afterTaiSuiCirclingSha,
      required this.diZhiShenShaSet,
      required this.tianGanShenShaSet,
      required this.otherShenShaSet});

  factory GongModel.fromJson(Map<String, dynamic> json) =>
      _$GongModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GongModelToJson(this);
}
