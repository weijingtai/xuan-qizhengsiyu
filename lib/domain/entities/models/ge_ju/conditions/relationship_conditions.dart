import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:common/utils/collections_utils.dart';

/// 辅助方法：从 JSON 解析星曜列表
List<EnumStars> _parseStars(List<dynamic> jsonList) {
  return jsonList
      .map((e) => EnumStars.getBySingleName(e) ?? EnumStars.values.byName(e))
      .toList();
}

/// T-011: 多星同宫条件
/// stars: 星曜列表（通常为2颗或更多）
class SameGongCondition extends GeJuCondition {
  final List<EnumStars> stars;

  SameGongCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    if (stars.length < 2) return true; // 单星无“同宫”概念，默认为真或由业务定义

    // 方法1：直接比较每颗星的宫位（简单直观）
    // 方法2：使用 starRelationship.sameGongMap（性能优化）
    // 这里采用方法1以保证 robustness，避免依赖 map key 必须存在

    final firstGong = input.getStarGong(stars.first);
    if (firstGong == null) return false;

    for (int i = 1; i < stars.length; i++) {
      final gong = input.getStarGong(stars[i]);
      if (gong != firstGong) return false;
    }
    return true;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}同宫";
  }

  factory SameGongCondition.fromJson(Map<String, dynamic> json) {
    return SameGongCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'sameGong',
        'stars': stars.map((e) => e.name).toList(),
      };
}

/// T-012: 多星同宿条件
class SameConstellationCondition extends GeJuCondition {
  final List<EnumStars> stars;

  SameConstellationCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    if (stars.length < 2) return true;

    final firstInn = input.getStarConstellation(stars.first);
    if (firstInn == null) return false;

    for (int i = 1; i < stars.length; i++) {
      final inn = input.getStarConstellation(stars[i]);
      if (inn != firstInn) return false;
    }
    return true;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}同宿";
  }

  factory SameConstellationCondition.fromJson(Map<String, dynamic> json) {
    return SameConstellationCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'sameConstellation',
        'stars': stars.map((e) => e.name).toList(),
      };
}

/// T-013: 星曜对照（对宫）条件
/// 通常指 star1 与 star2 在对冲位置
class OppositeGongCondition extends GeJuCondition {
  final EnumStars starA;
  final EnumStars starB;

  OppositeGongCondition(this.starA, this.starB);

  @override
  bool evaluate(GeJuInput input) {
    return input.isOpposite(starA, starB);
  }

  @override
  String describe() {
    return "${starA.singleName}${starB.singleName}对照";
  }

  factory OppositeGongCondition.fromJson(Map<String, dynamic> json) {
    final stars = _parseStars(json['stars']);
    if (stars.length != 2)
      throw ArgumentError("OppositeGongCondition requires exactly 2 stars");
    return OppositeGongCondition(stars[0], stars[1]);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'oppositeGong',
        'stars': [starA.name, starB.name],
      };
}

/// T-014: 星曜三合条件
/// 指 starA, starB (, starC) 处于三合宫位
class TrineGongCondition extends GeJuCondition {
  final List<EnumStars> stars;

  TrineGongCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    if (stars.length < 2) return false;

    // 取第一颗星的 Trine 列表
    final gong1 = input.getStarGong(stars.first);
    if (gong1 == null) return false;

    final trineGongs =
        gong1.otherTringleGongList; // 它是一个 getter，返回 List<EnumTwelveGong>
    // 包含本宫的三合局列表
    final validGongs = [gong1, ...trineGongs];

    // 检查其余星是否都在 validGongs 中
    for (int i = 1; i < stars.length; i++) {
      final gong = input.getStarGong(stars[i]);
      if (gong == null || !validGongs.contains(gong)) return false;
    }

    // 如果是三颗星，通常要求占据三合的三个不同顶点？或者只是“在三合关系中”即可？
    // 古籍中“三方拱照”通常指 A在B的三方。这里实现为：所有星都在同一个三合三角形内。
    return true;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}三合";
  }

  factory TrineGongCondition.fromJson(Map<String, dynamic> json) {
    return TrineGongCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'trineGong',
        'stars': stars.map((e) => e.name).toList(),
      };
}

/// T-015: 星曜四正条件
class SquareGongCondition extends GeJuCondition {
  final List<EnumStars> stars;

  SquareGongCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    if (stars.length < 2) return false;

    final gong1 = input.getStarGong(stars.first);
    if (gong1 == null) return false;

    final squareGongs = gong1.otherSquareGongList;
    final validGongs = [gong1, ...squareGongs];

    for (int i = 1; i < stars.length; i++) {
      final gong = input.getStarGong(stars[i]);
      if (gong == null || !validGongs.contains(gong)) return false;
    }
    return true;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}四正";
  }

  factory SquareGongCondition.fromJson(Map<String, dynamic> json) {
    return SquareGongCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'squareGong',
        'stars': stars.map((e) => e.name).toList(),
      };
}

/// T-016: 星曜同经条件
/// 指星曜位于同一宿度经度（或特定的同经定义）
class SameJingCondition extends GeJuCondition {
  final List<EnumStars> stars;

  SameJingCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    // 依赖 starRelationship.sameJingMap
    // input.starRelationship.sameJingMap 结构: Map<EnumStars, Map<Enum28Constellations, Set<ElevenStarsInfo>>>
    // 这个 Map 结构似乎是 "对于每个星，它同经的星列表"

    if (stars.length < 2) return true;

    final baseStar = stars.first;
    final sameJingInfo = input.starRelationship.sameJingMap[baseStar];

    if (sameJingInfo == null || sameJingInfo.isEmpty) return false;

    // 收集所有同经的星 list
    // sameJingMap 的 value 是 Map<Constellation, Set<Stars>>，需要把 Set 里的星提取出来
    final allSameJingStars = <EnumStars>{};
    for (var set in sameJingInfo.values) {
      for (var info in set) {
        allSameJingStars.add(info.star);
      }
    }

    // 检查其余星是否在同经列表中
    for (int i = 1; i < stars.length; i++) {
      if (!allSameJingStars.contains(stars[i])) return false;
    }
    return true;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}同经";
  }

  factory SameJingCondition.fromJson(Map<String, dynamic> json) {
    return SameJingCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'sameJing',
        'stars': stars.map((e) => e.name).toList(),
      };
}

/// T-017: 星曜同络条件
class SameLuoCondition extends GeJuCondition {
  final List<EnumStars> stars;

  SameLuoCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    // 依赖 sameLuoSet: Set<Set<ElevenStarsInfo>>
    // 遍历集合，找到包含 stars 中任意一颗星的那个 Set，然后看其他星是否也在该 Set 中

    if (stars.length < 2) return true;

    for (var luoSet in input.starRelationship.sameLuoSet) {
      // 提取出当前同络组的所有 EnumStars
      final luoStars = luoSet.map((e) => e.star).toSet();

      // 检查是否所有目标星都在这个组里
      bool allIn = true;
      for (var s in stars) {
        if (!luoStars.contains(s)) {
          allIn = false;
          break;
        }
      }
      if (allIn) return true;
    }

    return false;
  }

  @override
  String describe() {
    return "${stars.map((e) => e.singleName).join("")}同络";
  }

  factory SameLuoCondition.fromJson(Map<String, dynamic> json) {
    return SameLuoCondition(_parseStars(json['stars']));
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'sameLuo',
        'stars': stars.map((e) => e.name).toList(),
      };
}
