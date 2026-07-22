import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rangers_mobile/version.dart' show appVersion;

Future<void> showBugReportDialog(BuildContext context) async {
  final descriptionController = TextEditingController();
  final stepsController = TextEditingController();
  final expectedController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Report a Bug',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'What went wrong? *',
              hintText: 'Describe the issue...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: stepsController,
            decoration: const InputDecoration(
              labelText: 'Steps to Reproduce',
              hintText: '1. Go to...\n2. Tap on...\n3. See error',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: expectedController,
            decoration: const InputDecoration(
              labelText: 'What should have happened?',
              hintText: 'Expected vs actual behaviour',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _sendReport(
              context,
              descriptionController.text.trim(),
              stepsController.text.trim(),
              expectedController.text.trim(),
            ),
            child: const Text('Submit'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> _sendReport(
  BuildContext context,
  String description,
  String steps,
  String expected,
) async {
  if (description.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please describe the issue.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final body = StringBuffer()
    ..writeln(description)
    ..writeln();
  if (steps.isNotEmpty) {
    body.writeln('Steps to reproduce:');
    body.writeln(steps);
    body.writeln();
  }
  if (expected.isNotEmpty) {
    body.writeln('Expected vs actual:');
    body.writeln(expected);
    body.writeln();
  }
  body.writeln('---');
  body.writeln('App version: $appVersion');
  body.writeln('Device: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');

  final uri = Uri(
    scheme: 'mailto',
    path: 'contact@fire-chain.com',
    queryParameters: {
      'subject': 'Rangers Companion Bug Report',
      'body': body.toString(),
    },
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
    if (context.mounted) Navigator.pop(context);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open email.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
