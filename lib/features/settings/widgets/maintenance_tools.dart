import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firestore_service.dart';
import '../../../widgets/reflecto_button.dart';

/// Wartungs-Tools: Planung deduplizieren
class MaintenanceTools extends ConsumerStatefulWidget {
  const MaintenanceTools({super.key});

  @override
  ConsumerState<MaintenanceTools> createState() => _MaintenanceToolsState();
}

class _MaintenanceToolsState extends ConsumerState<MaintenanceTools> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Align(
      alignment: Alignment.centerLeft,
      child: ReflectoButton(
        text: _running ? 'Bereinige...' : 'Planung deduplizieren',
        icon: Icons.cleaning_services_outlined,
        onPressed: (uid == null || _running)
            ? null
            : () async {
                setState(() => _running = true);
                try {
                  final n = await FirestoreService().dedupeAllPlanningForUser(
                    uid,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bereinigung abgeschlossen: $n Dokument(e) aktualisiert',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
                } finally {
                  if (mounted) setState(() => _running = false);
                }
              },
      ),
    );
  }
}
