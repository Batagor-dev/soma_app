import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';

import '../../core/services/home_service.dart';
import '../../widgets/home_summary_card.dart';
import '../../widgets/home_stock_section.dart';
import '../../widgets/home_produk_terlaris.dart';
import '../../widgets/home_transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _service = HomeService();

  Map<String, dynamic>? homeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHome();
  }

  Future<void> fetchHome() async {
    try {
      final data = await _service.getHome();

      setState(() {
        homeData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching home data: $e');
      setState(() => isLoading = false);
    }
  }

  String formatRupiah(dynamic number) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final value = number is num
        ? number.toDouble()
        : double.tryParse(number?.toString() ?? '0') ?? 0;

    return format.format(value);
  }

  String _getImageUrl(dynamic item) {
    if (item is Map && item.containsKey('foto')) {
      final foto = item['foto'];
      if (foto != null && foto.toString().isNotEmpty) {
        if (foto.toString().startsWith('http')) {
          return foto.toString();
        }
        // gunakan baseUrl API
        return 'http://127.0.0.1:8000/storage/$foto';
      }
    }
    return "assets/images/no-image.jpg";
  }

  // Fungsi untuk parsing total_terjual dengan aman
  int _parseTotalTerjual(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  // Fungsi untuk parsing harga dengan aman (handle desimal)
  int _parseHarga(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Hapus titik desimal dan hanya ambil angka bulat
      final cleanValue = value.split('.').first;
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final summary = homeData?['summary'] ?? {};
    final pemasukan = summary['pemasukan'] ?? {};
    final pengeluaran = summary['pengeluaran'] ?? {};
    final produkTerlaris = homeData?['produk_terlaris'] as List? ?? [];
    final stokTerbaru = homeData?['stok_terbaru'] as List? ?? [];
    final transaksiList = homeData?['transaksi_terbaru'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== SUMMARY =====
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: "Pemasukan",
                      date: "Hari Ini",
                      todayAmount:
                          isLoading ? "" : formatRupiah(pemasukan['harian']),
                      totalAmount:
                          isLoading ? "" : formatRupiah(pemasukan['total']),
                      primaryColor: Colors.green,
                      icon: Remix.download_line,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: "Pengeluaran",
                      date: "Hari Ini",
                      todayAmount:
                          isLoading ? "" : formatRupiah(pengeluaran['harian']),
                      totalAmount:
                          isLoading ? "" : formatRupiah(pengeluaran['total']),
                      primaryColor: Colors.red,
                      icon: Remix.upload_line,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ===== PRODUK TERLARIS =====
              ProdukTerlarisHeader(
                onSeeAllPressed: () {
                  // Navigasi ke halaman semua produk terlaris
                },
                isLoading: isLoading,
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 260,
                child: isLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            const HomeProdukTerlaris(
                          nama: "",
                          harga: "",
                          imageUrl: "",
                          isLoading: true,
                        ),
                      )
                    : produkTerlaris.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada produk terlaris',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: produkTerlaris.length,
                            itemBuilder: (context, index) {
                              final item = produkTerlaris[index];

                              // Parse data dengan aman
                              final nama = item['nama']?.toString() ?? 'Produk';
                              final hargaValue = _parseHarga(item['harga']);
                              final totalTerjual =
                                  _parseTotalTerjual(item['total_terjual']);

                              // Ambil kategori jika ada
                              String? kategori;
                              if (item['kategori'] is Map) {
                                kategori = item['kategori']['nama']?.toString();
                              } else if (item['kategori_id'] != null) {
                                // Jika hanya punya kategori_id
                                kategori = 'Kategori ${item['kategori_id']}';
                              }

                              return HomeProdukTerlaris(
                                nama: nama,
                                harga: formatRupiah(hargaValue),
                                imageUrl: _getImageUrl(item),
                                kategori: kategori,
                                totalTerjual: totalTerjual,
                                rating:
                                    4.8, // Bisa diganti dengan data real jika ada
                                isLoading: false,
                              );
                            },
                          ),
              ),

              const SizedBox(height: 20),

              /// ===== STOCK SECTION =====
              HomeStockSection(
                stokList: stokTerbaru,
                isLoading: isLoading,
              ),

              const SizedBox(height: 20),

              /// ===== LAST TRANSACTION =====
              HomeTransaction(
                transaksiList: transaksiList,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
