import 'package:flutter/material.dart';
import 'package:metaphysics_core/domain/calculators/liu_yun/models/yun_liu_display_models.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:enumeration/enums.dart';
import 'package:metaphysics_core/enums/enum_tian_gan.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';

@Deprecated("Migrated to calendar package. Use package:calendar/calendar.dart instead.")
class YunLiuViewModel extends ChangeNotifier {
  final YunLiuUseCase _useCase;

  // --- Input Config ---
  final DateTime birthDateTime;
  final Gender gender;
  final ChineseDateInfo birthDateInfo;
  final DateTime referenceDate;

  // --- Business Data ---
  List<DaYunDisplayData> _daYunList = [];
  List<DaYunDisplayData> get daYunList => _daYunList;

  // --- Interaction State ---
  int? _selectedDaYunIdx;
  int? get selectedDaYunIdx => _selectedDaYunIdx;

  int? _selectedLiuNianIdx;
  int? get selectedLiuNianIdx => _selectedLiuNianIdx;

  int? _selectedLiuYueIdx;
  int? get selectedLiuYueIdx => _selectedLiuYueIdx;

  int? _selectedLiuRiDay;
  int? get selectedLiuRiDay => _selectedLiuRiDay;

  int? _selectedLiuShiIdx;
  int? get selectedLiuShiIdx => _selectedLiuShiIdx;

  // --- Cache ---
  final Map<String, List<LiuRiDisplayData>> _liuRiCache = {};
  final Map<String, List<LiuShiDisplayData>> _liuShiCache = {};

  // --- View State ---
  bool _isMiniMode = false;
  bool get isMiniMode => _isMiniMode;

  bool _isHorizontal = true;
  bool get isHorizontal => _isHorizontal;

  bool _isExplicitlyCollapsed = false;
  bool get isAllCollapsed => _isExplicitlyCollapsed;

  YunLiuViewModel({
    required YunLiuUseCase useCase,
    required this.birthDateTime,
    required this.gender,
    required this.birthDateInfo,
    DateTime? referenceDate,
  })  : _useCase = useCase,
        referenceDate = referenceDate ?? DateTime.now() {
    _init();
  }

  void _init() {
    _daYunList = _useCase.calculateDaYunList(
      birthDateTime: birthDateTime,
      gender: gender,
      birthDateInfo: birthDateInfo,
    );
    jumpToTargetDateTime(referenceDate);
  }

  // --- Actions ---

  void selectDaYun(int index) {
    if (index == _selectedDaYunIdx) return;
    _selectedDaYunIdx = index;
    _selectedLiuNianIdx = 0;
    _selectedLiuYueIdx = 0;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuNian(int idx) {
    _selectedLiuNianIdx = idx;
    _selectedLiuYueIdx = 0;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuYue(int idx) {
    _selectedLiuYueIdx = idx;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuRi(int day) {
    _selectedLiuRiDay = day;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuShi(int idx) {
    _selectedLiuShiIdx = idx;
    notifyListeners();
  }

  void toggleMiniMode() {
    _isMiniMode = !_isMiniMode;
    notifyListeners();
  }

  void toggleOrientation() {
    _isHorizontal = !_isHorizontal;
    notifyListeners();
  }

  void collapseAll() {
    _isExplicitlyCollapsed = true;
    notifyListeners();
  }

  void expandAll() {
    _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  /// Jumps to a specific date and time, synchronizing all levels of the list.
  /// Automatically syncs indices with the target date (e.g. Back to Today).
  void jumpToTargetDateTime(DateTime target) {
    final targetYear = target.year;
    final targetMonth = target.month;

    for (int i = 0; i < _daYunList.length; i++) {
      final dy = _daYunList[i];
      if (targetYear >= dy.startYear &&
          targetYear < dy.startYear + dy.yearsCount) {
        _selectedDaYunIdx = i;
        for (int j = 0; j < dy.liunian.length; j++) {
          final ln = dy.liunian[j];
          if (ln.year == targetYear) {
            _selectedLiuNianIdx = j;
            for (int k = 0; k < ln.liuyue.length; k++) {
              if (ln.liuyue[k].gregorianMonth == targetMonth) {
                _selectedLiuYueIdx = k;
                _selectedLiuRiDay = target.day;
                int hourIdx = (target.hour + 1) ~/ 2;
                if (hourIdx >= 12) hourIdx = 0;
                _selectedLiuShiIdx = hourIdx;
                break;
              }
            }
            break;
          }
        }
        break;
      }
    }
    notifyListeners();
  }

  // --- Data Providing ---

  TianGan get dayMaster => birthDateInfo.dayGanZhi.tianGan;

  List<LiuRiDisplayData> fetchLiuRiData(int year, int month) {
    final key = '$year-$month';
    if (_liuRiCache.containsKey(key)) {
      return _liuRiCache[key]!;
    }
    final data = _useCase.fetchLiuRiData(year, month, dayMaster);
    _liuRiCache[key] = data;
    return data;
  }

  List<LiuShiDisplayData> fetchLiuShiData(int year, int month, int day) {
    final key = '$year-$month-$day';
    if (_liuShiCache.containsKey(key)) {
      return _liuShiCache[key]!;
    }
    final data = _useCase.fetchLiuShiData(year, month, day, dayMaster);
    _liuShiCache[key] = data;
    return data;
  }
}
