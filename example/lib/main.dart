import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sweph/sweph.dart' hide kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:qizhengsiyu/di.dart' as qizhengsiyu_di;
import 'package:qizhengsiyu/navigator.dart' as qizhengsiyu_nav;
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_preferences/persistence_preferences.dart';
import 'package:persistence_assets/persistence_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_drift/qizhengsiyu/qizheng_module_registry.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_builtin_database.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_sqlite_data_source.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/ge_ju_dao.dart';
import 'package:qizhengsiyu/data/repositories/qizhengsiyu_pan_repository.dart';
import 'package:qizhengsiyu/data/repositories/ge_ju_repository_impl.dart';
import 'package:qizhengsiyu/data/datasources/local/services/ge_ju_school_service.dart';

class _RootBundleAssetLoader implements AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    return (await rootBundle.load(assetPath)).buffer.asUint8List();
  }
}

class _WebAssetLoader implements AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    final response = await http.get(Uri.parse('assets/$assetPath'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load asset: $assetPath');
    }
    return response.bodyBytes;
  }
}

Future<void> initSweph([List<String> epheAssets = const []]) async {
  if (kIsWeb) {
    await Sweph.init(
      epheAssets: epheAssets,
      epheFilesPath: 'ephe_files',
      assetLoader: _WebAssetLoader(),
    );
  } else {
    final epheFilesPath =
        '${(await getApplicationSupportDirectory()).path}/ephe_files';

    await Sweph.init(
      epheAssets: epheAssets,
      epheFilesPath: epheFilesPath,
      assetLoader: _RootBundleAssetLoader(),
    );
  }
}

Future<void> initServices() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await initSweph([
    'packages/sweph/assets/ephe/sefstars.txt',
  ]);
}

void main() async {
  await initServices();

  final appDatabase = AppDatabase();
  final geJuBuiltInDataSource =
      GeJuSQLiteDataSource(GeJuBuiltInDatabase(createGeJuBuiltInConnection()));
  final geJuDao = GeJuDao(appDatabase);

  final newDb = PersistenceDriftDatabase(
    driftDatabase(
      name: 'persistence',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final sessionRepo = PreferencesAccountSessionRepository(prefs);
  final accountDb = AccountDatabase(
    driftDatabase(
      name: 'account',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  final identityLinkRepo = DriftAccountIdentityLinkRepository(accountDb);
  
  final bootstrapStore = DriftScopeBootstrapStore(newDb);
  final ledger = DriftScopeLedger(db: newDb, bootstrapStore: bootstrapStore);
  final resolver = ScopeResolver(
    sessionRepository: sessionRepo,
    identityLinkRepository: identityLinkRepo,
    ledger: ledger,
  );
  final resolvedScope = await resolver.resolve();
  final scopeUid = resolvedScope.scopeUid;

  final ds = DriftRecordDataSource(newDb, scopeUid: scopeUid);
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([QiZhengModuleRegistry.codec()]));
  final recordBackedRepository = QiZhengModuleRegistry.repository(store: store);

  final deps = QiZhengSiYuStorageDependencies(
    panRepository: QiZhengSiYuPanRepository(appDatabase: appDatabase),
    recordRepository: recordBackedRepository,
    geJuRepository:
        GeJuRepositoryImpl(builtInDataSource: geJuBuiltInDataSource, dao: geJuDao),
    geJuBuiltInDataSource: geJuBuiltInDataSource,
    geJuSchoolService: GeJuSchoolService(dao: geJuDao),
    userSchoolProfileDao: appDatabase.userSchoolProfileDao,
    shenSha: AssetsQiZhengShenShaRepository(),
    huaYao: AssetsQiZhengHuaYaoRepository(),
    starPositionStatus: const AssetsQiZhengStarPositionStatusRepository(),
    historicalEphemeris: const AssetsQiZhengHistoricalEphemerisRepository(),
    ephemerisResource: const AssetsQiZhengEphemerisResourceRepository(),
    zhouTianModelRepository: const AssetsQiZhengZhouTianModelRepository(),
  );

  runApp(
    MultiProvider(
      providers: [
        // 七政四余模块的依赖注入
        ...qizhengsiyu_di.createProviders(deps),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QiZhengSiYu Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: qizhengsiyu_nav.NavigatorGenerator.generateRoute,
    );
  }
}
