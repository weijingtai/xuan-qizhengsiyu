import 'package:provider/single_child_widget.dart';

import '../../di.dart' as di_module;
import '../../qizhengsiyu_storage_dependencies.dart';
import 'qizhengsiyu_routes.dart';

final class QiZhengSiYuModuleManifest {
  const QiZhengSiYuModuleManifest._();

  static const String id = 'qizhengsiyu';
  static const String displayNameKey = 'module_qizhengsiyu_name';
  static const String version = '1.0.1';
  static const String minShellVersion = '0.1.0-a3';

  static List<SingleChildWidget> createProviders(QiZhengSiYuStorageDependencies deps) {
    return di_module.createProviders(deps);
  }

  static List<QiZhengSiYuRoute> createRoutes() {
    return QiZhengSiYuRoutes.all;
  }
}
