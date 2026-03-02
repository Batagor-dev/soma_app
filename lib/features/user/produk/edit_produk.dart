import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import '../../../core/services/produk_service.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/button_auth.dart';

class EditProduk extends StatefulWidget {
  final int id;

  const EditProduk({super.key, required this.id});

  @override
  State<EditProduk> createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  final ProdukService _service = ProdukService();

  int? _kategoriId;
  Uint8List? _imageBytes;
  XFile? _pickedFile;

  bool _isLoading = true;
  bool _isSubmitting = false;

  String _lastHargaValue = '';

  @override
  void initState() {
    super.initState();
    _hargaController.addListener(_formatHarga);
    _loadDetail();
  }

  // ========================
  // FORMAT RUPIAH
  // ========================

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

  // ========================
  // LOAD DETAIL
  // ========================

  Future<void> _loadDetail() async {
    final result = await _service.getDetail(widget.id);

    if (result != null && result["data"] != null) {
      final data = result["data"];

      _namaController.text = data["nama"] ?? "";
      _deskripsiController.text = data["deskripsi"] ?? "";

      final harga =
          double.tryParse(data["harga"]?.toString() ?? "0")?.toInt() ?? 0;

      _hargaController.text = formatRupiah(harga);

      _stokController.text = data["stok"].toString();
      _kategoriId = data["kategori_produk_id"];
    }

    setState(() => _isLoading = false);
  }

  // ========================
  // PICK IMAGE
  // ========================

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

  // ========================
  // SUBMIT
  // ========================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori dulu")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _service.updateProduk(
      id: widget.id,
      kategoriId: _kategoriId!,
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      harga: parseRupiah(_hargaController.text),
      stok: int.tryParse(_stokController.text) ?? 0,
      fotoPath: kIsWeb ? null : _pickedFile?.path,
    );

    setState(() => _isSubmitting = false);

    if (result != null && result["success"] == true) {
      Navigator.pop(context, true);
    } else {
      final errorMessage =
          result?["message"] ?? "Terjadi kesalahan saat update produk";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // ========================
  // UI
  // ========================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          "Edit Produk",
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text("Tap untuk ganti gambar"),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              InputText(
                controller: _namaController,
                hint: "Nama Produk",
                icon: Icons.shopping_bag_outlined,
                errorText: null,
              ),
              const SizedBox(height: 18),
              InputText(
                controller: _deskripsiController,
                hint: "Deskripsi Produk",
                icon: Icons.description_outlined,
                errorText: null,
              ),
              const SizedBox(height: 18),
              InputText(
                controller: _hargaController,
                hint: "Harga Produk",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                errorText: null,
              ),
              const SizedBox(height: 18),
              InputText(
                controller: _stokController,
                hint: "Stok Produk",
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                errorText: null,
              ),
              const SizedBox(height: 18),
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
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ButtonAuth(
                text: "Update Produk",
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
