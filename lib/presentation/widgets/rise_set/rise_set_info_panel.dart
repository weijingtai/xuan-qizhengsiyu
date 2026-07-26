import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/rise_set_display_data.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/utils/coordinate_converter.dart';

// ─── 调色板（与 HuaYaoResultPanel / GeJuResultPanel 保持一致）───────────────────

class _C {
  // 本命色系 — 暖色（琥珀/橙）
  static const natalBg = Color(0xFFFFFBEB);
  static const natalText = Color(0xFFD97706);
  static const natalBorder = Color(0xFFFDE68A);

  // 流年色系 — 冷色（靛蓝）
  static const transitBg = Color(0xFFEEF2FF);
  static const transitText = Color(0xFF4F46E5);
  static const transitBorder = Color(0xFFC7D2FE);

  // 通用
  static const pageBg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const badgeBg = Color(0xFFF1F5F9);
  static const dividerColor = Color(0xFFF1F5F9);
}

// ─── 日月出没信息面板 ─────────────────────────────────────────────────────────────

class RiseSetInfoPanel extends StatefulWidget {
  const RiseSetInfoPanel({super.key});

  @override
  State<RiseSetInfoPanel> createState() => _RiseSetInfoPanelState();
}

class _RiseSetInfoPanelState extends State<RiseSetInfoPanel> {
  bool _isCustomMode = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<QiZhengSiYuViewModel>();

    return ValueListenableBuilder<RiseSetDisplayData?>(
      valueListenable:
          _isCustomMode ? vm.customRiseSetNotifier : vm.birthRiseSetNotifier,
      builder: (context, data, _) {
        if (data == null) return const SizedBox.shrink();
        return Container(
          color: _C.pageBg,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: _buildCard(context, data, vm),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    RiseSetDisplayData data,
    QiZhengSiYuViewModel vm,
  ) {
    final accentBg = _isCustomMode ? _C.transitBg : _C.natalBg;
    final accentText = _isCustomMode ? _C.transitText : _C.natalText;
    final accentBorder = _isCustomMode ? _C.transitBorder : _C.natalBorder;

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 25,
            offset: Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行 + 模式切换
            _buildTitleRow(accentBg, accentText, accentBorder),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _C.dividerColor),
            const SizedBox(height: 12),

            // 日期 + 节气
            _buildDateRow(context, data, vm, accentText),
            const SizedBox(height: 8),

            // 真太阳时
            _buildInfoRow('真太阳时间', _formatTime12(data.trueSolarTime)),
            const SizedBox(height: 8),

            // 阴历
            _buildInfoRow(
              '阴历',
              '${data.lunarDateString}${data.lunarTimeString}'
              '（${data.isDayBirth ? "昼" : "夜"}）',
            ),
            const SizedBox(height: 8),

            // 经纬度
            _buildCoordinateRow(data),
            const SizedBox(height: 8),

            // 地点
            if (data.locationName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  data.locationName!,
                  style: const TextStyle(fontSize: 13, color: _C.textMuted),
                ),
              ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: _C.dividerColor),
            const SizedBox(height: 12),

            // 日出/日落
            _buildRiseSetRow(
              '\u2600', // ☀
              '日出',
              data.sunRise,
              '日落',
              data.sunSet,
              const Color(0xFFEA580C),
            ),
            const SizedBox(height: 8),

            // 月出/月落
            _buildRiseSetRow(
              '\u263D', // ☽
              '月出',
              data.moonRise,
              '月落',
              data.moonSet,
              const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 标题行 ──────────────────────────────────────────────────────────────

  Widget _buildTitleRow(Color bg, Color text, Color border) {
    return Row(
      children: [
        const Text(
          '日月出没',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _C.textMain,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        _buildModeToggle(bg, text, border),
      ],
    );
  }

  Widget _buildModeToggle(Color activeBg, Color activeText, Color activeBorder) {
    return Container(
      decoration: BoxDecoration(
        color: _C.badgeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('出生时', !_isCustomMode, activeBg, activeText, activeBorder),
          _toggleOption('自定义', _isCustomMode, activeBg, activeText, activeBorder),
        ],
      ),
    );
  }

  Widget _toggleOption(
    String label,
    bool isActive,
    Color activeBg,
    Color activeText,
    Color activeBorder,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _isCustomMode = label == '自定义'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? Border.all(color: activeBorder, width: 0.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? activeText : _C.textMuted,
          ),
        ),
      ),
    );
  }

  // ─── 信息行 ──────────────────────────────────────────────────────────────

  Widget _buildDateRow(
    BuildContext context,
    RiseSetDisplayData data,
    QiZhengSiYuViewModel vm,
    Color accentText,
  ) {
    final dateStr = DateFormat('M/d/yyyy hh:mma').format(data.localDateTime);
    final jieQi = data.jieQiInfo ?? '';

    if (_isCustomMode) {
      return GestureDetector(
        onTap: () => _pickDate(context, vm),
        child: Row(
          children: [
            Text(
              '$dateStr  $jieQi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accentText,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit_calendar, size: 14, color: accentText),
          ],
        ),
      );
    }

    return Text(
      '$dateStr  $jieQi',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _C.textMain,
      ),
    );
  }

  /// 该处属第三类时间语义（天象查询日期），与起课时间/命盘生日均不同，
  /// 现有 QueryTimeInputCard 双模式不覆盖；若未来出现第二个天象查询消费方，
  /// 再抽 QueryTimeInputCard 第三模式，当前不做通用组件。
  @Deprecated('原生 picker 待迁移至 TL 统一输入；当前该 panel 零挂载，保留待接。')
  Future<void> _pickDate(BuildContext context, QiZhengSiYuViewModel vm) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      vm.updateCustomDate(selected);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label\uff1a',
          style: const TextStyle(fontSize: 13, color: _C.textMuted),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _C.textMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinateRow(RiseSetDisplayData data) {
    final lonStr =
        CoordinateConverter.formatDms(data.longitude, isLongitude: true);
    final latStr =
        CoordinateConverter.formatDms(data.latitude, isLongitude: false);
    return Row(
      children: [
        Text('经\uff1a$lonStr',
            style: const TextStyle(fontSize: 13, color: _C.textMain)),
        const SizedBox(width: 16),
        Text('纬\uff1a$latStr',
            style: const TextStyle(fontSize: 13, color: _C.textMain)),
      ],
    );
  }

  // ─── 日月出没行 ─────────────────────────────────────────────────────────

  Widget _buildRiseSetRow(
    String icon,
    String riseLabel,
    DateTime? rise,
    String setLabel,
    DateTime? set_,
    Color iconColor,
  ) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 16, color: iconColor)),
        const SizedBox(width: 8),
        Text(
          '$riseLabel ${_formatTime24(rise)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _C.textMain,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          '$setLabel ${_formatTime24(set_)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _C.textMain,
          ),
        ),
      ],
    );
  }

  // ─── 时间格式化 ─────────────────────────────────────────────────────────

  String _formatTime12(DateTime? dt) {
    if (dt == null) return '---';
    return DateFormat('hh:mma').format(dt);
  }

  String _formatTime24(DateTime? dt) {
    if (dt == null) return '---';
    return DateFormat('HH:mm').format(dt);
  }
}
