import 'package:flutter/material.dart';
import '../../widgets/bottom_bar.dart';
import 'home_screen.dart';
import 'produk_screen.dart';
import 'kasir_screen.dart';
import 'transaksi_screen.dart';
import 'pengaturan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ProdukScreen(),
    KasirScreen(),
    TransaksiScreen(),
    PengaturanScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
