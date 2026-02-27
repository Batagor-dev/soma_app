import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/auth_service.dart';
import '../../../widgets/input_text.dart';
import '../../../widgets/input_dropdown.dart';
import '../../../widgets/button_auth.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isInitialLoading = true;

  String? _selectedGender;

  String? _nameError;
  String? _usernameError;
  String? _emailError;

  final List<String> _genderList = ["male", "female", "other"];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await _authService.getMe();
      if (!mounted) return;

      final data = result["data"];

      String? genderFromApi = data["gender"]?.toString().trim().toLowerCase();

      setState(() {
        _nameController.text = data["name"] ?? "";
        _usernameController.text = data["username"] ?? "";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["phone"] ?? "";
        _addressController.text = data["address"] ?? "";

        _selectedGender =
            _genderList.contains(genderFromApi) ? genderFromApi : null;

        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitialLoading = false);
      _showError("Gagal mengambil data profile");
    }
  }

  bool _validate() {
    bool isValid = true;

    setState(() {
      _nameError = null;
      _usernameError = null;
      _emailError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = "Nama wajib diisi";
        isValid = false;
      }

      if (_usernameController.text.trim().isEmpty) {
        _usernameError = "Username wajib diisi";
        isValid = false;
      }

      if (_emailController.text.trim().isEmpty) {
        _emailError = "Email wajib diisi";
        isValid = false;
      } else if (!_emailController.text.contains("@")) {
        _emailError = "Format email tidak valid";
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
            Expanded(child: Text("Profil berhasil diperbarui")),
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
      final result = await _authService.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result["success"] == true) {
        _showSuccess(result["message"] ?? "");
        await _loadProfile();
      } else {
        _showError("Gagal memperbarui profil");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Widget _buildSkeleton({double height = 50}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
            const SizedBox(height: 20),
            _isInitialLoading
                ? _buildSkeleton()
                : InputText(
                    controller: _nameController,
                    hint: "Nama Lengkap",
                    icon: Icons.person_outline,
                    errorText: _nameError,
                  ),
            const SizedBox(height: 18),
            _isInitialLoading
                ? _buildSkeleton()
                : InputText(
                    controller: _usernameController,
                    hint: "Username",
                    icon: Icons.alternate_email,
                    errorText: _usernameError,
                  ),
            const SizedBox(height: 18),
            _isInitialLoading
                ? _buildSkeleton()
                : InputText(
                    controller: _emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
            const SizedBox(height: 18),
            _isInitialLoading
                ? _buildSkeleton()
                : InputDropdown(
                    hint: "Jenis Kelamin",
                    value: _selectedGender,
                    icon: Icons.person_outline,
                    items: const [
                      DropdownMenuItem(
                        value: "male",
                        child: Text("Laki-laki"),
                      ),
                      DropdownMenuItem(
                        value: "female",
                        child: Text("Perempuan"),
                      ),
                      DropdownMenuItem(
                        value: "other",
                        child: Text("Lainnya"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
            const SizedBox(height: 18),
            _isInitialLoading
                ? _buildSkeleton()
                : InputText(
                    controller: _phoneController,
                    hint: "Nomor Telepon",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
            const SizedBox(height: 18),
            _isInitialLoading
                ? _buildSkeleton(height: 70)
                : InputText(
                    controller: _addressController,
                    hint: "Alamat",
                    icon: Icons.location_on_outlined,
                  ),
            const SizedBox(height: 32),
            _isInitialLoading
                ? _buildSkeleton(height: 55)
                : ButtonAuth(
                    text: "Simpan Perubahan",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
            const SizedBox(height: 24),
            const Text(
              "Pastikan data yang kamu ubah sudah benar sebelum disimpan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
