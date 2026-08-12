import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:xuan_time_location/xuan_time_location.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository_adapter.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository_adapter.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository_adapter.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_school_service_adapter.dart';
import 'package:qizhengsiyu/domain/services/user_school_profile_service_port.dart';
import 'package:qizhengsiyu/data/services/user_school_profile_service.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_product_repository.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_pipeline_executor.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/panel_config_viewmodel.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/engines/historical_engine.dart';
import 'package:qizhengsiyu/data/datasources/local/definitions/system_definition_local_data_source.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:bazi_embed_ui_interface/bazi_embed_ui_interface.dart';

// UseCase 导入
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/save_calculated_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/get_school_profiles_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/apply_school_profile_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/get_si_yu_profiles_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/validate_panel_config_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_yuan_le_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';

// GeJu 相关导入
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/domain/services/yuan_le_panel_builder.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_editor_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_detail_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_editor_viewmodel.dart';

class AppCalculationEngineProvider implements ICalculationEngineProvider {
  final QiZhengSiYuStorageDependencies _deps;

  AppCalculationEngineProvider(this._deps);

  @override
  ICalculationEngine getEngine(BasePanelConfig config) {
    if (config.celestialCoordinateSystem == CelestialCoordinateSystem.SkyEquatorial) {
      return HistoricalEngine(
        systemDefinitionSource: SystemDefinitionLocalDataSource(),
        ephemerisRepository: _deps.historicalEphemeris,
      );
    } else {
      return SwephEngine(ephemerisRes: _deps.ephemerisResource);
    }
  }
}

List<SingleChildWidget> createProviders(QiZhengSiYuStorageDependencies deps) {
  // timezone 数据库须在使用 tz.getLocation() 前初始化，
  // 否则抛 "Tried to get location before initializing timezone database"。
  // 幂等：重复调用安全（仅重新装载时区数据）。
  tz.initializeTimeZones();
  // 注册产品时区标识 Asia/Beijing → IANA Asia/Shanghai 别名
  // （tzdata 无 Asia/Beijing，见 china_time_zone_alias.dart）。
  // qizhengsiyu viewmodel 直接用 tz.getLocation('Asia/Beijing')，
  // 不在 xuan_time_location 内部调用点覆盖范围内，须在此显式注册。
  ensureChinaTimeZoneAlias();

  // Initialize calculation engine factory provider
  CalculationEngineFactory.setProvider(AppCalculationEngineProvider(deps));

  // Construct injectable ZhouTianModelManager
  final zhouTianModelManager = ZhouTianModelManager(repository: deps.zhouTianModelRepository);

  // Create adapters that bridge contract ports → product types
  final shenShaRepo = ShenShaRepositoryAdapter(deps.shenSha);
  final huaYaoRepo = HuaYaoRepositoryAdapter(deps.huaYao);
  final geJuRepo = GeJuRepositoryAdapter(deps.geJuRepository);
  final geJuSchool = GeJuSchoolServiceAdapter(deps.geJuSchoolService);

  // BaziEmbed 展示端口：由宿主注入实现，qizheng 侧只消费不实现
  return [
    // ============ BaziEmbed 端口 ============
    Provider<BaziEmbedUiPort?>.value(value: null),

    // ============ Repositories (via adapters from injected ports) ============
    Provider<QiZhengRecordRepository>(
      create: (_) => deps.recordRepository,
    ),
    Provider<ShenShaRepository>(
      create: (_) => shenShaRepo,
    ),
    Provider<HuaYaoRepository>(
      create: (_) => huaYaoRepo,
    ),

    // ============ Services ============
    Provider<ShenShaService>(
      create: (context) => ShenShaService(
        repository: context.read<ShenShaRepository>(),
      ),
    ),
    Provider<HuaYaoService>(
      create: (context) => HuaYaoService(
        repository: context.read<HuaYaoRepository>(),
      ),
    ),

    // ============ Managers ============
    Provider<ZhouTianModelManager>(
      create: (_) => zhouTianModelManager,
    ),
    Provider<ShenShaManager>(
      create: (context) => ShenShaManager(
        shenShaService: context.read<ShenShaService>(),
      ),
    ),
    Provider<HuaYaoManager>(
      create: (context) => HuaYaoManager(
        huaYaoService: context.read<HuaYaoService>(),
      ),
    ),

    // ============ GeJu 格局管理 (port-injected) ============

    // GeJu Repository (adapter wrapping contract port)
    Provider<GeJuProductRepository>(
      create: (_) => geJuRepo,
    ),

    // GeJu CRUD Service
    Provider<GeJuCrudService>(
      create: (context) => GeJuCrudService(
        repository: context.read<GeJuProductRepository>(),
      ),
    ),

    // GeJu Evaluation Service
    Provider<GeJuEvaluationService>(
      create: (context) => GeJuEvaluationService(
        repository: context.read<GeJuProductRepository>(),
      ),
    ),

    // GeJu School Service (adapter wrapping contract port)
    Provider<GeJuSchoolServiceAdapter>(
      create: (_) => geJuSchool,
    ),

    // UserSchoolProfileService
    Provider<UserSchoolProfileServicePort>(
      create: (_) => UserSchoolProfileService(deps.userSchoolProfileDao),
    ),

    // ============ Domain Services (non-static) ============
    Provider<YuanLePanelBuilder>(
      create: (context) => YuanLePanelBuilder(
        positionStatusRepo: deps.starPositionStatus,
      ),
    ),
    Provider<BuildYuanLePanelUseCase>(
      create: (context) =>
          BuildYuanLePanelUseCase(builder: context.read<YuanLePanelBuilder>()),
    ),

    // ============ Pipeline ============
    Provider<MomentResolver>(
      create: (_) => DefaultMomentResolver(),
    ),

    // ============ UseCases ============
    Provider<InitializeQiZhengOfficialDataUseCase>(
      create: (context) => InitializeQiZhengOfficialDataUseCase(
        zhouTianModelManager: context.read<ZhouTianModelManager>(),
      ),
    ),
    Provider<CalculateQiZhengBasePanelUseCase>(
      create: (context) => CalculateQiZhengBasePanelUseCase(
        shenShaManager: context.read<ShenShaManager>(),
        huaYaoManager: context.read<HuaYaoManager>(),
      ),
    ),
    Provider<EvaluateQiZhengGeJuUseCase>(
      create: (context) => EvaluateQiZhengGeJuUseCase(
        geJuEvaluationService: context.read<GeJuEvaluationService>(),
        positionStatusRepo: deps.starPositionStatus,
      ),
    ),
    Provider<BuildQiZhengTimelineUseCase>(
      create: (context) => BuildQiZhengTimelineUseCase(
        shenShaManager: context.read<ShenShaManager>(),
        huaYaoManager: context.read<HuaYaoManager>(),
      ),
    ),
    Provider<SaveCalculatedPanelUseCase>(
      create: (context) => SaveCalculatedPanelUseCase(
        qiZhengSiYuPanRepository: deps.panRepository,
        recordRepository: deps.recordRepository,
      ),
    ),
    Provider<GetSchoolProfilesUseCase>(create: (_) => GetSchoolProfilesUseCase()),
    Provider<ApplySchoolProfileUseCase>(create: (_) => ApplySchoolProfileUseCase()),
    Provider<GetSiYuProfilesUseCase>(create: (_) => GetSiYuProfilesUseCase()),
    Provider<ValidatePanelConfigUseCase>(create: (_) => ValidatePanelConfigUseCase()),
    Provider<ComputeRiseSetUseCase>(create: (_) => ComputeRiseSetUseCase()),
    Provider<YunLiuUseCase>(create: (_) => YunLiuUseCase()),
    Provider<ComputeGanZhiUseCase>(create: (_) => ComputeGanZhiUseCase()),

    // ============ ViewModels ============
    ChangeNotifierProvider<QiZhengSiYuViewModel>(
      create: (context) => QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: context.read<InitializeQiZhengOfficialDataUseCase>(),
        calculateBasePanelUseCase: context.read<CalculateQiZhengBasePanelUseCase>(),
        evaluateGeJuUseCase: context.read<EvaluateQiZhengGeJuUseCase>(),
        buildTimelineUseCase: context.read<BuildQiZhengTimelineUseCase>(),
        computeRiseSetUseCase: context.read<ComputeRiseSetUseCase>(),
        yunLiuUseCase: context.read<YunLiuUseCase>(),
        computeGanZhiUseCase: context.read<ComputeGanZhiUseCase>(),
        momentResolver: context.read<MomentResolver>(),
        shenShaService: context.read<ShenShaService>(),
        huaYaoService: context.read<HuaYaoService>(),
        pipelineExecutor: QizhengPipelineExecutor(),
        saveCalculatedPanelUseCase: context.read<SaveCalculatedPanelUseCase>(),
      ),
    ),
    ChangeNotifierProvider<PanelConfigViewModel>(
      create: (context) => PanelConfigViewModel(
        schoolProfiles: context.read<GetSchoolProfilesUseCase>(),
        applyProfile: context.read<ApplySchoolProfileUseCase>(),
      ),
    ),

    // GeJu ViewModels
    ChangeNotifierProvider<GeJuListViewModel>(
      create: (context) => GeJuListViewModel(
        crudService: context.read<GeJuCrudService>(),
      ),
    ),
    ChangeNotifierProvider<GeJuEditorViewModel>(
      create: (context) => GeJuEditorViewModel(
        crudService: context.read<GeJuCrudService>(),
        schoolService: context.read<GeJuSchoolServiceAdapter>(),
      ),
    ),
    ChangeNotifierProvider<GeJuDetailViewModel>(
      create: (context) => GeJuDetailViewModel(
        crudService: context.read<GeJuCrudService>(),
      ),
    ),
    ChangeNotifierProvider<GeJuSchoolListViewModel>(
      create: (context) => GeJuSchoolListViewModel(
        schoolService: context.read<GeJuSchoolServiceAdapter>(),
      ),
    ),
    ChangeNotifierProvider<GeJuSchoolEditorViewModel>(
      create: (context) => GeJuSchoolEditorViewModel(
        schoolService: context.read<GeJuSchoolServiceAdapter>(),
      ),
    ),

  ];
}
