// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navigatorParamError => '参数错误';

  @override
  String get navigatorUnknownPage => '奇门遁甲_未知页面';

  @override
  String get geJuDetail => '格局详情';

  @override
  String get edit => '编辑';

  @override
  String get copy => '复制';

  @override
  String get saveAs => '另存为';

  @override
  String get copyJson => '复制JSON';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get ruleNotFound => '格局不存在';

  @override
  String get copiedToClipboard => 'JSON 已复制到剪贴板';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteRule(String name) {
    return '确定要删除格局 \"$name\" 吗？此操作不可撤销。';
  }

  @override
  String get cancel => '取消';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get deleteAnnotation => '删除注解';

  @override
  String get confirmDeleteAnnotation => '确定要删除该注解吗？';

  @override
  String get deleteConditionSet => '删除判断方案';

  @override
  String confirmDeleteConditionSet(String label) {
    return '确定要删除方案 \"$label\" 吗？';
  }
}
