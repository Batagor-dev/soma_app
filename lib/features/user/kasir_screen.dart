import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import '../../core/services/kasir_service.dart';
import '../../core/services/kategori_service.dart';
import '../../features/user/checkout_screen.dart';
import '../../widgets/produk_card.dart';
import '../../widgets/kategori_chips.dart';

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

  final TextEditingController _searchController = TextEditingController();
  String _search = "";
  int? _selectedKategoriId;
  bool _isLoading = false;

  List<Map<String, dynamic>> cart = [];

  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    _produkFuture = _kasirService
        .getProduk(
      search: _search,
      kategoriId: _selectedKategoriId,
    )
        .then((value) {
      if (!mounted) return value;
      setState(() {
        _isLoading = false;
      });
      return value;
    }).catchError((error) {
      if (!mounted) return null;
      setState(() {
        _isLoading = false;
      });
      print('Error loading produk: $error');
      return null;
    });

    _kategoriFuture = _kategoriService.getKategori();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _loadData();
    });
  }

  bool _isProductInCart(int productId) {
    return cart.any((item) => item['produk_id'] == productId);
  }

  int _getCartQuantity(int productId) {
    final index = cart.indexWhere((item) => item['produk_id'] == productId);
    if (index != -1) {
      return cart[index]['jumlah'];
    }
    return 0;
  }

  void _addToCart(Map<String, dynamic> produk) {
    final index = cart.indexWhere((item) => item['produk_id'] == produk['id']);

    // Parse harga dengan benar (handle string dengan format desimal)
    int hargaInt = 0;
    if (produk['harga'] is String) {
      hargaInt = double.parse(produk['harga']).toInt();
    } else if (produk['harga'] is int) {
      hargaInt = produk['harga'];
    } else if (produk['harga'] is double) {
      hargaInt = (produk['harga'] as double).toInt();
    }

    // Cek stok
    int stokTersedia = produk['stok'] ?? 0;
    int jumlahDiCart = index != -1 ? cart[index]['jumlah'] : 0;

    if (jumlahDiCart >= stokTersedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${produk['nama_produk']} tidak mencukupi'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (index != -1) {
        cart[index]['jumlah'] += 1;
      } else {
        cart.add({
          "produk_id": produk['id'],
          "nama": produk['nama_produk'],
          "harga": hargaInt,
          "jumlah": 1,
          "stok": produk['stok'],
          "gambar": produk['gambar'],
        });
      }
    });

    // Animasi feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produk['nama_produk']} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateQty(int index, int delta) {
    int currentQty = cart[index]['jumlah'];
    int stokTersedia = cart[index]['stok'] ?? 999;

    if (delta > 0 && currentQty >= stokTersedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${cart[index]['nama']} tidak mencukupi'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      cart[index]['jumlah'] += delta;

      if (cart[index]['jumlah'] <= 0) {
        cart.removeAt(index);
      }
    });
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Keranjang'),
        content: const Text('Yakin ingin menghapus semua item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                cart.clear();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  int get total {
    int sum = 0;
    for (var item in cart) {
      sum += (item['harga'] * item['jumlah']) as int;
    }
    return sum;
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigasi ke halaman checkout
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cart: cart,
          total: total,
          onCheckoutSuccess: () {
            setState(() {
              cart.clear();
            });
            _refresh();
          },
        ),
      ),
    );

    // Jika ada perubahan cart dari halaman checkout
    if (result != null && result is List) {
      setState(() {
        cart = List.from(result);
      });
    }
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Remix.cup_line,
              size: 20,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(item['harga']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _updateQty(index, -1),
                  icon: const Icon(Remix.subtract_line, size: 16),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item['jumlah']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _updateQty(index, 1),
                  icon: const Icon(Remix.add_line, size: 16),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Remix.search_line, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Remix.close_line, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _search = "";
                            _refresh();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                ),
                onChanged: (value) {
                  _search = value;
                  _refresh();
                },
              ),
            ),

            const SizedBox(height: 10),
            // KATEGORI BUTTON
            FutureBuilder(
              future: _kategoriFuture,
              builder: (context, snapshot) {
                return KategoriChips(
                  snapshot: snapshot,
                  selectedKategoriId: _selectedKategoriId,
                  onKategoriSelected: (kategoriId) {
                    setState(() {
                      _selectedKategoriId = kategoriId;
                      _refresh();
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            // PRODUK LIST
            Expanded(
              child: _isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return const ProdukCardSkeleton();
                      },
                    )
                  : FutureBuilder(
                      future: _produkFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return const ProdukCardSkeleton();
                            },
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.error_warning_line,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refresh,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data?['data'] == null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.inbox_line,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada produk',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final produkList = snapshot.data!['data'] as List;

                        if (produkList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.search_line,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Produk tidak ditemukan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _refresh(),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: produkList.length,
                            itemBuilder: (context, index) {
                              final produk =
                                  Map<String, dynamic>.from(produkList[index]);
                              final productId = produk['id'];

                              // Tambahkan field kategori_nama jika belum ada di data produk
                              if (produk['kategori_nama'] == null &&
                                  produk['kategori'] != null) {
                                // Jika kategori adalah object, ambil namanya
                                if (produk['kategori'] is Map) {
                                  produk['kategori_nama'] =
                                      produk['kategori']['nama'];
                                }
                                // Jika kategori adalah string, gunakan langsung
                                else if (produk['kategori'] is String) {
                                  produk['kategori_nama'] = produk['kategori'];
                                }
                              }

                              return ProdukCard(
                                produk: produk,
                                onTap: () => _addToCart(produk),
                                onAddToCart: () => _addToCart(produk),
                                isInCart: _isProductInCart(productId),
                                cartQuantity: _getCartQuantity(productId),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            // CART PANEL
            if (cart.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Remix.shopping_cart_line,
                                  size: 20, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Keranjang (${cart.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _clearCart,
                            icon: Icon(Remix.delete_bin_line,
                                size: 18, color: Colors.red.shade400),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ),

                    // Cart Items List (PERBAIKAN: Menambahkan ListView untuk cart items)
                    

                    // Cart Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(total),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Remix.wallet_line, size: 18),
                                  SizedBox(width: 8),
                                  Text('Checkout'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
