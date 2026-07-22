import 'package:flutter/material.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/datetime_details_bundle_logic_model.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';

import '../theme/gan_zhi_gua_colors.dart';

/// Local UI data model for [LunarDateInfoCardV2].
///
/// Contains only the fields read by the widget. No JSON generation.
class LunarDateInfoV2Data {
  final DateTimeDetailsBundleLogicModel bundle;
  final EnumDatetimeType inUsed;
  final bool isHiddenDatetimeType;
  final String? cardChipTagStr;

  const LunarDateInfoV2Data({
    required this.bundle,
    required this.inUsed,
    this.isHiddenDatetimeType = false,
    this.cardChipTagStr,
  });

  ChineseDateInfo? get chineseDateInfo {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredChineseInfo;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTChineseInfo;
      case EnumDatetimeType.politicalCenter:
        return bundle.politicalCenterChineseInfo;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarChineseInfo;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarChineseInfo;
    }
  }

  DateTime? get dateTime {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredDatetime;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTDatetime;
      case EnumDatetimeType.politicalCenter:
        return bundle.politicalCenterDatetime;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarDatetime;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarDatetime;
    }
  }

  Color get mainlyTextThemeColor =>
      GanZhiGuaColors.zodiacZhiColors[chineseDateInfo!.eightChars.month.diZhi]!;

  Color get timingTextThemeColor =>
      GanZhiGuaColors.zodiacZhiColors[chineseDateInfo!.eightChars.time.diZhi]!;
}
