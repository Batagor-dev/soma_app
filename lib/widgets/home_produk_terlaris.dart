import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:remixicon/remixicon.dart';

class HomeProdukTerlaris extends StatelessWidget {
  final String nama;
  final String harga;
  final String imageUrl;
  final bool isLoading;

  const HomeProdukTerlaris({
    super.key,
    required this.nama,
    required this.harga,
    required this.imageUrl,
    this.isLoading = false,
  });

  Widget _skeletonBox({
    double height = 12,
    double width = double.infinity,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading ? _buildSkeleton() : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image skeleton dengan ukuran yang proporsional
          _skeletonBox(height: 120, width: double.infinity, radius: 12),
          const SizedBox(height: 8),

          /// Nama skeleton
          _skeletonBox(height: 12, width: 100),
          const SizedBox(height: 6),

          /// Harga skeleton
          _skeletonBox(height: 14, width: 80),
          const SizedBox(height: 6),

          /// Rating skeleton
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _skeletonBox(height: 10, width: 10, radius: 4),
              const SizedBox(width: 4),
              _skeletonBox(height: 10, width: 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image Container dengan aspect ratio 1:1
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// Image
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Remix.image_line,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gambar tidak\ntersedia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Colors.green.shade400,
                        ),
                      ),
                    );
                  },
                ),

                /// Badge "Terlaris" di pojok kiri atas gambar
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Remix.fire_fill,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Terlaris',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Content container dengan padding yang lebih kecil
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Nama produk dengan icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Remix.fire_line,
                      size: 10,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              /// Harga dengan desain lebih menarik
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Remix.coin_line,
                      size: 10,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      harga,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              /// Rating dan jumlah terjual (simulasi)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Remix.star_fill,
                    size: 12,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "4.8",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Remix.shopping_bag_line,
                    size: 10,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "1.2rb",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===== HEADER WIDGET UNTUK PRODUK TERLARIS =====
class ProdukTerlarisHeader extends StatelessWidget {
  final VoidCallback? onSeeAllPressed;
  final bool isLoading;

  const ProdukTerlarisHeader({
    super.key,
    this.onSeeAllPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Header dengan icon dan gradasi
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF6B00), Color(0xFFFFA726)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B00), Color(0xFFFFA726)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA726).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Remix.fire_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "Produk Terlaris",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Warna akan diganti oleh ShaderMask
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Tombol "Lihat Semua"
          if (!isLoading)
            GestureDetector(
              onTap: onSeeAllPressed,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFA726).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Lihat Semua",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B00),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Remix.arrow_right_s_line,
                      size: 14,
                      color: const Color(0xFFFF6B00),
                    ),
                  ],
                ),
              ),
            )
          else
            _skeletonBox(height: 30, width: 90, radius: 20),
        ],
      ),
    );
  }

  Widget _skeletonBox(
      {double height = 12, double width = double.infinity, double radius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
