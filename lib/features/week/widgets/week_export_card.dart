import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_button.dart';
import '../../../services/export_import_service.dart';

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
          Text('Export', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ReflectoButton(
                  text: 'JSON kopieren',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(
                      ClipboardData(text: jsonEncode(jsonData)),
                    );
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('JSON in Zwischenablage')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReflectoButton(
                  text: 'Markdown kopieren',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final md = exportSvc.buildMarkdownFromJson(jsonData);
                    await Clipboard.setData(ClipboardData(text: md));
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Markdown in Zwischenablage'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
