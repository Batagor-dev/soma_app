// lib/main.dart
import 'package:flutter/material.dart';
import 'core/routes/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Route awal
      initialRoute: Routes.login,

      // Semua route terdaftar di sini
      routes: Routes.routes,

      // Optional: fallback kalau route tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Route Not Found"),
            ),
          ),
        );
      },
    );
  }
}
