class AppText {
  // Bahasa Indonesia
  static const indo = _Indo();

  // Bahasa Inggris
  static const eng = _Eng();
}

// ===========================
// Bahasa Indonesia
// ===========================
class _Indo {
  const _Indo();

  // App general
  final String appName = "Soma";
  final String welcome = "Selamat datang";
  final String logout = "Keluar";
  final String profile = "Profil";

  // Login
  final String login = "Masuk";
  final String loginDeskripsi =
      "Silahkan masuk dengan akun Anda untuk melanjutkan";
  final String email = "Email";
  final String password = "Kata sandi";
  final String loginButton = "Masuk Sekarang";

  // Register
  final String register = "Daftar";
  final String registerDeskripsi =
      "Silahkan buat akun baru untuk mulai menggunakan aplikasi";
  final String confirmPassword = "Konfirmasi kata sandi";
  final String registerButton = "Daftar Sekarang";

  // Error messages
  final String fieldRequired = "Kolom ini wajib diisi";
  final String emailError = "Format email tidak valid";
  final String emailWrong = "Email Anda salah";
  final String passwordError = "Kata sandi minimal 6 karakter";
  final String passwordWrong = "Kata sandi salah";
  final String confirmPasswordError = "Kata sandi tidak cocok";
  final String accountNotFound = "Akun tidak ditemukan";
}

// ===========================
// Bahasa Inggris
// ===========================
class _Eng {
  const _Eng();

  // App general
  final String appName = "Soma";
  final String welcome = "Welcome";
  final String logout = "Logout";
  final String profile = "Profile";

  // Login
  final String login = "Login";
  final String loginDescription = "Please login with your account to continue";
  final String email = "Email";
  final String password = "Password";
  final String loginButton = "Login Now";

  // Register
  final String register = "Register";
  final String registerDescription =
      "Please create a new account to start using the app";
  final String confirmPassword = "Confirm Password";
  final String registerButton = "Register Now";

  // Error messages
  final String fieldRequired = "This field is required";
  final String emailError = "Invalid email format";
  final String emailWrong = "Incorrect email";
  final String passwordError = "Password must be at least 6 characters";
  final String passwordWrong = "Incorrect password";
  final String confirmPasswordError = "Passwords do not match";
  final String accountNotFound = "Account not found";
}
