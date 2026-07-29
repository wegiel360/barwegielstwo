import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'config/constants.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ProApp());
}

class ProApp extends StatelessWidget {
  const ProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Węgielstwo Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF886649),
          secondary: const Color(0xFFC49A6C),
          surface: const Color(0xFF2A1A16),
          onSurface: Colors.white,
        ),
      ),
      home: const ProHomeScreen(),
    );
  }
}

class ProHomeScreen extends StatefulWidget {
  const ProHomeScreen({super.key});

  @override
  State<ProHomeScreen> createState() => _ProHomeScreenState();
}

class _ProHomeScreenState extends State<ProHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  String _customMessage = 'Witaj w Barze Węgielstwo!';
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _msgSub = _api.customMessageStream().listen((msg) {
      if (mounted) setState(() => _customMessage = msg);
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _launchApp(_tabController.index);
    }
  }

  Future<void> _launchApp(int index) async {
    final apps = ['order', 'board', 'admin'];
    final app = apps[index];
    final dir = Directory.current.path;
    final names = ['bar_wegielstwo_order.exe', 'bar_wegielstwo_board.exe', 'bar_wegielstwo_admin.exe'];
    final paths = [
      '$dir\\${names[index]}',
      '$dir\\$app\\${names[index]}',
    ];
    for (final exe in paths) {
      if (await File(exe).exists()) {
        try {
          await Process.start(exe, []);
          return;
        } catch (_) {}
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie znaleziono aplikacji'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1A16),
        title: Text(
          _customMessage,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF886649),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Zamów'),
            Tab(text: 'Tablica'),
            Tab(text: 'Zarządzaj'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppTab(Icons.restaurant_menu, 'Zamów', 'Kiosk klienta', const Color(0xFF886649)),
          _buildAppTab(Icons.display_settings, 'Tablica', 'Wyświetlacz zamówień', const Color(0xFFC49A6C)),
          _buildAppTab(Icons.settings, 'Zarządzaj', 'Panel administratora', const Color(0xFFE8D5B8)),
        ],
      ),
    );
  }

  Widget _buildAppTab(IconData icon, String title, String subtitle, Color color) {
    return GestureDetector(
      onTap: () => _launchApp(_tabController.index),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withAlpha(76), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(51),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const Text(
              'Wersja 2.0.0',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}