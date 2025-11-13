import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/entry_providers.dart';
import '../providers/pending_providers.dart';
import './day_screen.dart';
import './week_screen.dart';
import './settings_screen.dart' as settings;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      user = null;
    }
    final firstName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? (user!.displayName!.split(' ').first)
        : (user?.email?.split('@').first ?? '');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          firstName.isNotEmpty
              ? 'Willkommen zurück, $firstName'
              : 'Willkommen zurück',
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final snap = ref.watch(todayDocProvider).valueOrNull;
              final pendingMeta = snap?.metadata.hasPendingWrites ?? false;
              final pendingLocal = ref.watch(appPendingProvider);
              final pending = pendingLocal || pendingMeta;
              final fromCache = snap?.metadata.isFromCache ?? false;
              final cs = Theme.of(context).colorScheme;
              late String text;
              late Color bg;
              late Color fg;
              late Color border;
              if (pending) {
                text = 'Synchronisiere...';
                bg = cs.primaryContainer;
                fg = cs.onPrimaryContainer;
                border = cs.primary;
              } else if (fromCache) {
                text = 'Offline';
                bg = cs.tertiaryContainer;
                fg = cs.onTertiaryContainer;
                border = cs.tertiary;
              } else {
                text = '\u2713 Gespeichert';
                bg = cs.secondaryContainer;
                fg = cs.onSecondaryContainer;
                border = cs.secondary;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: border.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [DayScreen(), WeekScreen(), settings.SettingsScreen()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            label: 'Heute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week_outlined),
            label: 'Woche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
