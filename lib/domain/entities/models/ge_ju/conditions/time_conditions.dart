import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_four_seasons.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';

/// T-026: 季节条件
class SeasonIsCondition extends GeJuCondition {
  final List<FourSeasons> seasons;

  SeasonIsCondition(this.seasons);

  @override
  bool evaluate(GeJuInput input) {
    return seasons.contains(input.season);
  }

  @override
  String describe() {
    return "生于${seasons.map((e) => e.name).join("/")}";
  }

  factory SeasonIsCondition.fromJson(Map<String, dynamic> json) {
    return SeasonIsCondition((json['seasons'] as List)
        .map((e) => FourSeasons.values.firstWhere(
            (v) => v.name == e || v.toString().split('.').last == e))
        .toList());
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'seasonIs',
        'seasons': seasons.map((e) => e.name).toList(),
      };
}

/// T-027: 昼夜生条件
class IsDayBirthCondition extends GeJuCondition {
  final bool isDay;

  IsDayBirthCondition(this.isDay);

  @override
  bool evaluate(GeJuInput input) {
    return input.isDayBirth == isDay;
  }

  @override
  String describe() {
    return isDay ? "昼生" : "夜生";
  }

  factory IsDayBirthCondition.fromJson(Map<String, dynamic> json) {
    return IsDayBirthCondition(json['isDay'] as bool);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'isDayBirth',
        'isDay': isDay,
      };
}

/// T-028: 月相条件
class MoonPhaseIsCondition extends GeJuCondition {
  final List<EnumMoonPhases> phases;

  MoonPhaseIsCondition(this.phases);

  @override
  bool evaluate(GeJuInput input) {
    return phases.contains(input.moonPhase);
  }

  @override
  String describe() {
    return "月相为${phases.map((e) => e.name).join("/")}";
  }

  factory MoonPhaseIsCondition.fromJson(Map<String, dynamic> json) {
    return MoonPhaseIsCondition((json['phases'] as List)
        .map((e) => EnumMoonPhases.values.firstWhere(
            (v) => v.name == e || v.toString().split('.').last == e))
        .toList());
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'moonPhaseIs',
        'phases': phases.map((e) => e.name).toList(),
      };
}

/// T-029: 出生月地支条件
class MonthIsCondition extends GeJuCondition {
  final List<DiZhi> months;

  MonthIsCondition(this.months);

  @override
  bool evaluate(GeJuInput input) {
    return months.contains(input.monthZhi);
  }

  @override
  String describe() {
    return "生于${months.map((e) => e.name).join("/")}月";
  }

  factory MonthIsCondition.fromJson(Map<String, dynamic> json) {
    return MonthIsCondition(
        (json['months'] as List).map((e) => DiZhi.getFromValue(e)!).toList());
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'monthIs',
        'months': months.map((e) => e.name).toList(),
      };
}
