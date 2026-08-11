import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

/// 星历资源文件名路由纯函数测试（2026-08-10）。
///
/// 回归：旧实现硬编码 `adjested`/`ecplictic` 拼写错误，与源资产文件名
/// 不符，AdjustedClassical/Modern 模式运行时资源不存在
/// （StorageError: ephemeris 资源不存在）。本测试锁定文件名映射契约，
/// 文件名须与 ephemeris 数据集（ephemeris_document）收录一致。
void main() {
  BasePanelConfig _cfg({
    required CelestialCoordinateSystem celestialCoordinateSystem,
    PanelSystemType panelSystemType = PanelSystemType.Tropical,
    ConstellationSystemType constellationSystemType =
        ConstellationSystemType.Classical,
  }) {
    return BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: celestialCoordinateSystem,
      panelSystemType: panelSystemType,
      constellationSystemType: constellationSystemType,
    );
  }

  test('Ecliptic×Tropical×Classical → ecliptic_tropical_classical.json', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      )),
      'ecliptic_tropical_classical.json',
    );
  });

  test('Ecliptic×Tropical×AdjustedClassical → ..._adjusted.json（拼写回归）', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
        constellationSystemType: ConstellationSystemType.AdjustedClassical,
      )),
      'ecliptic_tropical_classical_adjusted.json',
    );
  });

  test('Ecliptic×Tropical×Modern → ecliptic_tropical_morden.json（拼写回归）', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
        constellationSystemType: ConstellationSystemType.Modern,
      )),
      'ecliptic_tropical_morden.json',
    );
  });

  test('SkyEquatorial → yuan_shoushi_chidao_hengxin.json', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
      )),
      'yuan_shoushi_chidao_hengxin.json',
    );
  });

  test('Equatorial 复用赤道基准资产', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.Equatorial,
      )),
      'yuan_shoushi_chidao_hengxin.json',
    );
  });

  test('PseudoEcliptic 复用赤道基准资产', () {
    expect(
      resolveEphemerisAssetName(_cfg(
        celestialCoordinateSystem: CelestialCoordinateSystem.PseudoEcliptic,
      )),
      'yuan_shoushi_chidao_hengxin.json',
    );
  });
}
