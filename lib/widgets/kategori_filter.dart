import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

class KategoriFilter extends StatelessWidget {
  final Future<Map<String, dynamic>?> kategoriFuture;
  final int? selectedKategoriId;
  final String? selectedKategoriName;
  final Function(int? id, String? name) onChanged;
  final VoidCallback onReset;

  const KategoriFilter({
    super.key,
    required this.kategoriFuture,
    required this.selectedKategoriId,
    required this.selectedKategoriName,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: kategoriFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (snapshot.hasError || snapshot.data?["data"] == null) {
          return _buildError();
        }

        final kategoriList = snapshot.data!["data"] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown kategori
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedKategoriId,
                hint: Row(
                  children: [
                    Icon(Remix.price_tag_3_line,
                        size: 18, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      "Pilih kategori",
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Remix.arrow_down_s_line,
                      color: Color(0xFF6C63FF), size: 18),
                ),
                iconSize: 24,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                isExpanded: true,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(Remix.grid_line,
                              size: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 10),
                        const Text("Semua Kategori",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  ...kategoriList.map<DropdownMenuItem<int>>((kategori) {
                    return DropdownMenuItem<int>(
                      value: kategori["id"],
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selectedKategoriId == kategori["id"]
                                  ? const Color(0xFF6C63FF).withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Remix.price_tag_3_line,
                                size: 14,
                                color: selectedKategoriId == kategori["id"]
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey.shade600),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              kategori["nama"],
                              style: TextStyle(
                                fontWeight: selectedKategoriId == kategori["id"]
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selectedKategoriId == kategori["id"]
                                    ? const Color(0xFF6C63FF)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  final name = value != null
                      ? kategoriList.firstWhere((k) => k["id"] == value,
                          orElse: () => {"nama": ""})["nama"]
                      : null;
                  onChanged(value, name);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Info filter aktif
            if (selectedKategoriId != null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Remix.filter_3_fill,
                            size: 12, color: Color(0xFF6C63FF)),
                      ),
                      const SizedBox(width: 8),
                      const Text("Filter aktif: ",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(selectedKategoriName ?? "",
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onReset,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6)),
                          child: Icon(Remix.close_line,
                              size: 14, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Shimmer untuk dropdown
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Ikon skeleton
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Teks skeleton
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  // Icon dropdown skeleton
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Shimmer untuk info filter (jika ada filter aktif)
        if (selectedKategoriId != null)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerOld() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildError() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Remix.error_warning_line,
                color: Colors.red.shade400, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Gagal memuat kategori",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Tombol retry sederhana
            GestureDetector(
              onTap: () {
                // Trigger refresh
                onChanged(null, null);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Remix.refresh_line,
                  size: 16,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
