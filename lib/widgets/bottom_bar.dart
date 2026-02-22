// widgets/custom_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';// sesuaikan path Skeleton kamu

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isLoading;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          _buildBottomBar(),
          Positioned(
            top: -25,
            child: _buildKasirButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Remix.home_4_line,
              activeIcon: Remix.home_4_fill,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: Remix.shopping_bag_line,
              activeIcon: Remix.shopping_bag_fill,
              label: 'Produk',
            ),
            const SizedBox(width: 60),
            _buildNavItem(
              index: 3,
              icon: Remix.receipt_line,
              activeIcon: Remix.receipt_fill,
              label: 'Transaksi',
            ),
            _buildNavItem(
              index: 4,
              icon: Remix.settings_3_line,
              activeIcon: Remix.settings_3_fill,
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppSizes.r20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primaryLight : AppColors.surface,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: AppSizes.f10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primaryLight : AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKasirButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 85,
        height: 85,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Remix.shopping_cart_2_line,
              color: Colors.white,
              size: 34,
            ),
            const SizedBox(height: 2),
            Text(
              'Kasir',
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

