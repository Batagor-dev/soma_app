import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:remixicon/remixicon.dart';

import '../../../core/services/produk_service.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_auth.dart';

class RestokProduk extends StatefulWidget {
  final int id;

  const RestokProduk({super.key, required this.id});

  @override
  State<RestokProduk> createState() => _RestokProdukState();
}

class _RestokProdukState extends State<RestokProduk> {
  final _formKey = GlobalKey<FormState>();
  final ProdukService _service = ProdukService();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  bool _isSubmitting = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateInitialLoading();
  }

  // Simulasi loading awal
  Future<void> _simulateInitialLoading() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Tambah delay biar keliatan
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulasi loading untuk testing (hapus ini di production)
    await Future.delayed(const Duration(seconds: 2));

    final result = await _service.restokProduk(
      id: widget.id,
      jumlah: int.tryParse(_jumlahController.text) ?? 0,
      keterangan: _keteranganController.text.trim().isEmpty
          ? null
          : _keteranganController.text.trim(),
      tanggal: _tanggalController.text.isEmpty ? null : _tanggalController.text,
    );

    setState(() => _isSubmitting = false);

    if (result != null && result["success"] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?["message"] ?? "Gagal restok"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      _tanggalController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ========================
  // SKELETON WIDGETS
  // ========================

  Widget _buildSkeletonItem(
      {double height = 56, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Ganti dengan warna solid untuk base shimmer
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Skeleton untuk field tanggal dengan ikon kalender
  Widget _buildSkeletonDateField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Ganti dengan warna solid
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              color: Colors.grey[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tanggal (Opsional)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.grey[400], // Warna lebih gelap untuk kontras
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Skeleton untuk button
  Widget _buildSkeletonButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Skeleton utama dengan efek shimmer
  Widget _buildEnhancedSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500), // Atur kecepatan shimmer
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          // Skeleton Jumlah Restok
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Keterangan
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Tanggal dengan desain khusus
          _buildSkeletonDateField(),
          const SizedBox(height: 32),

          // Skeleton Button
          _buildSkeletonButton(),
        ],
      ),
    );
  }

  // ========================
  // FORM WIDGET
  // ========================

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Jumlah Restok
            InputText(
              controller: _jumlahController,
              hint: "Jumlah Restok",
              icon: Icons.add_box_outlined,
              keyboardType: TextInputType.number,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Keterangan
            InputText(
              controller: _keteranganController,
              hint: "Keterangan (Opsional)",
              icon: Icons.notes_outlined,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Tanggal dengan Date Picker
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: InputText(
                  controller: _tanggalController,
                  hint: "Tanggal (Opsional)",
                  icon: Icons.calendar_today_outlined,
                  errorText: null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button Simpan
            ButtonAuth(
              text: "Simpan Restok",
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    _tanggalController.dispose();
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Restok Produk",
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _isSubmitting || _isInitialLoading
            ? _buildEnhancedSkeleton()
            : _buildForm(),
      ),
    );
  }
}
