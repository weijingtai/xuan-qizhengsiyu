import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:metaphysics_core/enums.dart';

class QiZhengStarPalette {
  final Map<EnumStars, Color> _zhengColorMap;
  final Map<EnumStars, Color> _starsColorMap;

  QiZhengStarPalette({
    required Map<EnumStars, Color> zhengColorMap,
    required Map<EnumStars, Color> starsColorMap,
  })  : _zhengColorMap = Map.unmodifiable(zhengColorMap),
        _starsColorMap = Map.unmodifiable(starsColorMap);

  Color zhengColor(EnumStars star) {
    return _zhengColorMap[star] ?? _fallbackZhengColor;
  }

  Color starColor(EnumStars star) {
    return _starsColorMap[star] ?? _fallbackStarColor;
  }

  Map<EnumStars, Color> get zhengColorMap => _zhengColorMap;
  Map<EnumStars, Color> get starsColorMap => _starsColorMap;

  static const Color _fallbackZhengColor = Color(0xFF000000);
  static const Color _fallbackStarColor = Color(0xFF000000);

  static QiZhengStarPalette fallback({Brightness brightness = Brightness.light}) {
    return QiZhengStarPalette(
      zhengColorMap: _lightZhengColorMap,
      starsColorMap: _lightStarsColorMap,
    );
  }

  static const Map<EnumStars, Color> _lightZhengColorMap = {
    EnumStars.Sun: Color.fromRGBO(67, 60, 45, 1),
    EnumStars.Moon: Color.fromRGBO(214, 236, 240, 1),
    EnumStars.Mars: Color.fromRGBO(233, 84, 100, 1),
    EnumStars.Saturn: Color.fromRGBO(168, 132, 98, 1),
    EnumStars.Mercury: Color.fromRGBO(76, 141, 174, 1),
    EnumStars.Jupiter: Color.fromRGBO(84, 150, 136, 1),
    EnumStars.Venus: Color.fromRGBO(240, 167, 46, 1),
  };

  static const Map<EnumStars, Color> _lightStarsColorMap = {
    EnumStars.Sun: Color.fromRGBO(255, 164, 0, 1),
    EnumStars.Moon: Color.fromRGBO(161, 175, 201, 1),
    EnumStars.Mars: Color.fromRGBO(233, 84, 100, 1),
    EnumStars.Saturn: Color.fromRGBO(137, 108, 57, 1),
    EnumStars.Mercury: Color.fromRGBO(76, 141, 174, 1),
    EnumStars.Jupiter: Color.fromRGBO(84, 150, 136, 1),
    EnumStars.Venus: Color.fromRGBO(242, 190, 69, 1),
    EnumStars.Qi: Color.fromRGBO(141, 75, 187, 1),
    EnumStars.Bei: Color.fromRGBO(66, 80, 102, 1),
    EnumStars.Ji: Color.fromRGBO(211, 177, 125, 1),
    EnumStars.Luo: Color.fromRGBO(179, 92, 68, 1),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QiZhengStarPalette &&
          const MapEquality<EnumStars, Color>()
              .equals(_zhengColorMap, other._zhengColorMap) &&
          const MapEquality<EnumStars, Color>()
              .equals(_starsColorMap, other._starsColorMap);

  @override
  int get hashCode => Object.hash(
        const MapEquality<EnumStars, Color>().hash(_zhengColorMap),
        const MapEquality<EnumStars, Color>().hash(_starsColorMap),
      );
}
