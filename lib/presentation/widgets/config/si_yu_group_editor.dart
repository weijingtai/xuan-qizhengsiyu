import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/entities/models/si_yu_group.dart';
import 'package:qizhengsiyu/domain/entities/models/si_yu_group_spec.dart';

class SiYuGroupEditor extends StatefulWidget {
  final SiYuGroup group;
  final SiYuGroupSpec spec;
  final CelestialCoordinateSystem coordinate;
  final ValueChanged<SiYuGroupSpec> onChanged;

  const SiYuGroupEditor({
    super.key,
    required this.group,
    required this.spec,
    required this.coordinate,
    required this.onChanged,
  });

  @override
  State<SiYuGroupEditor> createState() => _SiYuGroupEditorState();
}

class _SiYuGroupEditorState extends State<SiYuGroupEditor> {
  late String _kind;
  late Map<String, double> _params;
  late List<SiYuSegmentSpec> _segments;
  late int _rahuKetuConventionIndex;

  @override
  void initState() {
    super.initState();
    _initFromSpec();
  }

  @override
  void didUpdateWidget(SiYuGroupEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spec != widget.spec) {
      _initFromSpec();
    }
  }

  void _initFromSpec() {
    _kind = widget.spec.kind;
    _params = Map.from(widget.spec.params);
    _segments = widget.spec.segments != null
        ? List.from(widget.spec.segments!)
        : [];
    _rahuKetuConventionIndex = widget.spec.rahuKetuConventionIndex ?? 0;
  }

  void _notifyChange() {
    widget.onChanged(SiYuGroupSpec(
      kind: _kind,
      params: _params,
      segments: _segments.isEmpty ? null : _segments,
      rahuKetuConventionIndex:
          widget.group == SiYuGroup.luoJi ? _rahuKetuConventionIndex : null,
    ));
  }

  List<String> get _availableKinds {
    switch (widget.group) {
      case SiYuGroup.luoJi:
        return const ['ephemeris_node', 'linear_node'];
      case SiYuGroup.yueBo:
        return const ['ephemeris_apogee', 'linear_apogee'];
      case SiYuGroup.ziQi:
        return const ['linear_ziqi', 'shixian_ziqi', 'yelv_tianguan_ziqi'];
    }
  }

  String _kindName(String kind) {
    switch (kind) {
      case 'ephemeris_node':
        return '星历平交点';
      case 'linear_node':
        return '古法平行升交点';
      case 'ephemeris_apogee':
        return '星历平均远地点';
      case 'linear_apogee':
        return '古法平行月孛';
      case 'linear_ziqi':
        return '果老紫气平行';
      case 'shixian_ziqi':
        return '清时宪紫气';
      case 'yelv_tianguan_ziqi':
        return '耶律天官紫气';
      default:
        return kind;
    }
  }

  bool get _showParams {
    return _kind.startsWith('linear') || _kind == 'yelv_tianguan_ziqi' || _kind == 'shixian_ziqi';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.group == SiYuGroup.luoJi
        ? '罗计配置'
        : widget.group == SiYuGroup.yueBo
            ? '月孛配置'
            : '紫气配置';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _kind,
              decoration: const InputDecoration(labelText: '推算类型'),
              items: _availableKinds
                  .map((k) => DropdownMenuItem(value: k, child: Text(_kindName(k))))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _kind = v;
                    _notifyChange();
                  });
                }
              },
            ),
            if (widget.group == SiYuGroup.luoJi) ...[
              const SizedBox(height: 12),
              const Text('罗计交点约定', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('罗降计升(默认)')),
                  ButtonSegment(value: 1, label: Text('罗升计降(新法)')),
                ],
                selected: {_rahuKetuConventionIndex},
                onSelectionChanged: (set) {
                  setState(() {
                    _rahuKetuConventionIndex = set.first;
                    _notifyChange();
                  });
                },
              ),
            ],
            if (_showParams) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _params['totalDegree']?.toString() ??
                          (widget.coordinate == CelestialCoordinateSystem.Ecliptic
                              ? '360.0'
                              : '365.25'),
                      decoration: const InputDecoration(labelText: '坐标总度数 (totalDegree)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null) {
                          _params['totalDegree'] = val;
                          _notifyChange();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _params['dailyMotion']?.toString() ?? '0.0',
                      decoration: const InputDecoration(labelText: '日行度数 (dailyMotion)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null) {
                          _params['dailyMotion'] = val;
                          _notifyChange();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _params['epochJulianDay']?.toString() ?? '0.0',
                      decoration: const InputDecoration(labelText: '历元儒略日 (epochJulianDay)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null) {
                          _params['epochJulianDay'] = val;
                          _notifyChange();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _params['epochPosition']?.toString() ?? '0.0',
                      decoration: const InputDecoration(labelText: '历元起点经度 (epochPosition)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null) {
                          _params['epochPosition'] = val;
                          _notifyChange();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('方向：'),
                  Radio<int>(
                    value: 1,
                    groupValue: (_params['direction'] ?? 1).toInt(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _params['direction'] = v.toDouble();
                          _notifyChange();
                        });
                      }
                    },
                  ),
                  const Text('顺行 (+1)'),
                  const SizedBox(width: 12),
                  Radio<int>(
                    value: -1,
                    groupValue: (_params['direction'] ?? 1).toInt(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _params['direction'] = v.toDouble();
                          _notifyChange();
                        });
                      }
                    },
                  ),
                  const Text('逆行 (-1)'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('时间分段节点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _segments.add(SiYuSegmentSpec(
                        fromJulianDay: 2440000.0, // default JD
                        spec: SiYuGroupSpec(kind: _kind, params: Map.from(_params)),
                      ));
                      _notifyChange();
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('增加分段'),
                ),
              ],
            ),
            ..._segments.asMap().entries.map((entry) {
              final idx = entry.key;
              final seg = entry.value;
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: seg.fromJulianDay.toString(),
                            decoration: const InputDecoration(labelText: '起算儒略日 (fromJulianDay)'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = double.tryParse(v);
                              if (val != null) {
                                _segments[idx] = SiYuSegmentSpec(
                                  fromJulianDay: val,
                                  spec: seg.spec,
                                );
                                _notifyChange();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _segments.removeAt(idx);
                              _notifyChange();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: seg.spec.kind,
                      decoration: const InputDecoration(labelText: '分段算法类型'),
                      items: _availableKinds
                          .map((k) => DropdownMenuItem(value: k, child: Text(_kindName(k))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _segments[idx] = SiYuSegmentSpec(
                              fromJulianDay: seg.fromJulianDay,
                              spec: SiYuGroupSpec(
                                kind: v,
                                params: seg.spec.params,
                                segments: seg.spec.segments,
                                rahuKetuConventionIndex: seg.spec.rahuKetuConventionIndex,
                              ),
                            );
                            _notifyChange();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
