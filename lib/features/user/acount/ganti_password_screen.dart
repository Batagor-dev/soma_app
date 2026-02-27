import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../core/services/auth_service.dart';
import '../../../widgets/input_password.dart';
import '../../../widgets/button_auth.dart';
import '../../../core/theme/app_colors.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;

  bool _isLoading = false;

  bool _validate() {
    bool isValid = true;

    setState(() {
      _currentError = null;
      _newError = null;
      _confirmError = null;

      if (_currentPasswordController.text.isEmpty) {
        _currentError = "Password lama wajib diisi";
        isValid = false;
      }

      if (_newPasswordController.text.length < 6) {
        _newError = "Minimal 6 karakter";
        isValid = false;
      }

      if (_confirmPasswordController.text != _newPasswordController.text) {
        _confirmError = "Konfirmasi tidak sama";
        isValid = false;
      }
    });

    return isValid;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Remix.checkbox_circle_fill, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text("Password berhasil diganti")),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Remix.error_warning_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result["success"] == true) {
        _showSuccess(result["message"] ?? "");
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            InputPassword(
              controller: _currentPasswordController,
              hint: "Password Lama",
              icon: Icons.lock_outline,
              errorText: _currentError,
            ),
            const SizedBox(height: 18),
            InputPassword(
              controller: _newPasswordController,
              hint: "Password Baru",
              icon: Icons.lock_reset_outlined,
              errorText: _newError,
            ),
            const SizedBox(height: 18),
            InputPassword(
              controller: _confirmPasswordController,
              hint: "Konfirmasi Password Baru",
              icon: Icons.lock_outline,
              errorText: _confirmError,
            ),
            const SizedBox(height: 30),
            ButtonAuth(
              text: "Simpan Password",
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
            const Text(
              "Gunakan kombinasi huruf dan angka agar lebih aman.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
