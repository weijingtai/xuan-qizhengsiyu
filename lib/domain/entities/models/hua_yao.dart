import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';

part 'hua_yao.g.dart';

@JsonSerializable()
class HuaYao extends ShenSha {
  ShenShaType type;
  HuaYao(super.name, super.jiXiong, super.descriptionList,
      super.locationDescriptionList, this.type);

  factory HuaYao.fromJson(Map<String, dynamic> json) => _$HuaYaoFromJson(json);
  Map<String, dynamic> toJson() => _$HuaYaoToJson(this);
}

@JsonSerializable()
class HuaYaoItem extends HuaYao {
  // ShenShaType type;
  // HuaYaoItem(super.name, super.jiXiong, super.descriptionList,
  // super.locationDescriptionList, super.type);
  HuaYaoItem({
    required String name,
    required JiXiongEnum jiXiong,
    required ShenShaType type,
  }) : super(name, jiXiong, null, null, type);
  factory HuaYaoItem.fromJson(Map<String, dynamic> json) =>
      _$HuaYaoItemFromJson(json);
  Map<String, dynamic> toJson() => _$HuaYaoItemToJson(this);

  static HuaYaoItem fromHuaYao(HuaYao huaYao) {
    return HuaYaoItem(
      name: huaYao.name,
      jiXiong: huaYao.jiXiong,
      type: huaYao.type,
    );
  }
}

@JsonSerializable()
class OthersHuaYao extends HuaYao {
  OthersHuaYao(super.name, super.jiXiong, super.descriptionList,
      super.locationDescriptionList, super.type);

  factory OthersHuaYao.fromJson(Map<String, dynamic> json) =>
      _$OthersHuaYaoFromJson(json);
  Map<String, dynamic> toJson() => _$OthersHuaYaoToJson(this);
}

@JsonSerializable()
class TianGanHuaYao extends HuaYao {
  // ShenShaType type;
  Map<TianGan, EnumStars> locationMapper;

  TianGanHuaYao(super.name, super.jiXiong, super.descriptionList,
      super.locationDescriptionList, super.type, this.locationMapper);

  factory TianGanHuaYao.fromJson(Map<String, dynamic> json) =>
      _$TianGanHuaYaoFromJson(json);
  Map<String, dynamic> toJson() => _$TianGanHuaYaoToJson(this);
}

@JsonSerializable()
class DiZhiHuaYao extends HuaYao {
  // ShenShaType type;
  Map<DiZhi, EnumStars> locationMapper;

  DiZhiHuaYao(super.name, super.jiXiong, super.descriptionList,
      super.locationDescriptionList, super.type, this.locationMapper);

  factory DiZhiHuaYao.fromJson(Map<String, dynamic> json) =>
      _$DiZhiHuaYaoFromJson(json);
  Map<String, dynamic> toJson() => _$DiZhiHuaYaoToJson(this);
}

@Deprecated("废弃")
@JsonSerializable()
class HuaYaoStarPair {
  final HuaYao huaYao;
  final EnumStars star;

  HuaYaoStarPair(this.huaYao, this.star);

  factory HuaYaoStarPair.fromJson(Map<String, dynamic> json) =>
      _$HuaYaoStarPairFromJson(json);
  Map<String, dynamic> toJson() => _$HuaYaoStarPairToJson(this);
}
