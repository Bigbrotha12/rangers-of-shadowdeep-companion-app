import 'package:flutter/material.dart';

Future<String?> showRenameDialog(BuildContext context, {
  required String title,
  required String currentName,
  required Future<void> Function(String newName) onSave,
}) async {
  final controller = TextEditingController(text: currentName);
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final newName = controller.text.trim();
            if (newName.isEmpty) return;
            await onSave(newName);
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  return saved == true ? controller.text.trim() : null;
}

Future<bool> showConfirmDeleteDialog(BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function() onConfirm,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await onConfirm();
            if (context.mounted) Navigator.pop(context, true);
          },
          child: Text(confirmLabel, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    ),
  ).then((r) => r ?? false);
}
