import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/reference_provider.dart';

class QuickReferenceCardView extends ConsumerWidget {
  const QuickReferenceCardView({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(quickReferenceEntriesProvider);
    final entry = entries.where((e) => e.id == entryId).firstOrNull;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Quick reference not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        entry.icon,
                        size: 20,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ..._parseContent(entry.content, Theme.of(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseContent(String content, ThemeData theme) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('⬇')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Icon(
              Icons.arrow_downward,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        ));
      } else if (line == line.toUpperCase() && line.trim().length > 3) {
        // Section header (all caps)
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ));
      } else if (line.startsWith('  ') || line.startsWith('\t')) {
        // Indented line (sub-item)
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Text(
            line.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ));
      } else {
        widgets.add(Text(
          line,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ));
      }
    }

    return widgets;
  }
}
