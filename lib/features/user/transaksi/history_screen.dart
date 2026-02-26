import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/transaksi_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransaksiService _service = TransaksiService();
  bool _isLoading = true;
  List _allTransactions = [];
  Map<String, List> _groupedTransactions = {};
  List<String> _sortedMonthKeys = [];

  /// Format tanggal: "dd MMM yyyy"
  String formatDate(String? date) {
    if (date == null) return "-";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "-";
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  /// Format bulan: "MMMM yyyy"
  String formatMonth(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('MMMM yyyy', 'id_ID').format(parsed);
    } catch (e) {
      return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi loading untuk shimmer
    await Future.delayed(const Duration(seconds: 2));

    try {
      final result = await _service.getAll();
      if (result != null && result["data"] != null) {
        _allTransactions = result["data"];
        _groupTransactions();
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _groupTransactions() {
    _groupedTransactions = {};

    for (var item in _allTransactions) {
      if (item["tanggal"] != null) {
        String monthKey = formatMonth(item["tanggal"]);
        _groupedTransactions.putIfAbsent(monthKey, () => []);
        _groupedTransactions[monthKey]!.add(item);
      }
    }

    // Sort keys descending (bulan terbaru di atas)
    _sortedMonthKeys = _groupedTransactions.keys.toList()
      ..sort((a, b) {
        try {
          DateTime dateA = DateFormat('MMMM yyyy', 'id_ID').parse(a);
          DateTime dateB = DateFormat('MMMM yyyy', 'id_ID').parse(b);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            icon: const Icon(Remix.arrow_left_line, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: const Text(
          "History Transaksi",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            ),
          ),
        ),
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: _isLoading
          ? _buildFullShimmerLoading()
          : _allTransactions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortedMonthKeys.length,
                    itemBuilder: (context, index) {
                      final monthKey = _sortedMonthKeys[index];
                      final transactions = _groupedTransactions[monthKey] ?? [];

                      return Column(
                        key: ValueKey(monthKey),
                        children: [
                          if (index > 0) const SizedBox(height: 16),
                          _buildMonthHeader(monthKey, transactions),
                          const SizedBox(height: 8),
                          ...transactions
                              .map((item) => _buildTransactionCard(item))
                              .toList(),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildMonthHeader(String monthKey, List transactions) {
    // Hitung total pemasukan dan pengeluaran per bulan
    double totalPemasukan = transactions
        .where((t) => t["tipe"]?.toString().toLowerCase() == "masuk")
        .fold(
            0, (sum, t) => sum + (double.tryParse(t["total"].toString()) ?? 0));

    double totalPengeluaran = transactions
        .where((t) => t["tipe"]?.toString().toLowerCase() == "keluar")
        .fold(
            0, (sum, t) => sum + (double.tryParse(t["total"].toString()) ?? 0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthKey,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${transactions.length} transaksi",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMonthSummary(
                  label: "Pemasukan",
                  amount: totalPemasukan,
                  color: Colors.green,
                  icon: Remix.arrow_up_line,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMonthSummary(
                  label: "Pengeluaran",
                  amount: totalPengeluaran,
                  color: Colors.red,
                  icon: Remix.arrow_down_line,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(amount),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item) {
    // Tipe transaksi
    final isMasuk = (item['tipe'] ?? '').toString().toLowerCase() == 'masuk';
    final icon =
        isMasuk ? Remix.arrow_right_up_line : Remix.arrow_right_down_line;
    final color = isMasuk ? Colors.green : Colors.red;
    final bgColor = (isMasuk ? Colors.green : Colors.red).withOpacity(0.1);
    final total = double.tryParse(item['total'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/transaksi-detail',
              arguments: item["id"],
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon dengan background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                // Content Expanded
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deskripsi
                      Text(
                        item['deskripsi'] ?? 'Transaksi',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Tanggal dan sumber
                      Row(
                        children: [
                          Icon(
                            Remix.calendar_line,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(item['tanggal']),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (item['sumber'] != null &&
                              item['sumber'].toString().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['sumber'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Total
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Rp ${NumberFormat("#,##0", "id_ID").format(total)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Menampilkan 3 bulan skeleton
      itemBuilder: (context, monthIndex) {
        return Column(
          children: [
            if (monthIndex > 0) const SizedBox(height: 16),
            // Shimmer untuk header bulan
            _buildShimmerMonthHeader(),
            const SizedBox(height: 8),
            // Shimmer untuk transaksi dalam bulan (3 transaksi per bulan)
            ...List.generate(3, (index) => _buildShimmerTransactionItem()),
          ],
        );
      },
    );
  }

  Widget _buildShimmerMonthHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 24,
                  width: 150,
                  color: Colors.white,
                ),
                Container(
                  height: 24,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTransactionItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon skeleton
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                // Content skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 12,
                            width: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 12,
                            width: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Total skeleton
                Container(
                  height: 28,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
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
                  Remix.history_line,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Data Transaksi Tidak Ditemukan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Belum ada transaksi yang tersedia",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Remix.error_warning_line,
              size: 48,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gagal mengambil data transaksi",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Silahkan coba lagi nanti",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Remix.refresh_line),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
