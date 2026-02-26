import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/produk_service.dart';

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
      harga: int.tryParse(_hargaController.text) ?? 0,
      stok: int.tryParse(_stokController.text) ?? 0,
      fotoPath: kIsWeb ? null : _pickedFile?.path,
    );

    setState(() => _isLoading = false);

    if (result != null && result["success"] == true) {
      // balik ke screen sebelumnya dan kirim flag refresh
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

  @override
  void dispose() {
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
        title: const Text("Tambah Produk"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                          child: Text("Tap untuk pilih gambar"),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stok"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Stok wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _kategoriId,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Makanan")),
                  DropdownMenuItem(value: 2, child: Text("Minuman")),
                ],
                onChanged: (value) {
                  setState(() => _kategoriId = value);
                },
                decoration: const InputDecoration(
                  labelText: "Kategori Produk",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Simpan Produk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
