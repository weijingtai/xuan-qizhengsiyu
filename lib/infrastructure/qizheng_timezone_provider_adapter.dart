import 'package:flutter/foundation.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:tuple/tuple.dart';
import 'package:xuan_four_zhu_card/domain/ports/i_timezone_provider.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

/// 七政四余侧 ITimezoneProvider 桥接类
///
/// 将 QTIC 所需的 ITimezoneProvider 接口映射到七政四余自身的时间输入上下文。
class QizhengTimezoneProviderAdapter implements ITimezoneProvider {
  QizhengTimezoneProviderAdapter({
    required DateTime initialDatetime,
    this.onDatetimeChanged,
    this.onLocationSelected,
  })  : _selectedDatetime = initialDatetime,
        _selectedTimeNotifier = ValueNotifier<DateTime?>(initialDatetime),
        _selectedDSTTimeNotifier = ValueNotifier<DateTime?>(null),
        _timezoneNotifier = ValueNotifier<String?>('Asia/Shanghai'),
        _defaultTimezoneNotifier = ValueNotifier<String?>(null),
        _displayDefaultTimezoneNotifier =
            ValueNotifier<Tuple2<TimezoneType, String>?>(null),
        _selectedLocationNotifier = ValueNotifier<Location?>(null),
        _myLocationNotifier = ValueNotifier<Location?>(null),
        _locationListNotifier = ValueNotifier<List<Location>>([]),
        _isSeerLocationNotifier = ValueNotifier<bool>(false),
        _isDefaultTimezoneNotifier = ValueNotifier<bool>(false),
        _myLocationIsDefaultNotifier = ValueNotifier<bool>(false),
        _isDSTNotifier = ValueNotifier<bool>(false),
        _isAutoHandleDSTNotifier = ValueNotifier<bool>(false);

  DateTime? _selectedDatetime;
  final ValueChanged<DateTime?>? onDatetimeChanged;
  final ValueChanged<Location?>? onLocationSelected;

  @override
  Future<void> load() async {}

  @override
  DateTime? get selectedDatetime => _selectedDatetime;

  final ValueNotifier<DateTime?> _selectedTimeNotifier;
  @override
  ValueNotifier<DateTime?> get selectedTimeNotifier => _selectedTimeNotifier;

  final ValueNotifier<DateTime?> _selectedDSTTimeNotifier;
  @override
  ValueNotifier<DateTime?> get selectedDSTTimeNotifier =>
      _selectedDSTTimeNotifier;

  @override
  void updateDatetime(DateTime? dt) {
    _selectedDatetime = dt;
    _selectedTimeNotifier.value = dt;
    onDatetimeChanged?.call(dt);
  }

  @override
  String? get timezone => _timezoneNotifier.value;

  @override
  String? get localTimezone => 'Asia/Shanghai';

  final ValueNotifier<String?> _timezoneNotifier;
  @override
  ValueNotifier<String?> get timezoneNotifier => _timezoneNotifier;

  final ValueNotifier<String?> _defaultTimezoneNotifier;
  @override
  ValueNotifier<String?> get defaultTimezoneNotifier =>
      _defaultTimezoneNotifier;

  final ValueNotifier<Tuple2<TimezoneType, String>?>
      _displayDefaultTimezoneNotifier;
  @override
  ValueNotifier<Tuple2<TimezoneType, String>?>
      get displayDefaultTimezoneNotifier => _displayDefaultTimezoneNotifier;

  @override
  void updateTimezone(String? newValue) {
    _timezoneNotifier.value = newValue;
  }

  final ValueNotifier<Location?> _selectedLocationNotifier;
  @override
  ValueNotifier<Location?> get selectedLocationNotifier =>
      _selectedLocationNotifier;

  final ValueNotifier<Location?> _myLocationNotifier;
  @override
  ValueNotifier<Location?> get myLocationNotifier => _myLocationNotifier;

  final ValueNotifier<List<Location>> _locationListNotifier;
  @override
  ValueNotifier<List<Location>> get locationListNotifier =>
      _locationListNotifier;

  @override
  void addLocation(Location? newLocation) {
    if (newLocation == null) return;
    final list = List<Location>.from(_locationListNotifier.value);
    if (!list.any((t) => t == newLocation)) {
      list.add(newLocation);
      _locationListNotifier.value = list;
    }
  }

  @override
  void selectLocation(Location newLocation) {
    _selectedLocationNotifier.value = newLocation;
    _isSeerLocationNotifier.value = false;
    onLocationSelected?.call(newLocation);
  }

  @override
  void updateLocation(Location oldLocation, Location? newLocation) {
    if (newLocation == null) return;
    final list = List<Location>.from(_locationListNotifier.value);
    final index = list.indexOf(oldLocation);
    if (index != -1) {
      list[index] = newLocation;
      _locationListNotifier.value = list;
    }
  }

  @override
  Future<void> updateMyLocation(Location? newLocation) async {
    _myLocationNotifier.value = newLocation;
  }

  final ValueNotifier<bool> _isSeerLocationNotifier;
  @override
  ValueNotifier<bool> get isSeerLocationNotifier => _isSeerLocationNotifier;

  @override
  void usingSeersLocation(bool isSeerLocation) {
    if (isSeerLocation && _selectedLocationNotifier.value != null) {
      _selectedLocationNotifier.value = null;
    }
    _isSeerLocationNotifier.value = isSeerLocation;
  }

  final ValueNotifier<bool> _isDefaultTimezoneNotifier;
  @override
  ValueNotifier<bool> get isDefaultTimezoneNotifier =>
      _isDefaultTimezoneNotifier;

  @override
  void onIsDefaultTimezoneChanged(bool? newValue) {
    _isDefaultTimezoneNotifier.value = newValue ?? false;
  }

  final ValueNotifier<bool> _myLocationIsDefaultNotifier;
  @override
  ValueNotifier<bool> get myLocationIsDefaultNotifier =>
      _myLocationIsDefaultNotifier;

  @override
  Future<void> setMyLocationAsDefault(bool isDefault) async {
    _myLocationIsDefaultNotifier.value = isDefault;
  }

  final ValueNotifier<bool> _isDSTNotifier;
  @override
  ValueNotifier<bool> get isDSTNotifier => _isDSTNotifier;

  final ValueNotifier<bool> _isAutoHandleDSTNotifier;
  @override
  ValueNotifier<bool> get isAutoHandleDSTNotifier =>
      _isAutoHandleDSTNotifier;

  @override
  void onAutoHandleTimezoneChanged(bool? newValue) {
    _isAutoHandleDSTNotifier.value = newValue ?? false;
  }
}
