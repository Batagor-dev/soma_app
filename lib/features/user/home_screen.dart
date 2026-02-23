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

  @override
  Widget build(BuildContext context) {
    final summary = homeData?['summary'] ?? {};
    final pemasukan = summary['pemasukan'] ?? {};
    final pengeluaran = summary['pengeluaran'] ?? {};
    // final produkTerlaris = homeData?['produk_terlaris'] ?? [];
    final stokTerbaru = homeData?['stok_terbaru'] ?? [];
    final transaksiList = homeData?['transaksi_terbaru'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// ===== SUMMARY =====
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: "Pemasukan",
                      date: homeData?['greeting'] ?? "",
                      todayAmount:
                          isLoading ? "" : formatRupiah(pemasukan['harian']),
                      totalAmount:
                          isLoading ? "" : formatRupiah(pemasukan['total']),
                      primaryColor: Colors.green,
                      icon: Remix.download_line,
                      isLoading: isLoading,
                    ),
                  ),
                  // const SizedBox(width: 3),
                  Expanded(
                    child: SummaryCard(
                      title: "Pengeluaran",
                      date: homeData?['greeting'] ?? "",
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
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  "Produk Terlaris",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 250, // minimal tinggi supaya card muat
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    HomeProdukTerlaris(
                      nama: "Espresso Arabica",
                      harga: "Rp 25.000",
                      imageUrl: "assets/images/produk/contoh.jpeg",
                      isLoading: isLoading,
                    ),
                    HomeProdukTerlaris(
                      nama: "Cappuccino Latte",
                      harga: "Rp 30.000",
                      imageUrl: "assets/images/produk/contoh.jpeg",
                      isLoading: isLoading,
                    ),
                    HomeProdukTerlaris(
                      nama: "Croissant Butter",
                      harga: "Rp 18.000",
                      imageUrl: "assets/images/produk/contoh.jpeg",
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// ===== STOCK SECTION =====
              HomeStockSection(
                stokList: stokTerbaru,
                isLoading: isLoading,
              ),

              const SizedBox(height: 20),

              // Last Transaction
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
