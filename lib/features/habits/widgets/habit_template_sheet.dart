import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/habit_template_providers.dart';
import '../../../services/habit_template_seed.dart';
import '../../../services/habit_template_service.dart';
import 'habit_dialog.dart';

/// Bottom Sheet für Template-Auswahl beim Erstellen neuer Habits
class HabitTemplateSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const HabitTemplateSheet({
    super.key,
    required this.parentContext,
  });

  @override
  ConsumerState<HabitTemplateSheet> createState() => _HabitTemplateSheetState();
}

class _HabitTemplateSheetState extends ConsumerState<HabitTemplateSheet> {
  bool _showFallback = false;
  bool _timerStarted = false;

  void _ensureTimeoutStarted() {
    if (_timerStarted) return;
    _timerStarted = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFallback = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return templatesAsync.when(
      loading: () {
        _ensureTimeoutStarted();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(child: CircularProgressIndicator()),
              if (_showFallback) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: widget.parentContext,
                      builder: (_) => const HabitDialog(),
                    );
                  },
                  child: const Text('Ohne Vorlage erstellen'),
                ),
              ],
            ],
          ),
        );
      },
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vorlagen'),
            const SizedBox(height: 8),
            Text('Fehler beim Laden: $e'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: widget.parentContext,
                  builder: (_) => const HabitDialog(),
                );
              },
              child: const Text('Ohne Vorlage erstellen'),
            ),
          ],
        ),
      ),
      data: (templates) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vorlagen',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: widget.parentContext,
                        builder: (_) => const HabitDialog(),
                      );
                    },
                    child: const Text('Ohne Vorlage'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (templates.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Keine Vorlagen verfügbar.'),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final uid = ref.watch(userIdProvider);
                    if (_isAdmin(uid)) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Vorlagen jetzt einspielen'),
                          onPressed: () async {
                            final svc = HabitTemplateService();
                            await svc.seedTemplates(
                              buildCuratedHabitTemplates(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vorlagen eingespielt'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ] else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final t = templates[i];
                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.category),
                        leading: CircleAvatar(
                          backgroundColor: _parseHexColor(t.color),
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onTap: () async {
                          final notifier = ref.read(
                            habitNotifierProvider.notifier,
                          );

                          // Auto-assign sortIndex: max existing sortIndex + 10
                          final habitsAsync = ref.read(habitsProvider);
                          final maxSortIndex = habitsAsync.when(
                            data: (habits) {
                              final service = ref.read(habitServiceProvider);
                              return service.getMaxSortIndex(habits);
                            },
                            loading: () => 0,
                            error: (_, __) => 0,
                          );

                          await notifier.createHabit(
                            title: t.title,
                            category: t.category,
                            color: t.color,
                            frequency: t.frequency,
                            reminderTime: t.reminderTime,
                            weekdays: t.weekdays,
                            weeklyTarget: t.weeklyTarget,
                            sortIndex: maxSortIndex + 10,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

Color _parseHexColor(String hexString) {
  try {
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF5B50FF);
  } catch (_) {
    return const Color(0xFF5B50FF);
  }
}

bool _isAdmin(String? uid) {
  if (uid == null) return false;
  const admins = {'your-admin-uid-here'};
  return admins.contains(uid) || kDebugMode;
}
