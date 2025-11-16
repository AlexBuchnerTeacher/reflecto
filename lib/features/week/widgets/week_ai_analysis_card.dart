import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_button.dart';
import '../../../services/firestore_service.dart';
import '../../../models/weekly_reflection.dart';
import '../../../services/export_import_service.dart';
import '../../../theme/tokens.dart';

/// KI-Auswertung/Notizen-Card: Textfeld für Import + Speichern-Button.
class WeekAiAnalysisCard extends StatefulWidget {
  final String uid;
  final String weekId;
  final WeeklyReflection? weeklyData;

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
    final ai = widget.weeklyData?.aiAnalysis;
    final aiText = widget.weeklyData?.aiAnalysisText;

    // Versuche Text aus aiAnalysis Map oder aiAnalysisText zu extrahieren
    String? analysisText;
    if (aiText != null && aiText.isNotEmpty) {
      analysisText = aiText;
    } else if (ai != null && ai['text'] != null) {
      analysisText = ai['text'].toString();
    }

    return ReflectoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KI-Auswertung', style: Theme.of(context).textTheme.titleMedium),

          // Gespeicherte Analyse anzeigen
          if (analysisText != null && analysisText.isNotEmpty) ...[
            const SizedBox(height: ReflectoSpacing.s16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(ReflectoSpacing.s16),
              child: MarkdownBody(
                data: analysisText,
                styleSheet: MarkdownStyleSheet(
                  h2: Theme.of(context).textTheme.titleLarge,
                  h3: Theme.of(context).textTheme.titleMedium,
                  p: Theme.of(context).textTheme.bodyMedium,
                  listBullet: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: ReflectoSpacing.s16),
            const Divider(),
          ],

          const SizedBox(height: ReflectoSpacing.s12),
          Text(
            analysisText != null
                ? 'Analyse aktualisieren:'
                : 'Neue Analyse einfügen:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: ReflectoSpacing.s8),
          TextField(
            controller: _aiCtrl,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'ChatGPT-Analyse hier einfügen…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: ReflectoSpacing.s8),
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
