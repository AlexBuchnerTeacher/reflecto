import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              ? 'Willkommen zurück, $firstName 👋'
              : 'Willkommen zurück 👋',
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _index,
        children: const [DayScreen(), WeekScreen(), SettingsScreen()],
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
