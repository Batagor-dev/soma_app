import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class HomeStockSection extends StatelessWidget {
  final List<dynamic> stokList;
  final bool isLoading;

  const HomeStockSection({
    super.key,
    required this.stokList,
    required this.isLoading,
  });

  String formatDate(String? date) {
    if (date == null) return "-";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "-";
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  String _getStockStatus(int stock) {
    if (stock <= 0) return "Habis";
    if (stock <= 5) return "Kritis";
    if (stock <= 10) return "Menipis";
    return "Tersedia";
  }

  Color _getStockColor(int stock) {
    if (stock <= 0) return Colors.red.shade700;
    if (stock <= 5) return Colors.orange.shade700;
    if (stock <= 10) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  Color _getStockBgColor(int stock) {
    if (stock <= 0) return Colors.red.shade50;
    if (stock <= 5) return Colors.orange.shade50;
    if (stock <= 10) return Colors.amber.shade50;
    return Colors.green.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Biru untuk stok
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Remix.archive_line, // Icon berbeda untuk stok
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      "Stok Barang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!isLoading && stokList.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${stokList.length}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isLoading && stokList.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman semua stok
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  
                ),
            )
          ],
        ),
      ),
      const SizedBox(height: 16),
        // Tambahkan Container dengan width: double.infinity di sini
        Container(
          width: double.infinity, // Membuat card full width
          child: Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: isLoading
                  ? _buildLoading()
                  : stokList.isEmpty
                      ? _buildEmptyState()
                      : _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Remix.inbox_line,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Data Stok Tidak Ditemukan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Belum ada data stok barang yang tersedia",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: List.generate(
        stokList.length,
        (index) {
          final item = stokList[index];
          final stok = item['stok'] ?? 0;
          final imagePath =
              item['image'] != null && item['image'].toString().isNotEmpty
                  ? item['image']
                  : "assets/images/no-image.jpg";
          final stockStatus = _getStockStatus(stok);
          final stockColor = _getStockColor(stok);
          final stockBgColor = _getStockBgColor(stok);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: index == 0 ? Colors.grey.shade50 : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FOTO BULAT DENGAN BORDER
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stockColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(imagePath),
                      backgroundColor: Colors.grey.shade100,
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// BAGIAN KANAN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// NAMA + UPDATE (POJOK KANAN)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// NAMA DAN STATUS STOK
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama'] ?? 'Produk',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  /// STATUS STOK
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stockBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      stockStatus,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: stockColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// TANGGAL UPDATE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Remix.time_line,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDate(item['updated_at']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// STOK PROGRESS BAR
                        Row(
                          children: [
                            /// ICON STOK
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: stockBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stok <= 5
                                    ? Remix.alarm_warning_line
                                    : Remix.archive_line,
                                size: 14,
                                color: stockColor,
                              ),
                            ),
                            const SizedBox(width: 8),

                            /// TEXT STOK
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stok tersisa",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    "$stok unit",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: stockColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// PROGRESS BAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: stok > 50 ? 1.0 : stok / 50,
                            backgroundColor: stockBgColor,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(stockColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FOTO SKELETON
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),

                /// BAGIAN KANAN SKELETON
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// NAMA + TANGGAL
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// STATUS STOK
                      Container(
                        width: 60,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// PROGRESS BAR
                      Container(
                        width: double.infinity,
                        height: 6,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
