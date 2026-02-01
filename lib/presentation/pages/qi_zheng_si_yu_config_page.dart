import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../../domain/entities/models/panel_config.dart';
import '../../enums/enum_school.dart';
import '../viewmodels/panel_config_viewmodel.dart';
import '../widgets/common/water_ink_card.dart';
import '../widgets/config/basic_info_section.dart';
import '../widgets/config/custom_config_section.dart';
import '../widgets/config/location_section.dart';
import '../widgets/config/school_selector.dart';
import '../widgets/config/star_chart_preview.dart';


/// 七政四余命盘配置页面
class QiZhengSiYuConfigPage extends StatefulWidget {
  /// 配置完成后的回调函数
  // final Function(PanelConfig config) onConfigComplete;

  /// 初始配置，用于恢复上次的设置
  final BasePanelConfig? initialConfig;

  const QiZhengSiYuConfigPage({
    Key? key,
    // required this.onConfigComplete,
    this.initialConfig,
  }) : super(key: key);

  @override
  State<QiZhengSiYuConfigPage> createState() => _QiZhengSiYuConfigPageState();
}

class _QiZhengSiYuConfigPageState extends State<QiZhengSiYuConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PanelConfigViewModel get _viewModel =>
      Provider.of<PanelConfigViewModel>(context);

  // 使用ValueNotifier替代setState
  // TODO: should remove this
  late ValueNotifier<EnumQueryType> _configTypeNotifier;

  // 表单的全局键，用于验证
  final _formKey = GlobalKey<FormState>();

  // 当前选中的流派
  EnumSchoolType _selectedSchool = EnumSchoolType.QinTang;

  // 当前设备类型
  EnumDeviceType _deviceType = EnumDeviceType.mobile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 初始化ViewModel
    // _viewModel = PanelConfigViewModel();

    // 初始化ValueNotifier
    // _configTypeNotifier =
    // ValueNotifier(widget.initialConfig?.queryType ?? EnumQueryType.destiny);
    _configTypeNotifier = ValueNotifier(EnumQueryType.destiny);

    // 设置初始流派
    // if (widget.initialConfig != null) {
    // _selectedSchool = widget.initialConfig!.schoolType;
    // }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _configTypeNotifier.dispose();
    super.dispose();
  }

  /// 检测当前设备类型
  void _detectDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppTheme.mobileBreakpoint) {
      _deviceType = EnumDeviceType.mobile;
    } else if (width < AppTheme.tabletBreakpoint) {
      _deviceType = EnumDeviceType.tablet;
    } else {
      _deviceType = EnumDeviceType.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    _detectDeviceType(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('七政四余命盘配置'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryText,
        actions: [
          // 帮助按钮
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          // 保存按钮
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: _buildResponsiveLayout(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 构建响应式布局
  Widget _buildResponsiveLayout() {
    switch (_deviceType) {
      case EnumDeviceType.mobile:
        return _buildMobileLayout();
      case EnumDeviceType.tablet:
        return _buildTabletLayout();
      case EnumDeviceType.desktop:
        return _buildDesktopLayout();
      default:
        return Container(
          child: Text('未知设备类型: $_deviceType'),
        );
    }
  }

  /// 构建移动端布局（单栏）
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配置类型选择
          _buildConfigTypeSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 流派选择
          _buildSchoolSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 基本信息
          WaterInkCard(
            title: '基本信息',
            icon: Icons.person_outline,
            child: ValueListenableBuilder<EnumQueryType>(
              valueListenable: _configTypeNotifier,
              builder: (context, configType, _) {
                return BasicInfoSection(
                  configType: configType == EnumQueryType.destiny
                      ? EnumQueryType.destiny
                      : EnumQueryType.divination,
                  onInfoChanged: _viewModel.updateBasicInfo,
                  initialInfo: configType == EnumQueryType.destiny
                      ? _viewModel.basicPersonInfo
                      : _viewModel.divinationInfo,
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // 位置信息
          WaterInkCard(
            title: '位置信息',
            icon: Icons.location_on_outlined,
            child: LocationSection(
              onLocationChanged: _viewModel.updateLocation,
              initialLocation: _viewModel.location,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // 自定义配置
          WaterInkCard(
            title: '自定义配置',
            icon: Icons.settings_outlined,
            child: CustomConfigSection(
              onConfigChanged: _viewModel.updateCustomConfig,
              initialConfig: _viewModel.customConfig,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建平板布局（两栏）
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        children: [
          // 配置类型选择
          _buildConfigTypeSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 流派选择
          _buildSchoolSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 两栏布局
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧配置栏
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // 基本信息
                    WaterInkCard(
                      title: '基本信息',
                      icon: Icons.person_outline,
                      child: ValueListenableBuilder<EnumQueryType>(
                        valueListenable: _configTypeNotifier,
                        builder: (context, configType, _) {
                          return BasicInfoSection(
                            configType: configType == EnumQueryType.destiny
                                ? EnumQueryType.destiny
                                : EnumQueryType.divination,
                            onInfoChanged: _viewModel.updateBasicInfo,
                            initialInfo: configType == EnumQueryType.destiny
                                ? _viewModel.basicPersonInfo
                                : _viewModel.divinationInfo,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // 位置信息
                    WaterInkCard(
                      title: '位置信息',
                      icon: Icons.location_on_outlined,
                      child: LocationSection(
                        onLocationChanged: _viewModel.updateLocation,
                        initialLocation: _viewModel.location,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),

              // 右侧预览栏
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // 星盘预览
                    WaterInkCard(
                      title: '星盘预览',
                      icon: Icons.auto_graph,
                      child: StarChartPreview(
                        config: _viewModel.customConfig,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // 自定义配置
                    WaterInkCard(
                      title: '自定义配置',
                      icon: Icons.settings_outlined,
                      child: CustomConfigSection(
                        onConfigChanged: _viewModel.updateCustomConfig,
                        initialConfig: _viewModel.customConfig,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建桌面布局（三栏）
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        children: [
          // 配置类型选择
          _buildConfigTypeSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 流派选择
          _buildSchoolSelector(),
          const SizedBox(height: AppTheme.spacing24),

          // 三栏布局
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧基本信息栏
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // 基本信息
                    WaterInkCard(
                      title: '基本信息',
                      icon: Icons.person_outline,
                      child: ValueListenableBuilder<EnumQueryType>(
                        valueListenable: _configTypeNotifier,
                        builder: (context, configType, _) {
                          return BasicInfoSection(
                            configType: configType == EnumQueryType.destiny
                                ? EnumQueryType.destiny
                                : EnumQueryType.divination,
                            onInfoChanged: _viewModel.updateBasicInfo,
                            initialInfo: configType == EnumQueryType.destiny
                                ? _viewModel.basicPersonInfo
                                : _viewModel.divinationInfo,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // 位置信息
                    WaterInkCard(
                      title: '位置信息',
                      icon: Icons.location_on_outlined,
                      child: LocationSection(
                        onLocationChanged: _viewModel.updateLocation,
                        initialLocation: _viewModel.location,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),

              // 中间星盘预览栏
              Expanded(
                flex: 5,
                child: WaterInkCard(
                  title: '星盘预览',
                  icon: Icons.auto_graph,
                  child: StarChartPreview(
                    config: _viewModel.customConfig,
                    height: 500,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),

              // 右侧自定义配置栏
              Expanded(
                flex: 2,
                child: WaterInkCard(
                  title: '自定义配置',
                  icon: Icons.settings_outlined,
                  child: CustomConfigSection(
                    onConfigChanged: _viewModel.updateCustomConfig,
                    initialConfig: _viewModel.customConfig,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建配置类型选择器
  Widget _buildConfigTypeSelector() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _configTypeNotifier,
        builder: (ctx, configType, _) {
          return SlideSwitcher(
            initialIndex: configType.index,
            onSelect: (index) {
              if (index != configType.index) {
                _configTypeNotifier.value = EnumQueryType.values[index];
              }
            },
            containerHeight: 42,
            containerWight: _deviceType == EnumDeviceType.mobile ? 300 : 350,
            indents: 4,
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
                "命理",
                style: configType != EnumQueryType.destiny
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(),
              ),
              Text(
                "占测",
                style: configType != EnumQueryType.divination
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

  /// 构建流派选择器
  Widget _buildSchoolSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacing8),
          child: Text(
            '选择流派',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        SchoolSelector(
          selectedSchool: _selectedSchool,
          onSchoolSelected: (EnumSchoolType school) {
            setState(() {
              _selectedSchool = school;
            });
            _viewModel.updateSchoolType(school);
          },
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回'),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // 生成命盘按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('生成命盘'),
            onPressed: _generateChart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置说明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '基本信息',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing8),
              const Text('• 命理运势：需要填写出生时间和性别'),
              const Text('• 占卜事情：需要填写事情描述和福主信息'),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '位置信息',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing8),
              const Text('• 选择出生地或占卜地点'),
              const Text('• 时区会根据地点自动设置'),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '自定义配置',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing8),
              const Text('• 星道制式：黄道制或赤道制'),
              const Text('• 星宿制式：回归制或恒星制'),
              const Text('• 流派典籍：不同流派的经典著作'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解了'),
          ),
        ],
      ),
    );
  }

  /// 保存当前配置
  void _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      // 表单验证失败
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单中的错误'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 构建配置
      final config = _viewModel.buildConfig();

      // 保存配置（这里可以调用本地存储或云端存储服务）
      // await ConfigStorageService.saveConfig(config);

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置已保存'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 生成命盘
  void _generateChart() async {
    if (!_formKey.currentState!.validate()) {
      // 表单验证失败
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单中的错误'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacing16),
            Text('正在生成命盘...'),
          ],
        ),
      ),
    );

    try {
      // 构建配置
      final config = _viewModel.buildConfig();

      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));

      // 关闭加载对话框
      Navigator.of(context).pop();

      // 调用回调函数
      // widget.onConfigComplete(config);
      // 跳转到面板页并传递配置
      Navigator.of(context).pushNamed('/qizhengsiyu/panel', arguments: config);
    } catch (e) {
      // 关闭加载对话框
      Navigator.of(context).pop();

      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成命盘失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
