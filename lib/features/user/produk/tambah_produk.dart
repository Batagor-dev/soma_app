import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/services/produk_service.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_auth.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  final ProdukService _service = ProdukService();

  int? _kategoriId;
  Uint8List? _imageBytes;
  XFile? _pickedFile;

  bool _isLoading = false;
  bool _isInitialLoading = true;
  String _lastHargaValue = '';

  @override
  void initState() {
    super.initState();
    _hargaController.addListener(_formatHarga);
    _simulateInitialLoading();
  }

  Future<void> _simulateInitialLoading() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  void _formatHarga() {
    final text = _hargaController.text;
    if (text.isEmpty) {
      _lastHargaValue = '';
      return;
    }

    final numeric = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      _hargaController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      _lastHargaValue = '';
      return;
    }

    if (text == _lastHargaValue) return;

    final number = int.parse(numeric);
    final formatted = formatRupiah(number);

    _hargaController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _lastHargaValue = formatted;
  }

  String formatRupiah(int number) {
    return "Rp ${number.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}";
  }

  int parseRupiah(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori dulu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _service.createProduk(
      kategoriId: _kategoriId!,
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      harga: parseRupiah(_hargaController.text),
      stok: int.tryParse(_stokController.text) ?? 0,
      fotoPath: kIsWeb ? null : _pickedFile?.path,
    );

    setState(() => _isLoading = false);

    if (result != null && result["success"] == true) {
      Navigator.pop(context, true);
    } else {
      final errorMessage =
          result?["message"] ?? "Terjadi kesalahan saat menyimpan produk";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget skeleton untuk image picker dengan aspek 1:1
  Widget _buildSkeletonImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                "Memuat...",
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget skeleton untuk setiap item form
  Widget _buildSkeletonItem(
      {double height = 56, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Widget skeleton untuk dropdown
  Widget _buildSkeletonDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.category_outlined, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Kategori Produk",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 14,
                  width: 100,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // Widget skeleton untuk button
  Widget _buildSkeletonButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Skeleton utama
  Widget _buildEnhancedSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          // Skeleton Image Picker dengan aspek 1:1
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width -
                  40, // Full width dengan padding
              child: _buildSkeletonImage(),
            ),
          ),
          const SizedBox(height: 20),

          // Skeleton Nama Produk
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Deskripsi
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Harga
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Stok
          _buildSkeletonItem(),
          const SizedBox(height: 18),

          // Skeleton Dropdown Kategori
          _buildSkeletonDropdown(),
          const SizedBox(height: 32),

          // Skeleton Button
          _buildSkeletonButton(),
        ],
      ),
    );
  }

  // Image Picker dengan aspek 1:1
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: _imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap untuk pilih gambar",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rasio 1:1 (persegi)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Image Picker dengan aspek 1:1
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width -
                    40, // Full width dengan padding
                child: _buildImagePicker(),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Produk
            InputText(
              controller: _namaController,
              hint: "Nama Produk",
              icon: Icons.shopping_bag_outlined,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Deskripsi Produk
            InputText(
              controller: _deskripsiController,
              hint: "Deskripsi Produk",
              icon: Icons.description_outlined,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Harga Produk
            InputText(
              controller: _hargaController,
              hint: "Harga Produk",
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Stok Produk
            InputText(
              controller: _stokController,
              hint: "Stok Produk",
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
              errorText: null,
            ),
            const SizedBox(height: 18),

            // Kategori Dropdown
            DropdownButtonFormField<int>(
              value: _kategoriId,
              items: const [
                DropdownMenuItem(value: 1, child: Text("Makanan")),
                DropdownMenuItem(value: 2, child: Text("Minuman")),
              ],
              onChanged: (value) {
                setState(() => _kategoriId = value);
              },
              decoration: InputDecoration(
                labelText: "Kategori Produk",
                labelStyle: TextStyle(color: Colors.grey.shade700),
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button Simpan
            ButtonAuth(
              text: "Simpan Produk",
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hargaController.removeListener(_formatHarga);
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
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
          "Tambah Produk",
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
        child: _isLoading || _isInitialLoading
            ? _buildEnhancedSkeleton()
            : _buildForm(),
      ),
    );
  }
}
