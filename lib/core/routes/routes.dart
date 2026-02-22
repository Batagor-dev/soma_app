import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/user/home_screen.dart';
import '../../features/user/produk_screen.dart';
import '../../features/user/transaksi_screen.dart';
import '../../features/user/pengaturan_screen.dart';
import '../../features/user/kasir_screen.dart';
import '../../features/user/main_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String produk = '/produk';
  static const String transaksi = '/transaksi';
  static const String pengaturan = '/pengaturan';
  static const String kasir = '/kasir';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const MainScreen(),
  };
}
