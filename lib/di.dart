import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/data/datasources/local/shen_sha_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/shen_sha_repository_impl.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// GeJu 相关导入
import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/ge_ju_repository_impl.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_editor_viewmodel.dart';

List<SingleChildWidget> createProviders() {
  return [
    // Data Sources
    Provider<ShenShaLocalDataSource>(
      create: (_) => ShenShaLocalDataSourceImpl(),
    ),
    Provider<HuaYaoLocalDataSource>(
      create: (_) => HuaYaoLocalDataSourceImpl(),
    ),

    // Repositories
    Provider<ShenShaRepository>(
      create: (context) => ShenShaRepositoryImpl(
        localDataSource: context.read<ShenShaLocalDataSource>(),
      ),
    ),
    Provider<HuaYaoRepository>(
      create: (context) => HuaYaoRepositoryImpl(
        localDataSource: context.read<HuaYaoLocalDataSource>(),
      ),
    ),

    // Services
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

    // Managers
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

    // ViewModels
    ChangeNotifierProvider<QiZhengSiYuViewModel>(
      create: (context) => QiZhengSiYuViewModel(
        shenShaManager: context.read<ShenShaManager>(),
        huaYaoManager: context.read<HuaYaoManager>(),
        zhouTianModelManager: context.read<ZhouTianModelManager>(),
      ),
    ),

    // ============ GeJu 格局管理 ============

    // GeJu DataSource
    Provider<GeJuLocalDataSource>(
      create: (_) => GeJuLocalDataSourceImpl(),
    ),

    // GeJu Repository
    Provider<IGeJuRepository>(
      create: (context) => GeJuRepositoryImpl(
        localDataSource: context.read<GeJuLocalDataSource>(),
      ),
    ),

    // GeJu CRUD Service
    Provider<GeJuCrudService>(
      create: (context) => GeJuCrudService(
        repository: context.read<IGeJuRepository>(),
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
      ),
    ),
  ];
}
