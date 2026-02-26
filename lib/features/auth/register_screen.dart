// register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import '../../core/routes/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_texts.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/input_text.dart';
import '../../widgets/input_password.dart';
import '../../widgets/button_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  String? nameError;
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

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

                Text(
                  AppText.indo.register,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.indo.registerDeskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Lengkap
                Text("Nama Lengkap",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                InputText(
                  controller: nameController,
                  hint: "Masukkan nama lengkap",
                  errorText: nameError,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),

                // Username
                Text("Username",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                InputText(
                  controller: usernameController,
                  hint: "Masukkan username",
                  errorText: usernameError,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),

                // Email
                Text("Email",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                InputText(
                  controller: emailController,
                  hint: "Masukkan email",
                  errorText: emailError,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),

                // Password
                Text("Kata Sandi",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                InputPassword(
                  controller: passwordController,
                  hint: "Masukkan kata sandi",
                  errorText: passwordError,
                ),
                const SizedBox(height: 20),

                // Confirm Password
                Text("Konfirmasi Kata Sandi",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                InputPassword(
                  controller: confirmPasswordController,
                  hint: "Masukkan ulang kata sandi",
                  errorText: confirmPasswordError,
                ),
                const SizedBox(height: 24),

                // Tombol Register
                ButtonAuth(
                  text: AppText.indo.register,
                  isLoading: isLoading,
                  onPressed: _handleRegister,
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

                // Sudah punya akun? Masuk
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Sudah punya akun? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                          text: "Masuk disini",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.login);
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

  Future<void> _handleRegister() async {
    setState(() {
      isLoading = true;
      nameError = null;
      usernameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (nameController.text.isEmpty) {
      nameError = "Nama tidak boleh kosong";
      hasError = true;
    }
    if (usernameController.text.isEmpty) {
      usernameError = "Username tidak boleh kosong";
      hasError = true;
    }
    if (emailController.text.isEmpty) {
      emailError = "Email tidak boleh kosong";
      hasError = true;
    }
    if (passwordController.text.isEmpty) {
      passwordError = "Kata sandi tidak boleh kosong";
      hasError = true;
    }
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError = "Konfirmasi kata sandi tidak boleh kosong";
      hasError = true;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = "Kata sandi tidak sama";
      hasError = true;
    }

    setState(() {}); // refresh UI

    if (hasError) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final success = await AuthService().register(
        nameController.text,
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        // fallback error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi gagal")),
        );
      }
    } catch (e) {
      final msg = e.toString();
      setState(() {
        if (msg.toLowerCase().contains("email")) {
          emailError = msg;
        } else if (msg.toLowerCase().contains("username")) {
          usernameError = msg;
        } else if (msg.toLowerCase().contains("password")) {
          passwordError = msg;
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }
}
