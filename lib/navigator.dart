import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:qizhengsiyu/presentation/pages/beauty_view_page.dart';
import 'package:qizhengsiyu/presentation/pages/primary_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_list_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_detail_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_editor_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_school_list_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_school_editor_page.dart';
import 'package:qizhengsiyu/presentation/pages/qizhengsiyu_home_page.dart';

import 'di.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static Logger logger = Logger();
  static final routes = {
    // ============ 根路由 ============
    "/": (context, {arguments}) => const QiZhengSiYuHomePage(),

    "/qizhengsiyu/panel": (context, {arguments}) => const BeautyViewPage(),

    // ============ 七政四余首页 ============
    "/qizhengsiyu/home": (context, {arguments}) => const QiZhengSiYuHomePage(),

    // ============ 格局管理路由 ============
    "/qizhengsiyu/ge_ju/list": (context, {arguments}) => const GeJuListPage(),

    "/qizhengsiyu/ge_ju/detail": (context, {arguments}) {
      // arguments is a ruleId (String)
      if (arguments is String) {
        return GeJuDetailPage(ruleId: arguments);
      }
      return const Scaffold(body: Center(child: Text('参数错误')));
    },

    "/qizhengsiyu/ge_ju/create": (context, {arguments}) {
      String? duplicateFromId;
      String? saveAsFromId;
      if (arguments is Map) {
        duplicateFromId = arguments['duplicate'] as String?;
        saveAsFromId = arguments['saveAs'] as String?;
      }
      return GeJuEditorPage(
        duplicateFromId: duplicateFromId,
        saveAsFromId: saveAsFromId,
      );
    },

    "/qizhengsiyu/ge_ju/edit": (context, {arguments}) {
      final ruleId = arguments as String?;
      return GeJuEditorPage(ruleId: ruleId);
    },

    // ============ 流派管理路由 ============
    "/qizhengsiyu/ge_ju/school/list": (context, {arguments}) => const GeJuSchoolListPage(),

    "/qizhengsiyu/ge_ju/school/edit": (context, {arguments}) {
      final schoolId = arguments as String?;
      return GeJuSchoolEditorPage(schoolId: schoolId);
    },
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name != null && name.isNotEmpty) {
      final Function? pageContentBuilder = routes[name];
      if (pageContentBuilder != null) {
        final Route route = MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        // 未知路由回退到首页（处理 Web 端 initialRoute 路径拆分产生的中间路由）
        logger.w('Unknown route: $name, falling back to home');
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => const QiZhengSiYuHomePage());
      }
    } else {
      return MaterialPageRoute(
          settings: settings,
          builder: (_) => const QiZhengSiYuHomePage());
    }
  }

  static Route _errorPage(msg) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: const Text('奇门遁甲_未知页面')),
          body: Center(child: Text(msg)));
    });
  }

  static Route<dynamic> generateRoute1(RouteSettings settings) {
    switch (settings.name) {
      case '/qizhengsiyu/primary':
        return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            // pageBuilder: (_, __, ___) => CreateOrderPage(settings.arguments == null ?null:settings.arguments as CreateOrderPageArgs),
            pageBuilder: (_, __, ___) => const PrimaryPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );
              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            });
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
