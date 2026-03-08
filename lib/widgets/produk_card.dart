import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProdukCard extends StatefulWidget {
  final Map<String, dynamic> produk;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isInCart;
  final int? cartQuantity;

  const ProdukCard({
    super.key,
    required this.produk,
    this.onTap,
    this.onAddToCart,
    this.isInCart = false,
    this.cartQuantity,
  });

  @override
  State<ProdukCard> createState() => _ProdukCardState();
}

class _ProdukCardState extends State<ProdukCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _formatHarga {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    dynamic hargaValue = widget.produk['harga'] ?? 0;
    double hargaDouble = 0;

    if (hargaValue is String) {
      hargaDouble = double.tryParse(hargaValue) ?? 0;
    } else if (hargaValue is int) {
      hargaDouble = hargaValue.toDouble();
    } else if (hargaValue is double) {
      hargaDouble = hargaValue;
    }

    return currencyFormat.format(hargaDouble);
  }

  int get _stok {
    return widget.produk['stok'] ?? 0;
  }

  bool get _isOutOfStock {
    return _stok <= 0;
  }

  bool get _isLowStock {
    return _stok > 0 && _stok <= 5;
  }

  String get _namaProduk {
    return widget.produk['nama_produk'] ?? 'Produk';
  }

  String? get _imageUrl {
    return widget.produk['gambar'];
  }

  String? get _kategori {
    return widget.produk['kategori_nama'] ?? widget.produk['kategori'];
  }

  Color _getStokColor() {
    if (_stok > 10) return Colors.green;
    if (_stok > 0) return Colors.orange;
    return Colors.red;
  }

  IconData _getCategoryIcon() {
    final categoryName = _kategori?.toLowerCase() ?? '';

    if (categoryName.contains('makanan') || categoryName.contains('food')) {
      return Remix.restaurant_line;
    } else if (categoryName.contains('minuman') ||
        categoryName.contains('drink')) {
      return Remix.cup_line;
    } else if (categoryName.contains('snack') ||
        categoryName.contains('camilan')) {
      return Remix.cake_line;
    } else if (categoryName.contains('elektronik')) {
      return Remix.device_line;
    } else if (categoryName.contains('pakaian') ||
        categoryName.contains('fashion')) {
      return Remix.shirt_line;
    } else if (categoryName.contains('alat tulis')) {
      return Remix.pencil_line;
    } else if (categoryName.contains('kesehatan')) {
      return Remix.heart_pulse_line;
    } else {
      return Remix.price_tag_line;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: _isOutOfStock ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (_isHovered ? Colors.blue : Colors.black)
                      .withOpacity(0.1),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background gradient for hover effect
                  if (_isHovered && !_isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade50.withOpacity(0.3),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section dengan badge overlay
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: _buildImage(),
                          ),

                          // Category badge di pojok kiri atas
                          if (_kategori != null && _kategori!.isNotEmpty)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.amber.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(),
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _kategori!,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Stock badge di pojok kanan atas
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildStockBadge(),
                          ),

                          // Quantity badge jika ada di cart
                          if (widget.isInCart && widget.cartQuantity != null)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${widget.cartQuantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama produk
                            Text(
                              _namaProduk,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.3,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Harga dengan desain yang lebih menarik
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade50,
                                    Colors.green.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Remix.coin_fill,
                                    size: 12,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatHarga,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Stok indicator dan add to cart button
                            Row(
                              children: [
                                // Stok indicator dengan progress bar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Remix.stock_line,
                                            size: 12,
                                            color: _getStokColor(),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Stok $_stok',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _getStokColor(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Add to cart button dengan animasi
                                if (!_isOutOfStock)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: widget.onAddToCart,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: widget.isInCart
                                                ? LinearGradient(
                                                    colors: [
                                                      Colors.blue.shade100,
                                                      Colors.blue.shade200,
                                                    ],
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.blue.shade400,
                                                      Colors.blue.shade600,
                                                    ],
                                                  ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              if (!widget.isInCart)
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                widget.isInCart
                                                    ? Remix.add_circle_line
                                                    : Remix.shopping_cart_line,
                                                size: 14,
                                                color: widget.isInCart
                                                    ? Colors.blue.shade700
                                                    : Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.isInCart
                                                    ? 'Tambah'
                                                    : 'Tambah',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: widget.isInCart
                                                      ? Colors.blue.shade700
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Overlay untuk out of stock
                  if (_isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Remix.error_warning_line,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Stok Habis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      if (_imageUrl!.startsWith('http')) {
        return Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildNoImage(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingImage(loadingProgress);
          },
        );
      } else {
        return Image.asset(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildNoImage(),
        );
      }
    }

    return _buildNoImage();
  }

  Widget _buildNoImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOutOfStock ? Remix.shopping_bag_line : Remix.image_line,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            _isOutOfStock ? 'Stok Habis' : 'Tidak Ada Gambar',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage(ImageChunkEvent loadingProgress) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: Colors.blue.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    if (_isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Remix.close_circle_line,
              size: 10,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Habis',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (_isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Remix.alarm_warning_line,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Sisa $_stok',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// PERBAIKAN: Skeleton loading yang lebih halus dengan efek shimmer yang lebih baik
class ProdukCardSkeleton extends StatelessWidget {
  const ProdukCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      direction: ShimmerDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton dengan badge skeletons
            _buildImageSkeleton(),

            // Content skeleton dengan variasi ukuran
            _buildContentSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSkeleton() {
    return Stack(
      children: [
        // Background image skeleton
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: Colors.grey.shade300,
            ),
          ),
        ),

        // Category badge skeleton
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            width: 80,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),

        // Stock badge skeleton
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton dengan 2 baris yang bervariasi
          Container(
            width: double.infinity,
            height: 18,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 18,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Price skeleton dengan desain pill
          Container(
            width: 130,
            height: 32,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          // Stock indicator dan button skeleton dalam satu baris
          Row(
            children: [
              // Stock indicator skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Progress bar skeleton
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Button skeleton
              Container(
                width: 80,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PERBAIKAN: Skeleton dengan gradient animasi yang lebih halus (alternatif)
class ProdukCardSkeletonGradient extends StatefulWidget {
  const ProdukCardSkeletonGradient({super.key});

  @override
  State<ProdukCardSkeletonGradient> createState() =>
      _ProdukCardSkeletonGradientState();
}

class _ProdukCardSkeletonGradientState extends State<ProdukCardSkeletonGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _beginAnimation;
  late Animation<Alignment> _endAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _beginAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _endAnimation = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: _beginAnimation.value,
              end: _endAnimation.value,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
                Colors.grey.shade400,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

              // Content skeleton
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    Container(
                      width: double.infinity,
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Price skeleton
                    Container(
                      width: 130,
                      height: 32,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    // Stock indicator and button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 70,
                                height: 12,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Extension untuk menggunakan skeleton dengan mudah
extension ProdukCardSkeletonExtension on Widget {
  Widget withSkeleton({required bool isLoading, Widget? skeleton}) {
    if (isLoading) {
      return skeleton ?? const ProdukCardSkeleton();
    }
    return this;
  }
}
