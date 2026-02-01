import 'dart:convert';

import 'dart:convert';

import 'package:common/models/shen_sha_bundled.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/models/shen_sha_tian_gan.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/domain/entities/entities_temp/di_zhi_shen_sha.dart';

import '../../../domain/entities/models/di_zhi_shen_sha.dart';

abstract class ShenShaLocalDataSource {
  Future<List<TianGanShenSha>> getTianGanShenSha();
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha();
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha();
  Future<List<GanZhiShenSha>> getGanZhiShenSha();
  Future<List<BundledShenSha>> getBundledShenSha();
  Future<List<OtherShenSha>> getOtherShenSha();
}

class ShenShaLocalDataSourceImpl implements ShenShaLocalDataSource {
  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_shensha_tiangan.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => TianGanShenSha.fromJson(e)).toList();
  }

  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async {
    final jsonString = await rootBundle
        .loadString('assets/shen_sha/74_shensha_dizhi_year.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => YearDiZhiShenSha.fromJson(e)).toList();
  }

  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async {
    final jsonString = await rootBundle
        .loadString('assets/shen_sha/74_shensha_dizhi_month.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => MonthDiZhiShenSha.fromJson(e)).toList();
  }

  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_shensha_ganzhi.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => GanZhiShenSha.fromJson(e)).toList();
  }

  @override
  Future<List<BundledShenSha>> getBundledShenSha() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_shensha_bundle.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => BundledShenSha.fromJson(e)).toList();
  }

  @override
  Future<List<OtherShenSha>> getOtherShenSha() async {
    final jsonString =
        await rootBundle.loadString('assets/shen_sha/74_shensha_others.json');
    final list = json.decode(jsonString) as List;
    return list.map((e) => OtherShenSha.fromJson(e)).toList();
  }
}
