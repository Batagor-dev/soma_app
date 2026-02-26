import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/transaksi_service.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_auth.dart';

class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({super.key});

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _sumberController = TextEditingController();

  final TransaksiService _service = TransaksiService();

  bool _isLoading = false;
  bool _isInitialLoading = true; // Untuk efek skeleton awal

  String? _deskripsiError;
  String? _totalError;
  String? _sumberError;

  // Untuk formatting Rupiah
  String _lastTotalValue = '';

  @override
  void initState() {
    super.initState();
    // Simulasi loading awal
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });

    // Tambahkan listener untuk formatting Rupiah
    _totalController.addListener(_formatRupiah);
  }

  void _formatRupiah() {
    final text = _totalController.text;
    if (text.isEmpty) {
      _lastTotalValue = '';
      return;
    }

    // Hanya angka yang diproses
    final numericValue = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.isEmpty) {
      _totalController.value = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      _lastTotalValue = '';
      return;
    }

    // Cegah rekursi
    if (text == _lastTotalValue) return;

    try {
      // Parse ke integer (tanpa desimal untuk formatting)
      final number = int.parse(numericValue);

      // Format Rupiah (Rp 1.000.000)
      final currencyFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      final formatted = currencyFormatter.format(number);

      // Update controller dengan format baru
      _totalController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      _lastTotalValue = formatted;
    } catch (e) {
      // Abaikan error parsing
    }
  }

  // Fungsi untuk mendapatkan nilai numerik murni
  double? _getNumericValue() {
    final text = _totalController.text;
    if (text.isEmpty) return null;

    // Hapus semua karakter non-digit kecuali titik desimal
    final numericString = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return null;

    try {
      return double.parse(numericString);
    } catch (e) {
      return null;
    }
  }

  // Reset form setelah berhasil submit
  void _resetForm() {
    _deskripsiController.clear();
    _totalController.clear();
    _sumberController.clear();
    setState(() {
      _deskripsiError = null;
      _totalError = null;
      _sumberError = null;
    });
  }

  bool _validate() {
    bool isValid = true;

    setState(() {
      _deskripsiError = null;
      _totalError = null;
      _sumberError = null;

      if (_deskripsiController.text.trim().isEmpty) {
        _deskripsiError = "Deskripsi wajib diisi";
        isValid = false;
      }

      final numericValue = _getNumericValue();
      if (_totalController.text.trim().isEmpty) {
        _totalError = "Total wajib diisi";
        isValid = false;
      } else if (numericValue == null) {
        _totalError = "Total harus berupa angka";
        isValid = false;
      } else if (numericValue <= 0) {
        _totalError = "Total harus lebih dari 0";
        isValid = false;
      }

      if (_sumberController.text.trim().isEmpty) {
        _sumberError = "Sumber wajib diisi";
        isValid = false;
      }
    });

    return isValid;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Remix.checkbox_circle_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Remix.error_warning_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final numericValue = _getNumericValue();

    final result = await _service.createTransaksi(
      deskripsi: _deskripsiController.text.trim(),
      total: numericValue!, // Pastikan tidak null karena sudah divalidasi
      sumber: _sumberController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null && result["success"] == true) {
      // Tampilkan alert sukses
      _showSuccessSnackbar(
          result["message"] ?? "Pengeluaran berhasil disimpan");

      // Reset form setelah berhasil
      _resetForm();

      // Optional: Kirim notifikasi ke halaman sebelumnya bahwa ada data baru
      // Tapi tidak perlu pindah halaman
      // Navigator.pop(context, true); // HAPUS baris ini agar tidak pindah halaman
    } else {
      final errorMessage = result?["message"] ?? "Gagal menyimpan pengeluaran";
      _showErrorSnackbar(errorMessage);
    }
  }

  Widget _buildSkeletonItem(
      {double height = 50, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _totalController.removeListener(_formatRupiah);
    _deskripsiController.dispose();
    _totalController.dispose();
    _sumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Pengeluaran",
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            /// DESKRIPSI
            _isInitialLoading
                ? _buildSkeletonItem(height: 50)
                : InputText(
                    controller: _deskripsiController,
                    hint: "Deskripsi Pengeluaran",
                    icon: Icons.description_outlined,
                    errorText: _deskripsiError,
                  ),

            const SizedBox(height: 18),

            /// TOTAL dengan Format Rupiah
            _isInitialLoading
                ? _buildSkeletonItem(height: 50)
                : InputText(
                    controller: _totalController,
                    hint: "Total Pengeluaran (Rp)",
                    icon: Icons.attach_money,
                    errorText: _totalError,
                    keyboardType: TextInputType.number, // Keyboard numerik
                  ),

            const SizedBox(height: 18),

            /// SUMBER
            _isInitialLoading
                ? _buildSkeletonItem(height: 50)
                : InputText(
                    controller: _sumberController,
                    hint: "Sumber Dana (Kas / Bank / dll)",
                    icon: Icons.account_balance_wallet_outlined,
                    errorText: _sumberError,
                  ),

            const SizedBox(height: 32),

            /// BUTTON
            _isInitialLoading
                ? _buildSkeletonItem(height: 55)
                : ButtonAuth(
                    text: "Simpan Pengeluaran",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
          ],
        ),
      ),
    );
  }
}
