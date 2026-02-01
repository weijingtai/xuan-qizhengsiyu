import 'package:common/database/app_database.dart' as db;
import 'package:common/database/world_info_database.dart' as db;
import 'package:common/datasource/geo_location_repository.dart';
import 'package:common/datasource/loca_binary/world_country_repository.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sweph/sweph.dart' hide kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:qizhengsiyu/di.dart' as qizhengsiyu_di;
import 'package:qizhengsiyu/navigator.dart' as qizhengsiyu_nav;
import 'package:common/common_logger.dart';
import 'package:http/http.dart' as http;

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
  runApp(
    MultiProvider(
      providers: [
        Provider<db.AppDatabase>(
          create: (ctx) => db.AppDatabase(),
          dispose: (ctx, db) => db.close(),
        ),
        Provider<db.WorldInfoDatabase>(
          create: (ctx) => db.WorldInfoDatabase(),
          dispose: (ctx, db) => db.close(),
        ),
        Provider<WorldCountryRepository>(
          create: (ctx) => WorldCountryRepository(
            path: "assets/dataset/world_country.pro",
            regionJsonFilePath: "assets/dataset/regions.json",
          ),
        ),
        Provider<GeoLocationRepository>(
          create: (ctx) => GeoLocationRepository(
            path: "assets/dataset/province_city_area_lng_lat.json",
          ),
        ),
        ListenableProvider<TimezoneLocationViewModel>(
          create: (ctx) => TimezoneLocationViewModel(
              appFeatureModule: AppFeatureModule.Golabel),
        ),
        ListenableProvider<DevEnterPageViewModel>(
            create: (ctx) =>
                DevEnterPageViewModel(appDatabase: ctx.read<db.AppDatabase>())
                  ..initState()),
        // 七政四余模块的依赖注入
        ...qizhengsiyu_di.createProviders(),
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
      initialRoute: '/qizhengsiyu/panel',
      onGenerateRoute: qizhengsiyu_nav.NavigatorGenerator.generateRoute,
    );
  }
}
