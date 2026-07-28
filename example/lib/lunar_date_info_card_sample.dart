import 'package:flutter/material.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/datetime_details_bundle_logic_model.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:metaphysics_core/models/seventy_two_phenology.dart';
import 'package:qizhengsiyu/presentation/models/lunar_date_info_v2_data.dart';
import 'package:qizhengsiyu/presentation/widgets/lunar_date_info_card_v2.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  runApp(const LunarDateInfoCardSampleApp());
}

class LunarDateInfoCardSampleApp extends StatelessWidget {
  const LunarDateInfoCardSampleApp({super.key});

  static final _chineseDateInfo = ChineseDateInfo(
    eightChars: EightChars.defualtBaZi(),
    phenology: Phenology.phenologyList.firstWhere(
      (phenology) =>
          phenology.jieqi == TwentyFourJieQi.DONG_ZHI && phenology.order == 1,
    ),
    lunarMonth: 11,
    lunarDay: 15,
    isLeapMonth: false,
    jieQiInfo: JieQiInfo(
      jieQi: TwentyFourJieQi.DONG_ZHI,
      startAt: DateTime(2023, 12, 22),
      endAt: DateTime(2024, 1, 6),
    ),
    threeYuan: YuanYunOrder.upper,
    nineYun: NineYun.first,
  );

  static final _standardDatetime = tz.TZDateTime(
    tz.getLocation('Asia/Shanghai'),
    2023,
    12,
    27,
    12,
  );

  static final _data = LunarDateInfoV2Data(
    bundle: DateTimeDetailsBundleLogicModel(
      calculationConfig: CalculationStrategyConfigLogicModel.defaultConfig,
      standeredDatetime: _standardDatetime,
      standeredChineseInfo: _chineseDateInfo,
      utcDatetime: _standardDatetime.toUtc(),
      timezoneStr: 'Asia/Shanghai',
      coordinates: Coordinates(latitude: 39.9042, longitude: 116.4074),
    ),
    inUsed: EnumDatetimeType.standard,
    cardChipTagStr: '静态示例',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LunarDateInfoCardV2(data: _data),
            ),
          ),
        ),
      ),
    );
  }
}
