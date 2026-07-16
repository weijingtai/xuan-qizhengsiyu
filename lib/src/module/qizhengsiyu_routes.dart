import 'package:flutter/widgets.dart';
import 'package:qizhengsiyu/presentation/pages/beauty_view_page.dart';
import 'package:qizhengsiyu/presentation/pages/qizhengsiyu_home_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_list_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_detail_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_editor_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_school_list_page.dart';
import 'package:qizhengsiyu/presentation/pages/ge_ju/ge_ju_school_editor_page.dart';

final class QiZhengSiYuRoute {
  final String path;
  final String? redirectTo;
  final WidgetBuilder? builder;
  final String? name;
  final Map<String, String>? params;

  const QiZhengSiYuRoute({
    this.redirectTo,
    this.builder,
    this.name,
    this.params,
    required this.path,
  });
}

final class QiZhengSiYuRoutes {
  QiZhengSiYuRoutes._();

  static final List<QiZhengSiYuRoute> all = [
    // ============ 模块根路由 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu',
      redirectTo: '/modules/qizhengsiyu/panel',
    ),

    // ============ 星盘面板 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/panel',
      name: 'module.qizhengsiyu.panel',
      builder: (_) => const BeautyViewPage(),
    ),

    // ============ 七政四余首页 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/home',
      name: 'module.qizhengsiyu.home',
      builder: (_) => const QiZhengSiYuHomePage(),
    ),

    // ============ 格局列表 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/list',
      name: 'module.qizhengsiyu.ge_ju.list',
      builder: (_) => const GeJuListPage(),
    ),

    // ============ 格局详情 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/detail/:ruleId',
      name: 'module.qizhengsiyu.ge_ju.detail',
      params: {'ruleId': 'String'},
    ),

    // ============ 格局创建（支持 duplicate / saveAs 查询参数） ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/create',
      name: 'module.qizhengsiyu.ge_ju.create',
      params: {'duplicate': 'String?', 'saveAs': 'String?'},
    ),

    // ============ 格局编辑 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/edit/:ruleId',
      name: 'module.qizhengsiyu.ge_ju.edit',
      params: {'ruleId': 'String?'},
    ),

    // ============ 流派列表 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/school/list',
      name: 'module.qizhengsiyu.ge_ju.school.list',
      builder: (_) => const GeJuSchoolListPage(),
    ),

    // ============ 流派编辑 ============
    QiZhengSiYuRoute(
      path: '/modules/qizhengsiyu/ge_ju/school/edit/:schoolId?',
      name: 'module.qizhengsiyu.ge_ju.school.edit',
      params: {'schoolId': 'String?'},
    ),

    // ============ 旧路径重定向 ============
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/panel',
      redirectTo: '/modules/qizhengsiyu/panel',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/home',
      redirectTo: '/modules/qizhengsiyu/home',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/list',
      redirectTo: '/modules/qizhengsiyu/ge_ju/list',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/detail',
      redirectTo: '/modules/qizhengsiyu/ge_ju/list',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/create',
      redirectTo: '/modules/qizhengsiyu/ge_ju/create',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/edit',
      redirectTo: '/modules/qizhengsiyu/ge_ju/list',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/school/list',
      redirectTo: '/modules/qizhengsiyu/ge_ju/school/list',
    ),
    QiZhengSiYuRoute(
      path: '/qizhengsiyu/ge_ju/school/edit',
      redirectTo: '/modules/qizhengsiyu/ge_ju/school/list',
    ),
  ];
}
