import 'package:common/datamodel/location.dart';
import 'package:flutter/material.dart';
import 'package:common/module.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';

/// 位置信息配置部分
class LocationSection extends StatefulWidget {
  /// 位置变更回调
  final Function onLocationChanged;

  /// 初始位置信息
  final Address? initialLocation;

  const LocationSection({
    Key? key,
    required this.onLocationChanged,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  late String _country;
  late String _province;
  late String _city;
  late String _timezone;
  late bool _hasDaylightSaving;
  late bool _isTrueSolarTime;
  double? _longitude;
  double? _latitude;

  @override
  void initState() {
    super.initState();

    // 设置初始值
    // _country = widget.initialLocation?.country ?? '中国';
    // _city = widget.initialLocation?.city ?? '北京';
    // _province = widget.initialLocation?.province ?? '北京';
    _timezone = widget.initialLocation?.timezone ?? 'Asia/Shanghai';
    // _hasDaylightSaving = widget.initialLocation?.hasDaylightSaving ?? false;
    // _isTrueSolarTime = widget.initialLocation?.isTrueSolarTime ?? false;
    // _longitude = widget.initialLocation?.longitude;
    // _latitude = widget.initialLocation?.latitude;
  }

  void _updateLocation() {
    // final location = Location(
    //   country: _country,
    //   province: _province,
    //   city: _city,
    //   timezone: _timezone,
    //   // hasDaylightSaving: _hasDaylightSaving,
    //   // isTrueSolarTime: _isTrueSolarTime,
    //   coordinates: Coordinates(latitude: 116.4, longitude: 39.9),
    // );
    // widget.onLocationChanged(location);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 位置选择器
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          // child: LocationPicker(
          //   initialCountry: _country,
          //   initialProvince: _province,
          //   initialCity: _city,
          //   initialLongitude: _longitude,
          //   initialLatitude: _latitude,
          //   onLocationChanged: (country, province, city, longitude, latitude) {
          //     setState(() {
          //       _country = country;
          //       _province = province;
          //       _city = city;
          //       _longitude = longitude;
          //       _latitude = latitude;
          //     });
          //     _updateLocation();
          //   },
          // ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 时区选择器
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '时区设置',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              // 时区选择器
              Container(child: const Text("时区选择"))
              // TimezonePicker(
              //   initialValue: _timezone,
              //   onChanged: (value) {
              //     setState(() {
              //       _timezone = value;
              //     });
              //     _updateLocation();
              //   },
              // ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 高级选项
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '高级选项',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),

              // 夏令时选项
              SwitchListTile(
                title: const Text('是否有夏令时'),
                subtitle: const Text('部分地区在特定时期使用夏令时'),
                value: _hasDaylightSaving,
                onChanged: (value) {
                  setState(() {
                    _hasDaylightSaving = value;
                  });
                  _updateLocation();
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryColor,
              ),

              // 真太阳时选项
              SwitchListTile(
                title: const Text('是否使用真太阳时'),
                subtitle: const Text('使用真太阳时会根据经度调整时间'),
                value: _isTrueSolarTime,
                onChanged: (value) {
                  setState(() {
                    _isTrueSolarTime = value;
                  });
                  _updateLocation();
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryColor,
              ),

              if (_isTrueSolarTime)
                Container(
                  margin: const EdgeInsets.only(left: AppTheme.spacing16),
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          '真太阳时会根据您所在经度位置，调整时间以反映实际太阳位置',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 坐标显示
        if (_longitude != null && _latitude != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacing16),
            child: Text(
              '当前坐标: ${_latitude!.toStringAsFixed(4)}°N, ${_longitude!.toStringAsFixed(4)}°E',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryText,
                  ),
            ),
          ),
      ],
    );
  }
}
