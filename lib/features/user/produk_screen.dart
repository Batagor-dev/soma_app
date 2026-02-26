import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/services/produk_service.dart';
import '../../core/services/kategori_service.dart';
import '../../widgets/kategori_filter.dart';
import '../../widgets/produk_card_list.dart';
import '../../core/routes/routes.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final ProdukService _produkService = ProdukService();
  final KategoriService _kategoriService = KategoriService();

  late Future<Map<String, dynamic>?> _produkFuture;
  late Future<Map<String, dynamic>?> _kategoriFuture;

  int? _selectedKategoriId;
  String? _selectedKategoriName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _produkFuture = _produkService.getProduk(kategoriId: _selectedKategoriId);
    _kategoriFuture = _kategoriService.getKategori();
  }

  void _refreshProduk() {
    setState(() {
      _produkFuture = _produkService.getProduk(kategoriId: _selectedKategoriId);
    });
  }

  void _handleDelete(int id) async {
    final success = await _produkService.deleteProduk(id);
    if (success) {
      _refreshProduk();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produk berhasil dihapus'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _handleAdd() {
    Navigator.pushNamed(context, Routes.tambahProduk).then((_) {
      _refreshProduk();
    });
  }

  void _handleEdit(Map<String, dynamic> produk) {
    Navigator.pushNamed(
      context,
      Routes.editProduk,
      arguments: produk,
    ).then((_) {
      _refreshProduk();
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedKategoriId = null;
      _selectedKategoriName = null;
      _refreshProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Filter dengan desain modern
               KategoriFilter(
                  kategoriFuture: _kategoriFuture,
                  selectedKategoriId: _selectedKategoriId,
                  selectedKategoriName: _selectedKategoriName,
                  onChanged: (id, name) {
                    setState(() {
                      _selectedKategoriId = id;
                      _selectedKategoriName = name;
                      _refreshProduk();
                    });
                  },
                  onReset: _resetFilter,
                ),


                const SizedBox(height: 12),

                // Produk List
                Expanded(
                  child: ProdukCardList(
                    produkFuture: _produkFuture,
                    onDelete: _handleDelete,
                    onAdd: _handleAdd,
                    onEdit: (produk) {
                      Navigator.pushNamed(context, Routes.editProduk);
                    },
                  ),
                ),

              
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerDropdown() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Remix.error_warning_line, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Gagal memuat kategori",
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
