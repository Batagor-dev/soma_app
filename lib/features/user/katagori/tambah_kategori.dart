import 'package:flutter/material.dart';

class TambahKategori extends StatelessWidget {
  const TambahKategori({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Kategori")),
      body: const Center(
        child: Text("Form tambah Kategori di sini"),
      ),
    );
  }
}
