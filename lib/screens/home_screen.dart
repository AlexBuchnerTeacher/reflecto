import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_screen.dart';
import 'week_screen.dart';
import 'settings_screen.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? (user!.displayName!.split(' ').first)
        : (user?.email?.split('@').first ?? '');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          firstName.isNotEmpty
              ? 'Willkommen zur\u00FCck, $firstName \u{1F44B}'
              : 'Willkommen zur\u00FCck \u{1F44B}',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return const SizedBox.shrink();
              final stream = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('stats')
                  .doc('streak')
                  .snapshots();
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snap) {
                  final doc = snap.data;
                  final cnt = (doc?.data()?['streakCount'] as num?)?.toInt() ?? 0;
                  if (cnt <= 0) return const SizedBox(height: 8);
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('\u{1F525}', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('Streak: $cnt Tage in Folge', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [DayScreen(), WeekScreen(), SettingsScreen()],
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

