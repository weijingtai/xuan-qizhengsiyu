import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';

void main() {
  group('ZhouTianModel Serialization Tests', () {
    final baseJson = {
      "systemType": "ecliptic",
      "constellationSystemType": "classical",
      "panelSystemType": "tropical",
      "epochCorrection": "none",
      "totalDegree": 360.0,
      "gongDegreeSeq": [],
      "starInnDegreeSeq": [],
      "alignmentPointAtConstellation": {"constellation": "虚", "degree": 6.0},
      "alignmentPointAtGong": {"gong": "子", "degree": 15.0},
      "zeroPointJieQi": "春分",
      "zeroPointAtConstellation": {"constellation": "室", "degree": 6.5},
      "zeroPointAtGong": {"gong": "戌", "degree": 0.0},
      "celestialLongitude": 0.0,
      "zeroPointOffsetToNow": 0.0,
      "rightAscension": 0.0,
      "specificationList": [],
      "gongOrder": ["子"],
      "starInnOrder": ["角"]
    };

    test('Should handle missing projectionConfig (Backward Compatibility)', () {
      final model = ZhouTianModel.fromJson(baseJson);
      expect(model.projectionConfig, isNull);
    });

    test('Should deserialize Linear ProjectionConfig', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['projectionConfig'] = {
        "strategy": "linear",
        "offset": 5.5
      };

      final model = ZhouTianModel.fromJson(json);
      expect(model.projectionConfig?.strategy, MappingStrategy.linear);
      expect(model.projectionConfig?.offset, 5.5);
    });

    test('Should deserialize Piecewise ProjectionConfig', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['projectionConfig'] = {
        "strategy": "piecewise",
        "sourcePoints": [0.0, 180.0, 360.0],
        "targetPoints": [0.0, 182.0, 365.25]
      };

      final model = ZhouTianModel.fromJson(json);
      expect(model.projectionConfig?.strategy, MappingStrategy.piecewise);
      expect(model.projectionConfig?.sourcePoints, containsAll([0.0, 180.0, 360.0]));
    });
  });
}
