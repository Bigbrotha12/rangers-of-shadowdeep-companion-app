import 'package:flutter/material.dart';

void showLegalDialog(BuildContext context, String title, String body) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: SelectableText(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

String privacyPolicyContent = '''
Privacy Policy

Last updated: July 23, 2026

Overview

Rangers of Shadow Deep Companion app ("the App") is an offline companion app for the Rangers of Shadow Deep solo/co-op tabletop miniatures game. It is provided by Firechain Services LLC ("we," "our," or "us").

This policy explains how the App handles any information when you use it.

What information we collect

No automatic data collection
The App does not collect, store, or transmit any personal information automatically. We do not use any analytics services, crash reporting SDKs, trackers, or third-party telemetry.

Local-only data
All data you enter into the App (ranger characters, companions, game sessions, settings) is stored exclusively on your device in a local SQLite database. We have no access to this data. It is never transmitted to us or any third party. The App does not make any network requests.

Bug reports (opt-in only)
If you voluntarily use the built-in bug report feature in Settings, your device email client will open with a pre-filled message addressed to contact@fire-chain.com. The message may include:
- What you typed into the report form (description, reproduction steps, expected behavior)
- The App version number
- Your device OS and OS version

This report is sent directly from your email client. You can review and edit the message before sending. You choose whether or not to send it.

What we do not collect

We do not collect, store, or have access to:
- Names, email addresses, or real identities
- Account credentials or passwords
- Location data
- Camera, microphone, or sensor data
- Contacts or address book data
- Device identifiers or advertising IDs
- Browsing or usage history
- Financial or payment information
- Health or biometric data

Third parties

The App contains no third-party analytics, advertising, or data-collection SDKs. No personal information is shared with, sold to, or disclosed to any third party.

Data retention and deletion

Since all App data is stored only on your device:
- Retention: data persists as long as you keep the App installed.
- Deletion: uninstalling the App removes all data from your device. There is no server-side data to delete.

Bug reports you choose to send via email are retained in accordance with our email provider's standard practices. You may request their deletion by contacting us.

Children's privacy

The App does not target or collect personal information from children under the age of 13 (or under the applicable age in your jurisdiction).

Your rights

Depending on your jurisdiction (e.g., GDPR, CCPA), you may have the right to:
- Know what personal information is collected
- Request correction or deletion of your data
- Withdraw consent (though no data collection is occurring)

Because we hold none of your data ourselves, these rights are fulfilled simply by not using the bug report feature or by uninstalling the App.

Contact

If you have questions about this privacy policy, please contact us at: contact@fire-chain.com

Changes to this policy

We may update this policy to reflect changes in the App or legal requirements. The "Last updated" date at the top will be revised. Continued use of the App after changes constitutes acceptance of the new terms.
''';

String termsContent = '''
Terms and Conditions

Last updated: July 23, 2026

Acceptance

By using Rangers of Shadow Deep Companion app ("the App"), you agree to these terms. If you do not agree, do not use the App.

Description

The App is a free, offline companion tool for the Rangers of Shadow Deep tabletop miniatures game. It is not affiliated with, endorsed by, or sponsored by Modiphius Entertainment or any related entity.

License

The App is provided under an MIT license. You may use, copy, modify, and distribute the software subject to the terms of that license.

No warranty

The App is provided "as is" without warranty of any kind, express or implied. We do not guarantee that the App will be error-free, uninterrupted, or meet your specific needs.

Limitation of liability

To the maximum extent permitted by law, Firechain Services LLC shall not be liable for any damages arising out of or related to your use of the App, including but not limited to lost data or game progress.

Intellectual property

Rangers of Shadow Deep is a trademark and property of its respective owner. All game content, rules, and references displayed within the App are the intellectual property of the game's publisher and are used for informational reference purposes only.

User responsibility

You are responsible for maintaining backups of your local data. The App does not sync or store data in the cloud.

Changes

We may update these terms at any time. Continued use after changes constitutes acceptance of the new terms.

Contact: contact@fire-chain.com
''';

String licenseContent = '''
MIT License

Copyright (c) 2026 Bigbrotha12

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''';