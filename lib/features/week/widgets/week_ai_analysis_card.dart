import 'package:flutter/material.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_button.dart';
import '../../../services/firestore_service.dart';
import '../../../services/export_import_service.dart';

/// KI-Auswertung/Notizen-Card: Textfeld für Import + Speichern-Button.
class WeekAiAnalysisCard extends StatefulWidget {
  final String uid;
  final String weekId;
  final Map<String, dynamic>? weeklyData;

  const WeekAiAnalysisCard({
    super.key,
    required this.uid,
    required this.weekId,
    required this.weeklyData,
  });

  @override
  State<WeekAiAnalysisCard> createState() => _WeekAiAnalysisCardState();
}

class _WeekAiAnalysisCardState extends State<WeekAiAnalysisCard> {
  final _aiCtrl = TextEditingController();
  final _svc = FirestoreService();
  final _exportSvc = ExportImportService();

  @override
  void dispose() {
    _aiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motto = widget.weeklyData?['motto'] as String?;
    final summary = widget.weeklyData?['summaryText'] as String?;
    final ai = widget.weeklyData?['aiAnalysis'];

    return ReflectoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KI-Auswertung / Notizen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (motto != null && motto.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Motto: $motto',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(summary),
          ],
          if (ai != null) ...[
            const SizedBox(height: 8),
            Text(
              'AI-Daten vorhanden',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _aiCtrl,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'KI-Auswertung hier einfügen (Text oder JSON)…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ReflectoButton(
                  text: 'Importieren & Speichern',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final input = _aiCtrl.text.trim();
                    if (input.isEmpty) return;

                    final parsed = _exportSvc.tryParseAiAnalysis(input);
                    final toSave = parsed != null && parsed.containsKey('text')
                        ? {'aiAnalysisText': parsed['text']}
                        : {'aiAnalysis': parsed};

                    await _svc.saveWeeklyReflection(
                      widget.uid,
                      widget.weekId,
                      toSave,
                    );

                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Auswertung gespeichert')),
                    );
                    _aiCtrl.clear();
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
