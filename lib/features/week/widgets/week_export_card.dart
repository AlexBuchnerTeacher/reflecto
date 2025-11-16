import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_button.dart';
import '../../../services/export_import_service.dart';
import '../../../theme/tokens.dart';

/// Export-Card: Buttons für JSON- und Markdown-Export in Zwischenablage.
class WeekExportCard extends StatelessWidget {
  final Map<String, dynamic> jsonData;

  const WeekExportCard({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    final exportSvc = ExportImportService();

    return ReflectoCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KI-Analyse', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: ReflectoSpacing.s8),
          ReflectoButton(
            text: 'Für ChatGPT kopieren',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final md = exportSvc.buildMarkdownFromJson(jsonData);
              await Clipboard.setData(ClipboardData(text: md));
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Prompt in Zwischenablage kopiert'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
