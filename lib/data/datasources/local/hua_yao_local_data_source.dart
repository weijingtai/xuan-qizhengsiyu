import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../domain/entities/models/hua_yao.dart';

abstract class HuaYaoLocalDataSource {
  Future<List<TianGanHuaYao>> getTianGanHuaYao();
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao();
  Future<List<OthersHuaYao>> getOthersHuaYao();
}

class HuaYaoLocalDataSourceImpl implements HuaYaoLocalDataSource {
  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_huayao_tiangan.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => TianGanHuaYao.fromJson(e)).toList();
  }

  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_huayao_dizhi.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => DiZhiHuaYao.fromJson(e)).toList();
  }

  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_huayao_others.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => OthersHuaYao.fromJson(e)).toList();
  }
}
