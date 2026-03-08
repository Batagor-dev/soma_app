import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

class KategoriChips extends StatefulWidget {
  final AsyncSnapshot<Map<String, dynamic>?> snapshot;
  final int? selectedKategoriId;
  final Function(int?) onKategoriSelected;

  const KategoriChips({
    super.key,
    required this.snapshot,
    required this.selectedKategoriId,
    required this.onKategoriSelected,
  });

  @override
  State<KategoriChips> createState() => _KategoriChipsState();
}

class _KategoriChipsState extends State<KategoriChips>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading state dengan skeleton shimmer yang lebih menarik
    if (widget.snapshot.connectionState == ConnectionState.waiting) {
      return _buildEnhancedShimmerLoading();
    }

    // Error state dengan desain yang lebih informatif
    if (!widget.snapshot.hasData || widget.snapshot.data?['data'] == null) {
      return _buildErrorState();
    }

    final data = widget.snapshot.data!['data'] as List;

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: data.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildEnhancedKategoriChip(
              label: 'Semua',
              icon: Remix.apps_line,
              isActive: widget.selectedKategoriId == null,
              onTap: () => widget.onKategoriSelected(null),
              index: index,
            );
          }

          final kategori = data[index - 1];
          final isActive = widget.selectedKategoriId == kategori['id'];

          // Dapatkan icon berdasarkan kategori atau random yang konsisten
          final icon = _getCategoryIcon(kategori['nama'] ?? '', index);

          return _buildEnhancedKategoriChip(
            label: kategori['nama'] ?? '',
            icon: icon,
            isActive: isActive,
            onTap: () => widget.onKategoriSelected(kategori['id']),
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildEnhancedKategoriChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AnimatedScale(
        scale: isActive ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.blue.withOpacity(0.1),
              highlightColor: Colors.blue.withOpacity(0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                        )
                      : null,
                  color: isActive ? null : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        isActive ? Colors.blue.shade300 : Colors.grey.shade200,
                    width: isActive ? 0 : 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon dengan animasi
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        icon,
                        size: 18,
                        color: isActive ? Colors.white : Colors.blue.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text dengan animasi
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                      child: Text(label),
                    ),
                    // Badge count (jika ada)
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Remix.check_line,
                          size: 10,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedShimmerLoading() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1500),
        direction: ShimmerDirection.ltr,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                width: index == 0 ? 100 : 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Remix.error_warning_line,
                size: 16,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                'Gagal memuat kategori',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => widget.onKategoriSelected(null),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Coba lagi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Remix.folder_forbid_line,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                'Belum ada kategori',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName, int index) {
    // Mapping icon berdasarkan nama kategori
    final categoryLower = categoryName.toLowerCase();

    if (categoryLower.contains('makanan') || categoryLower.contains('food')) {
      return Remix.restaurant_line;
    } else if (categoryLower.contains('minuman') ||
        categoryLower.contains('drink')) {
      return Remix.cup_line;
    } else if (categoryLower.contains('snack') ||
        categoryLower.contains('camilan')) {
      return Remix.cake_line;
    } else if (categoryLower.contains('elektronik')) {
      return Remix.device_line;
    } else if (categoryLower.contains('pakaian') ||
        categoryLower.contains('fashion')) {
      return Remix.shirt_line;
    } else if (categoryLower.contains('alat tulis')) {
      return Remix.pencil_line;
    } else if (categoryLower.contains('kesehatan')) {
      return Remix.heart_pulse_line;
    } else if (categoryLower.contains('rumah tangga')) {
      return Remix.home_line;
    } else {
      // Fallback ke icon berdasarkan index
      final icons = [
        Remix.folder_line,
        Remix.price_tag_line,
        Remix.star_line,
        Remix.heart_line,
        Remix.fire_line,
        Remix.flashlight_line,
      ];
      return icons[index % icons.length];
    }
  }
}

// Extension untuk menambahkan efek hover di web/desktop (opsional)
extension on Widget {
  Widget withHoverEffect({
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: this,
    );
  }
}
