import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/logo-soma.png",
      width: size,
      height: size,
    );
  }
}
