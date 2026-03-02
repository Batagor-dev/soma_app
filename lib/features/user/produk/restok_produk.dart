import 'package:flutter/material.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            InputText(
              controller: _jumlahController,
              hint: "Jumlah Restok",
              icon: Icons.add_box_outlined,
              keyboardType: TextInputType.number,
              errorText: null,
            ),
            const SizedBox(height: 18),
            InputText(
              controller: _keteranganController,
              hint: "Keterangan (Opsional)",
              icon: Icons.notes_outlined,
              errorText: null,
            ),
            const SizedBox(height: 18),
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

  Widget _skeletonBox({double height = 56}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        _skeletonBox(),
        const SizedBox(height: 18),
        _skeletonBox(),
        const SizedBox(height: 18),
        _skeletonBox(),
        const SizedBox(height: 32),
        _skeletonBox(height: 50),
      ],
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        child: _isSubmitting ? _buildSkeleton() : _buildForm(),
      ),
    );
  }
}
