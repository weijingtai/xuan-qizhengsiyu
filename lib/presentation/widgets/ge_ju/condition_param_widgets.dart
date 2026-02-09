import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/condition_type_registry.dart';

/// 根据参数定义构建对应的参数编辑器
Widget buildParamEditor(
  ConditionParamDefinition def,
  dynamic value,
  ValueChanged<dynamic> onChange,
) {
  switch (def.paramType) {
    case ConditionParamType.star:
      return _StarDropdown(
        label: def.displayName,
        value: value as String?,
        onChanged: onChange,
      );
    case ConditionParamType.starList:
      return _StarMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.gongList:
      return _GongMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.constellationList:
      return _ConstellationMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.walkingStateList:
      return _WalkingStateMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.fourTypeList:
      return _FourTypeMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.huaYaoList:
      return _HuaYaoMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.seasonList:
      return _SeasonMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.moonPhaseList:
      return _MoonPhaseMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.gongStatusList:
      return _GongStatusMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.roleList:
      return _RoleMultiSelect(
        label: def.displayName,
        selected: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.destinyGong:
      return _DestinyGongDropdown(
        label: def.displayName,
        value: value as String?,
        onChanged: onChange,
      );
    case ConditionParamType.gongIdentifier:
      return _GongIdentifierDropdown(
        label: def.displayName,
        value: value as String?,
        onChanged: onChange,
      );
    case ConditionParamType.shenShaList:
      return _ShenShaTextInput(
        label: def.displayName,
        values: _toStringList(value),
        onChanged: onChange,
      );
    case ConditionParamType.boolean:
      return _BooleanSwitch(
        label: def.displayName,
        value: value as bool? ?? def.defaultValue as bool? ?? false,
        onChanged: onChange,
      );
    case ConditionParamType.string:
      return _StringInput(
        label: def.displayName,
        value: value as String? ?? '',
        onChanged: onChange,
      );
    case ConditionParamType.gong:
      return _GongDropdown(
        label: def.displayName,
        value: value as String?,
        onChanged: onChange,
      );
    case ConditionParamType.constellation:
      return _ConstellationDropdown(
        label: def.displayName,
        value: value as String?,
        onChanged: onChange,
      );
  }
}

List<String> _toStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

// ============================================================
// Single-select dropdowns
// ============================================================

class _StarDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _StarDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stars = ConditionParamOptions.stars;
    return _ParamSection(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: stars
            .map((s) => DropdownMenuItem(
                  value: s.singleName,
                  child: Text('${s.starName}(${s.singleName})'),
                ))
            .toList(),
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

class _GongDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _GongDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gongs = ConditionParamOptions.gongs;
    return _ParamSection(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: gongs
            .map((g) => DropdownMenuItem(
                  value: g.name,
                  child: Text(g.name),
                ))
            .toList(),
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

class _ConstellationDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _ConstellationDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final constellations = ConditionParamOptions.constellations;
    return _ParamSection(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: constellations
            .map((c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.fullname),
                ))
            .toList(),
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

class _DestinyGongDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _DestinyGongDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gongs = ConditionParamOptions.destinyGongs;
    return _ParamSection(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: gongs
            .map((g) => DropdownMenuItem(
                  value: g.name,
                  child: Text(g.name),
                ))
            .toList(),
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

class _GongIdentifierDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<dynamic> onChanged;

  const _GongIdentifierDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final specialItems = ConditionParamOptions.specialGongIdentifiers
        .map((id) => DropdownMenuItem(
              value: id,
              child: Text(ConditionParamOptions.specialGongDisplayNames[id] ?? id),
            ))
        .toList();
    final gongItems = ConditionParamOptions.gongs
        .map((g) => DropdownMenuItem(
              value: g.name,
              child: Text('${g.name}宫'),
            ))
        .toList();

    return _ParamSection(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [...specialItems, ...gongItems],
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

// ============================================================
// Multi-select chip widgets
// ============================================================

class _StarMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _StarMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stars = ConditionParamOptions.stars;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: stars.map((s) {
          final isSelected = selected.contains(s.singleName);
          return FilterChip(
            label: Text(s.starName),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(s.singleName);
              } else {
                newList.remove(s.singleName);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _GongMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _GongMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gongs = ConditionParamOptions.gongs;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: gongs.map((g) {
          final isSelected = selected.contains(g.name);
          return FilterChip(
            label: Text(g.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(g.name);
              } else {
                newList.remove(g.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ConstellationMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _ConstellationMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final constellations = ConditionParamOptions.constellations;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: constellations.map((c) {
          final isSelected = selected.contains(c.name);
          return FilterChip(
            label: Text(c.fullname),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(c.name);
              } else {
                newList.remove(c.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _WalkingStateMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _WalkingStateMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final states = ConditionParamOptions.walkingStates;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: states.map((s) {
          final isSelected = selected.contains(s.name);
          return FilterChip(
            label: Text(s.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(s.name);
              } else {
                newList.remove(s.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _FourTypeMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _FourTypeMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = ConditionParamOptions.fourTypes;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: types.map((t) {
          final isSelected = selected.contains(t.name);
          return FilterChip(
            label: Text(t.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(t.name);
              } else {
                newList.remove(t.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _HuaYaoMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _HuaYaoMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yaos = ConditionParamOptions.huaYaos;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: yaos.map((h) {
          final isSelected = selected.contains(h.name);
          return FilterChip(
            label: Text(h.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(h.name);
              } else {
                newList.remove(h.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SeasonMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _SeasonMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final seasons = ConditionParamOptions.seasons;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: seasons.map((s) {
          final isSelected = selected.contains(s.name);
          return FilterChip(
            label: Text(s.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(s.name);
              } else {
                newList.remove(s.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _MoonPhaseMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _MoonPhaseMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final phases = ConditionParamOptions.moonPhases;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: phases.map((p) {
          final isSelected = selected.contains(p.name);
          return FilterChip(
            label: Text(p.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(p.name);
              } else {
                newList.remove(p.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _GongStatusMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _GongStatusMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ConditionParamOptions.gongStatuses;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: statuses.map((s) {
          final isSelected = selected.contains(s.name);
          return FilterChip(
            label: Text(s.name),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(s.name);
              } else {
                newList.remove(s.name);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _RoleMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<dynamic> onChanged;

  const _RoleMultiSelect({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roles = ConditionParamOptions.siZhuRoles;
    final displayNames = ConditionParamOptions.siZhuRoleDisplayNames;
    return _ParamSection(
      label: label,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: roles.map((r) {
          final isSelected = selected.contains(r);
          return FilterChip(
            label: Text(displayNames[r] ?? r),
            selected: isSelected,
            onSelected: (sel) {
              final newList = List<String>.from(selected);
              if (sel) {
                newList.add(r);
              } else {
                newList.remove(r);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// Text input widgets
// ============================================================

class _ShenShaTextInput extends StatefulWidget {
  final String label;
  final List<String> values;
  final ValueChanged<dynamic> onChanged;

  const _ShenShaTextInput({
    required this.label,
    required this.values,
    required this.onChanged,
  });

  @override
  State<_ShenShaTextInput> createState() => _ShenShaTextInputState();
}

class _ShenShaTextInputState extends State<_ShenShaTextInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.values.contains(text)) return;
    final newList = [...widget.values, text];
    widget.onChanged(newList);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return _ParamSection(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.values.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.values.map((v) {
                  return Chip(
                    label: Text(v),
                    onDeleted: () {
                      final newList = widget.values.where((e) => e != v).toList();
                      widget.onChanged(newList);
                    },
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '输入神煞名称',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onFieldSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _addItem,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BooleanSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<dynamic> onChanged;

  const _BooleanSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ParamSection(
      label: label,
      child: SwitchListTile(
        value: value,
        onChanged: (v) => onChanged(v),
        title: Text(value ? '是' : '否'),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

class _StringInput extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<dynamic> onChanged;

  const _StringInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ParamSection(
      label: label,
      child: TextFormField(
        initialValue: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

// ============================================================
// Common section wrapper
// ============================================================

class _ParamSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _ParamSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
