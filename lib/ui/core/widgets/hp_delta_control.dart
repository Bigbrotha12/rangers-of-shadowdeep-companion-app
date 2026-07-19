import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';

class HpDeltaControl extends StatefulWidget {
  final int delta;
  final ValueChanged<int> onDecrement;
  final ValueChanged<int> onIncrement;

  const HpDeltaControl({
    required this.delta,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  @override
  State<HpDeltaControl> createState() => _HpDeltaControlState();
}

class _HpDeltaControlState extends State<HpDeltaControl> {
  late final TextEditingController _controller;
  late int _delta;

  @override
  void initState() {
    super.initState();
    _delta = widget.delta;
    _controller = TextEditingController(text: '$_delta');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
          onPressed: () => widget.onDecrement(_delta),
          iconSize: 28,
        ),
        SizedBox(
          width: 44,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              setState(() {
                _delta = int.tryParse(v) ?? 1;
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: statusGreen(theme)),
          onPressed: () => widget.onIncrement(_delta),
          iconSize: 28,
        ),
      ],
    );
  }
}
