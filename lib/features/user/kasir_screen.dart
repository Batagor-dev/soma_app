import 'package:flutter/material.dart';
import '../../core/services/kasir_service.dart';
import '../../core/services/kategori_service.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final KasirService _kasirService = KasirService();
  final KategoriService _kategoriService = KategoriService();

  Future<Map<String, dynamic>?>? _produkFuture;
  Future<Map<String, dynamic>?>? _kategoriFuture;

  String _search = "";
  int? _selectedKategoriId;

  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _produkFuture = _kasirService.getProduk(
      search: _search,
      kategoriId: _selectedKategoriId,
    );
    _kategoriFuture = _kategoriService.getKategori();
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  void _addToCart(Map<String, dynamic> produk) {
    final index = cart.indexWhere((item) => item['produk_id'] == produk['id']);
    int hargaInt = (produk['harga'] is String)
        ? int.parse((produk['harga'] as String).split('.').first)
        : produk['harga'] as int;

    if (index != -1) {
      cart[index]['jumlah'] += 1;
    } else {
      cart.add({
        "produk_id": produk['id'],
        "nama": produk['nama_produk'],
        "harga": hargaInt, // pastikan ini int
        "jumlah": 1,
      });
    }

    setState(() {});
  }

  void _updateQty(int index, int delta) {
    cart[index]['jumlah'] += delta;
    if (cart[index]['jumlah'] <= 0) {
      cart.removeAt(index);
    }
    setState(() {});
  }

  int get total {
    int sum = 0;
    for (var item in cart) {
      sum += item['harga'] * item['jumlah'] as int;
    }
    return sum;
  }

  Future<void> _checkout() async {
    final items = cart
        .map((e) => {
              "produk_id": e['produk_id'],
              "jumlah": e['jumlah'],
            })
        .toList();

    final result = await _kasirService.createTransaksi(items: items);

    if (result?['success'] == true) {
      cart.clear();
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaksi berhasil")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _search = value;
                  _refresh();
                },
              ),
            ),

            // KATEGORI BUTTON
            SizedBox(
              height: 45,
              child: FutureBuilder(
                future: _kategoriFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!['data'] as List;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final kategori = data[index];
                      final isActive = _selectedKategoriId == kategori['id'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(kategori['nama']),
                          selected: isActive,
                          onSelected: (_) {
                            setState(() {
                              _selectedKategoriId = kategori['id'];
                              _refresh();
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // PRODUK LIST
            Expanded(
              child: FutureBuilder(
                future: _produkFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final produkList = snapshot.data!['data'] as List;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              produk['nama_produk'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rp ${produk['harga']}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _addToCart(produk),
                                child: const Text("Tambah"),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // CART PANEL / PREVIEW
            if (cart.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ...cart.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item['nama'])),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _updateQty(index, -1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(item['jumlah'].toString()),
                              IconButton(
                                onPressed: () => _updateQty(index, 1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: Rp $total",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: _checkout,
                          child: const Text("Bayar"),
                        )
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
