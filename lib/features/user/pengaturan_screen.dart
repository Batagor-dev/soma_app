import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/routes/routes.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/menu_item_widget.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F7FA)],
          ),
        ),
        child: _isLoading ? _buildShimmer() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            "Menu Pengaturan",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          MenuItemWidget(
            title: "Edit Profil",
            subtitle: "Ubah data akun kamu",
            icon: Remix.user_settings_line,
            gradientColors: const [Color(0xFF06D6A0), Color(0xFF1B9AAA)],
            onTap: () => Navigator.pushNamed(context, Routes.editProfile),
          ),
          const SizedBox(height: 16),
          MenuItemWidget(
            title: "Ganti Password",
            subtitle: "Perbarui password akun",
            icon: Remix.lock_password_line,
            gradientColors: const [Color(0xFFFF9F1C), Color(0xFFFFBF69)],
            onTap: () => Navigator.pushNamed(context, Routes.gantiPassword),
          ),
          const SizedBox(height: 16),
          MenuItemWidget(
            title: "Logout",
            subtitle: "Keluar dari akun",
            icon: Remix.logout_box_r_line,
            gradientColors: const [Color(0xFFE63946), Color(0xFFFF6B6B)],
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
