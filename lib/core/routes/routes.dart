import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/user/main_screen.dart';
import '../../features/user/produk/tambah_produk.dart';
import '../../features/user/katagori/tambah_kategori.dart';
import '../../features/user/transaksi_screen.dart';
import '../../features/user/transaksi/history_screen.dart';
import '../../features/user/transaksi/pengeluaran_screen.dart';
import '../../features/user/transaksi/transaksi_detail_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String produk = '/produk';
  static const String pengaturan = '/pengaturan';
  static const String kasir = '/kasir';
  static const String tambahProduk = '/tambah-produk';
  static const String editProduk = '/edit-produk';
  static const String tambahKategori = '/tambah-kategori';
  static const String transaksi = '/transaksi';
  static const String history = '/history';
  static const String pengeluaran = '/pengeluaran';
  static const String transaksiDetail = '/transaksi-detail';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const MainScreen(),
    tambahProduk: (_) => const TambahProduk(),
    editProduk: (_) => const TambahProduk(),
    tambahKategori: (_) => const TambahKategori(),
    transaksi: (_) => const TransaksiScreen(),
    history: (_) => const HistoryScreen(),
    pengeluaran: (_) => const PengeluaranScreen(),
    transaksiDetail: (_) => const TransaksiDetailScreen(),
  };
}
