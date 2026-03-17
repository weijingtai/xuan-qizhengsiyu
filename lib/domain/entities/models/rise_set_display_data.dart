/// 日月出没展示数据模型
///
/// 纯 display DTO，用于 RiseSetInfoPanel 展示。
class RiseSetDisplayData {
  /// 日出时刻（本地时区）
  final DateTime? sunRise;

  /// 日落时刻（本地时区）
  final DateTime? sunSet;

  /// 月出时刻（本地时区）
  final DateTime? moonRise;

  /// 月落时刻（本地时区）
  final DateTime? moonSet;

  /// 真太阳时
  final DateTime? trueSolarTime;

  /// 观测点经度
  final double longitude;

  /// 观测点纬度
  final double latitude;

  /// 时区标识
  final String timezone;

  /// 阴历日期字符串，如 "丁卯年四月初七日"
  final String lunarDateString;

  /// 阴历时辰字符串，如 "巳时"
  final String lunarTimeString;

  /// 是否昼生
  final bool isDayBirth;

  /// 四柱显示文本
  final String fourPillarsDisplay;

  /// 观测本地时间
  final DateTime localDateTime;

  /// 地点名称，如 "成都, 中国 四川"
  final String? locationName;

  /// 节气信息，如 "谷雨"
  final String? jieQiInfo;

  const RiseSetDisplayData({
    this.sunRise,
    this.sunSet,
    this.moonRise,
    this.moonSet,
    this.trueSolarTime,
    required this.longitude,
    required this.latitude,
    required this.timezone,
    required this.lunarDateString,
    required this.lunarTimeString,
    required this.isDayBirth,
    required this.fourPillarsDisplay,
    required this.localDateTime,
    this.locationName,
    this.jieQiInfo,
  });
}
