// login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import '../../core/routes/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
// import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_texts.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/input_text.dart';
import '../../widgets/input_password.dart';
import '../../widgets/button_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(child: const AppLogo(size: 200)),
                const SizedBox(height: 20),

                // Title
                Text(
                  AppText.indo.login,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.indo.loginDeskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Email
                Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InputText(
                  controller: emailController,
                  hint: "Masukkan email Anda",
                  errorText: emailError,
                ),
                const SizedBox(height: 20),

                // Password
                Text(
                  "Kata Sandi",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InputPassword(
                  controller: passwordController,
                  hint: "Masukkan kata sandi Anda",
                  errorText: passwordError,
                ),
                const SizedBox(height: 12),

                // Lupa password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        "Lupa kata sandi?",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Login
                ButtonAuth(
                  text: AppText.indo.login,
                  isLoading: isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Divider "atau"
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.grey.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "atau",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey.withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 24),

                // Gabung "Belum punya akun? Daftar Sekarang"
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Belum punya akun? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                          text: "Daftar Sekarang",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.register);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
    });

    bool hasError = false;

    if (emailController.text.isEmpty) {
      emailError = "Email tidak boleh kosong";
      hasError = true;
    }

    if (passwordController.text.isEmpty) {
      passwordError = "Kata sandi tidak boleh kosong";
      hasError = true;
    }

    setState(() {}); // refresh UI

    if (hasError) {
      setState(() => isLoading = false);
      return;
    }

    final success = await AuthService().login(
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      setState(() {
        emailError = "Email salah";
        passwordError = "Kata sandi salah";
      });
    }
  }
}
