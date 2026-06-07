import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';
import 'package:qizhengsiyu/data/contract_mappers/qizhengsiyu_contract_mappers.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// GeJu 相关导入
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_editor_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_detail_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_editor_viewmodel.dart';

List<SingleChildWidget> createProviders(QiZhengSiYuStorageDependencies deps) {
  // Create adapters that bridge contract ports → product types
  final shenShaRepo = ShenShaRepositoryAdapter(deps.shenSha);
  final huaYaoRepo = HuaYaoRepositoryAdapter(deps.huaYao);
  final geJuRepo = GeJuRepositoryAdapter(deps.geJuRepository);
  final geJuSchool = GeJuSchoolServiceAdapter(deps.geJuSchoolService);

  return [
    // ============ Repositories (via adapters from injected ports) ============
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
      create: (_) => ZhouTianModelManager.instance,
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
    Provider<GeJuRepositoryAdapter>(
      create: (_) => geJuRepo,
    ),

    // GeJu CRUD Service
    Provider<GeJuCrudService>(
      create: (context) => GeJuCrudService(
        repository: context.read<GeJuRepositoryAdapter>(),
      ),
    ),

    // GeJu Evaluation Service
    Provider<GeJuEvaluationService>(
      create: (context) => GeJuEvaluationService(
        repository: context.read<GeJuRepositoryAdapter>(),
      ),
    ),

    // GeJu School Service (adapter wrapping contract port)
    Provider<GeJuSchoolServiceAdapter>(
      create: (_) => geJuSchool,
    ),

    // ============ ViewModels ============
    ChangeNotifierProvider<QiZhengSiYuViewModel>(
      create: (context) => QiZhengSiYuViewModel(
        shenShaManager: context.read<ShenShaManager>(),
        huaYaoManager: context.read<HuaYaoManager>(),
        zhouTianModelManager: context.read<ZhouTianModelManager>(),
        geJuEvaluationService: context.read<GeJuEvaluationService>(),
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
