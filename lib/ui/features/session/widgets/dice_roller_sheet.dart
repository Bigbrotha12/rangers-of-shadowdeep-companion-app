import 'dart:math' show Random;

import 'package:flutter/material.dart';

class DiceRollerSheet extends StatefulWidget {
  const DiceRollerSheet({super.key});

  @override
  State<DiceRollerSheet> createState() => _DiceRollerSheetState();
}

class _DiceRollerSheetState extends State<DiceRollerSheet> {
  final _modifierController = TextEditingController(text: '0');
  int? _lastRoll;
  final List<String> _history = [];

  @override
  void dispose() {
    _modifierController.dispose();
    super.dispose();
  }

  void _rollDice() {
    final modifier = int.tryParse(_modifierController.text) ?? 0;
    final roll = Random().nextInt(20) + 1;
    final total = roll + modifier;

    setState(() {
      _lastRoll = total;
      _history.insert(0, 'd20: $roll${modifier != 0 ? (modifier > 0 ? ' + $modifier' : ' - ${modifier.abs()}') : ''} = $total');
      if (_history.length > 10) _history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Dice Roller',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Roll result
          if (_lastRoll != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  '$_lastRoll',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.casino,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),

          // Modifier input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _modifierController,
                  decoration: const InputDecoration(
                    labelText: 'Modifier',
                    prefixIcon: Icon(Icons.calculate),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Roll button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text('Roll d20'),
            ),
          ),
          const SizedBox(height: 16),

          // History
          if (_history.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _history[index],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
