import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/datamodel/location.dart';
import 'package:common/enums.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:common/module.dart';
import 'package:flutter_city_picker/city_picker.dart';
import 'package:flutter_city_picker/model/address.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:intl/intl.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:timezone/timezone.dart' as tz;

/// 基本信息配置部分
class BasicInfoSection extends StatefulWidget {
  /// 配置类型
  final EnumQueryType configType;

  /// 信息变更回调
  final Function onInfoChanged;

  /// 初始信息
  final dynamic initialInfo;

  const BasicInfoSection({
    Key? key,
    required this.configType,
    required this.onInfoChanged,
    this.initialInfo,
  }) : super(key: key);

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection>
    with SingleTickerProviderStateMixin
    implements CityPickerListener {
  AnimationController? _animationController;
  final String _addressProvince = "请选择省";
  final String _addressCity = "请选择市";
  final String _addressArea = "请选择地区";
  final String _addressStreet = "请选择街道";
  final Color _themeColor = Colors.blue;
  final Color _backgroundColor = Colors.white;
  final double _height = 500.0;
  final double _opacity = 0.5;
  final double _corner = 20;
  final bool _dismissible = true;
  final bool _showTabIndicator = true;
  // List<AddressNode> _selectProvince = [];
  // List<AddressNode> _selectCity = [];
  // List<AddressNode> _selectArea = [];
  // List<AddressNode> _selectStreet = [];

  // 命理运势信息
  late String _name;
  late DateTime _birthDateTime;
  late Gender _gender;

  late final ValueNotifier<String> _timezoneNotifier;
  late final ValueNotifier<bool> _isTrueSolarNotifier;
  // late final ValueNotifier<bool> auto;
  // 占卜事情信息
  late String _eventDescription;
  late String _querierName;
  late DateTime _queryDateTime;

  final ValueNotifier<DateTime> _selectedBirthTimeNotifier =
      ValueNotifier<DateTime>(DateTime.now());

  // 表单键
  final _formKey = GlobalKey<FormState>();

  // 文本控制器
  late TextEditingController _nameController;
  late TextEditingController _eventController;
  late TextEditingController _querierController;

  late final ValueNotifier<Gender> genderValueNotifier;

  @override
  void initState() {
    super.initState();

    _timezoneNotifier = ValueNotifier("Asia/Shanghai");
    // 初始化文本控制器
    _nameController = TextEditingController();
    _eventController = TextEditingController();
    _querierController = TextEditingController();

    _initializeValues();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _eventController.dispose();
    _querierController.dispose();
    genderValueNotifier.dispose();
    _timezoneNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BasicInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configType != widget.configType ||
        oldWidget.initialInfo != widget.initialInfo) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    if (widget.configType == EnumQueryType.destiny) {
      genderValueNotifier = ValueNotifier(Gender.male);
      // 命理运势初始化
      final info = widget.initialInfo as BasicPersonInfo?;
      _name = info?.name ?? '';
      // _birthDateTime = info?.birthTime ?? DateTime.now();
      _gender = info?.gender ?? Gender.male;

      _nameController.text = _name;
    } else {
      genderValueNotifier = ValueNotifier(Gender.unknown);
      // 占卜事情初始化
      final info = widget.initialInfo as BasicDivination?;
      // _eventDescription = info?.eventDescription ?? '';
      // _querierName = info?.querierName ?? '';
      // _queryDateTime = info?.queryTime ?? DateTime.now();

      _eventController.text = _eventDescription;
      _querierController.text = _querierName;
    }
  }

  void _updateInfo() {
    if (widget.configType == EnumQueryType.destiny) {
      // 更新命理运势信息
      final info = BasicPersonInfo(
          name: _name,
          birthTime: DateTime.now(),
          gender: _gender,
          birthLocation: Address.defualtAddress,
          trueSolarTime: DateTime.now(),
          bazi: EightChars(
              year: JiaZi.JIA_ZI,
              month: JiaZi.JIA_ZI,
              day: JiaZi.JIA_ZI,
              time: JiaZi.JIA_ZI),
          hasDaylightSaving: false,
          isTrueSolarTime: true);
      widget.onInfoChanged(info);
    } else {
      // 更新占卜事情信息
      final info = BasicDivination(
        question: '',
        divinationAt: _queryDateTime,
        details: "",
        divinationPerson: null,
      );
      widget.onInfoChanged(info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.configType == EnumQueryType.destiny
          ? _buildDestinyForm()
          : _buildDivinationForm(),
    );
  }

  /// 构建命理运势表单
  Widget _buildDestinyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 姓名输入
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 240,
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
                      '姓名',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '请输入姓名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing16,
                          vertical: AppTheme.spacing12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入姓名';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                        _updateInfo();
                      },
                    ),
                  ],
                ),
              ),
              // 性别选择
              Container(
                width: 180,
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
                      '性别',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildGenderSelector(),
                  ],
                ),
              ),
            ]),

        const SizedBox(height: AppTheme.spacing16),

        // 出生日期时间
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
                '出生日期时间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              selectDateTimeButton(),
              // DateTimePicker(
              //   initialDateTime: _birthDateTime,
              //   onDateTimeChanged: (dateTime) {
              //     setState(() {
              //       _birthDateTime = dateTime;
              //     });
              //     _updateInfo();
              //   },
              // ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        ElevatedButton(
            onPressed: () async {
              // 显示城市选择器底部弹窗
              final Address? selectedLocation = await showCityPickerBottomSheet(
                context: context,
                initAddress: Address.defualtAddress, // 可选，初始选中的地理位置编码
                myLocationNotifier: ValueNotifier<Location?>(null),
              );
// 处理选择结果
              if (selectedLocation != null) {
                logger.d(selectedLocation.toJson().toString());
                // logger.d('选中的地区: ${selectedLocation.name}');
                // logger.d('编码: ${selectedLocation.code}');
                // logger.d(
                // '经纬度: (${selectedLocation.latitude}, ${selectedLocation.longitude})');
              }
            },
            child: const Text("选择地区")),

        ValueListenableBuilder(
            valueListenable: _timezoneNotifier,
            builder: (ctx, timezone, _) {
              return DropdownButton<String>(
                value: timezone,
                items: tz.timeZoneDatabase.locations.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _timezoneNotifier.value = newValue ?? timezone;
                  // 获取当前选定时区的时间
                  // tz.TZDateTime now =
                  //     tz.TZDateTime.now(tz.getLocation(_selectedTimeZone));
                  // print(now);
                },
              );
            }),
      ],
    );
  }

  // void show(List<AddressNode> initData) {
  void show() {
    CityPicker.show(
      context: context,
      animController: _animationController,
      opacity: _opacity,
      dismissible: _dismissible,
      height: _height,
      titleHeight: 50,
      corner: _corner,
      backgroundColor: _backgroundColor,
      paddingLeft: 15,
      titleWidget: const Text(
        '请选择地址',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      selectText: "请选择",
      closeWidget: const Icon(Icons.close),
      tabHeight: 40,
      showTabIndicator: _showTabIndicator,
      tabPadding: 15,
      tabIndicatorColor: Theme.of(context).primaryColor,
      tabIndicatorHeight: 2,
      labelTextSize: 15,
      selectedLabelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.black54,
      itemHeadHeight: 30,
      itemHeadBackgroundColor: _backgroundColor,
      itemHeadLineColor: Colors.black,
      itemHeadLineHeight: 0.1,
      itemHeadTextStyle: const TextStyle(fontSize: 15, color: Colors.black),
      itemHeight: 40,
      indexBarWidth: 28,
      indexBarItemHeight: 20,
      indexBarBackgroundColor: Colors.black12,
      indexBarTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
      itemSelectedIconWidget:
          Icon(Icons.done, color: Theme.of(context).primaryColor, size: 16),
      itemSelectedTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
      itemUnSelectedTextStyle:
          const TextStyle(fontSize: 14, color: Colors.black54),
      // initialAddress: initData,
      cityPickerListener: this,
    );
  }

  Widget selectDateTimeButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await showBoardDateTimePicker(
              context: context,
              pickerType: DateTimePickerType.datetime,
            );
            if (result != null) {
              // dateTimeValueNotifier.value = result;
              // selectedDateTime = result;
              _selectedBirthTimeNotifier.value = result;
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors
                .white, // Background coloronPrimary: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15), // Padding
            textStyle: const TextStyle(fontSize: 18), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                  valueListenable: _selectedBirthTimeNotifier,
                  builder: (ctx, dateTime, _) {
                    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm");
                    return Text(
                      dateFormat.format(dateTime ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    );
                  }),
              const Text(
                '选择时间',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: () async {
            InteractiveToast.slide(
              context: context,
              // leading: leadingWidget(),
              title: const Text("不能重复"),
              // trailing: trailingWidget(),
              toastStyle: const ToastStyle(titleLeadingGap: 10),
              toastSetting: const SlidingToastSetting(
                animationDuration: Duration(seconds: 1),
                displayDuration: Duration(seconds: 2),
                toastStartPosition: ToastPosition.top,
                toastAlignment: Alignment.topCenter,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.green, // Background coloronPrimary: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15), // Padding
            textStyle: const TextStyle(fontSize: 18), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: const Text('现在'),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: genderValueNotifier,
        builder: (ctx, configType, _) {
          return SlideSwitcher(
            initialIndex: configType.index,
            onSelect: (index) {
              if (index != configType.index) {
                genderValueNotifier.value = Gender.values[index];
              }
            },
            containerHeight: 42,
            containerWight: 100,
            indents: 2,
            containerColor: const Color(0xffe4e5eb),
            slidersColors: const [Color(0xfff7f5f7)],
            containerBoxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 2,
                spreadRadius: 4,
              )
            ],
            children: [
              Text(
                "男",
                style: configType != Gender.male
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(),
              ),
              Text(
                "女",
                style: configType != Gender.female
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 获取滑块未激活状态的文本样式
  TextStyle _getSwitcherInactivatedStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppTheme.secondaryText,
    );
  }

  /// 获取滑块激活状态的文本样式
  TextStyle _getSwitcherActivatedStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppTheme.primaryColor,
    );
  }

  /// 构建占卜事情表单
  Widget _buildDivinationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 事情描述
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
                '事情描述',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              TextFormField(
                controller: _eventController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '请描述需要占卜的事情',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请描述需要占卜的事情';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _eventDescription = value;
                  });
                  _updateInfo();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 福主信息
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
                '福主信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              TextFormField(
                controller: _querierController,
                decoration: InputDecoration(
                  hintText: '请输入福主姓名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入福主姓名';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _querierName = value;
                  });
                  _updateInfo();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 占卜时间
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
                '占卜时间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Container(child: const Text("选择时间"))
              // DateTimePicker(
              //   initialDateTime: _queryDateTime,
              //   onDateTimeChanged: (dateTime) {
              //     setState(() {
              //       _queryDateTime = dateTime;
              //     });
              //     _updateInfo();
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Future<List<AddressNode>> onDataLoad(int index, AddressNode? node) {
    throw UnimplementedError("not imp");
  }

  @override
  void onFinish(List<AddressNode> data) {}
}
