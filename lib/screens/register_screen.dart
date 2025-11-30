import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/hive_database.dart';
import '../services/user_status_service.dart';
import 'login_screen.dart';
// import 'home_screen.dart'; // kalau mau auto-login langsung ke Home

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    final hiveDb = HiveDatabase();

    try {
      // 🔹 Pastikan gak ada currentUser / current_email nyangkut
      final box = await hiveDb.getUserBox();
      await box.delete('currentUser');
      await box.delete('current_email');

      final emailExists = await hiveDb.checkEmailExists(email);
      if (emailExists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Email sudah terdaftar")));
        setState(() => _isLoading = false);
        return;
      }

      // 🔹 Simpan user baru
      await hiveDb.addUser(
        username: username,
        email: email,
        password: password,
      );

      // 🔹 Simpan current user key (simpan kedua key untuk kompatibilitas)
      await box.put('currentUser', email);
      await box.put('current_email', email);

      // Update global username notifier
      await UserStatusService.refreshUsername();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
      );

      // 👉 Kalau mau langsung ke HomeScreen, ganti ini:
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
      // );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e, st) {
      if (kDebugMode) print("❌ Hive Register Error: $e\n$st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }

    setState(() => _isLoading = false);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/Logo.png', width: 120),
                  const SizedBox(height: 20),
                  const Text(
                    "Buat Akun EjaMate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          validator: (v) =>
                              v!.isEmpty ? 'Masukkan username' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Masukkan email';
                            } else if (!_isValidEmail(v)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (v) =>
                              v!.length < 6 ? 'Minimal 6 karakter' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: _registerUser,
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sudah punya akun? Masuk",
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
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
}
