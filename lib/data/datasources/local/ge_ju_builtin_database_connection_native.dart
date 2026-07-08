import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor createGeJuBuiltInConnection() {
  return LazyDatabase(() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(supportDir.path, 'ge_ju_builtin.sqlite'));

    final data = await rootBundle
        .load('assets/qizhengsiyu/ge_ju/ge_ju_database.sqlite');
    await dbFile.writeAsBytes(data.buffer.asUint8List());

    return NativeDatabase(dbFile, logStatements: false);
  });
}
