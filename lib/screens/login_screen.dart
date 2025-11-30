import 'package:flutter/material.dart';
import '../database/hive_database.dart';
import 'register_screen.dart';
import 'home_screen.dart'; // ganti dengan halaman utama kamu
import '../services/user_status_service.dart';
import '../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _biometricAvailable = false;
  String? _biometricUserEmail;

  Future<void> _login() async {
    final emailOrUsername = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrUsername.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom.")));
      return;
    }

    setState(() => _isLoading = true);
    final db = HiveDatabase();

    try {
      final user = await db.loginUser(emailOrUsername, password);

      if (user != null) {
        // update global username notifier so UI updates
        await UserStatusService.refreshUsername();
        // offer biometric opt-in for this user if device supports it
        try {
          final hive = HiveDatabase();
          final currentEmail = (user['email'] ?? '')?.toString().toLowerCase() ?? '';
          final canBio = await BiometricService.isAvailable();
          final u = (await hive.getUserBox()).get(currentEmail);
          final already = (u is Map) ? (u['biometric_enabled'] ?? false) : false;
          if (canBio && !already && currentEmail.isNotEmpty) {
            // ask user whether to enable
            if (!mounted) return;
            final enable = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Aktifkan masuk biometrik?'),
                content: const Text('Aktifkan autentikasi sidik jari / PIN perangkat untuk masuk cepat?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Tidak')),
                  ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya')),
                ],
              ),
            );
            if (enable == true) {
              await hive.updateUser(currentEmail, {'biometric_enabled': true});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masuk biometrik diaktifkan')));
            }
          }
        } catch (_) {}
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: user['username']),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau password salah.")),
        );

        // 🔍 Debug: lihat isi Hive saat login gagal
        await db.printAllUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }

    setState(() => _isLoading = false);
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
            child: Column(
              children: [
                Image.asset('assets/images/Logo.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  "Masuk ke EjaMate",
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
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: 'Email atau Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
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
                              onPressed: _login,
                              child: const Text(
                                "Login",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Biometric login button (if a user opted in and device supports it)
                            if (_biometricAvailable && _biometricUserEmail != null)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.fingerprint_outlined),
                                label: const Text('Masuk pakai Biometrik'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade800,
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: _loginWithBiometric,
                              ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Belum punya akun? Daftar",
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
    );
  }

  @override
  void initState() {
    super.initState();
    _detectBiometricEnabledUser();
  }

  Future<void> _detectBiometricEnabledUser() async {
    try {
      final can = await BiometricService.isAvailable();
      if (!can) return;
      final hive = HiveDatabase();
      final box = await hive.getUserBox();
      for (var k in box.keys) {
        if (k == 'currentUser' || k == 'current_email' || k == 'username' || k == 'profile_image') continue;
        final val = box.get(k);
        if (val is Map) {
          final enabled = (val['biometric_enabled'] ?? false) as bool;
          if (enabled) {
            setState(() {
              _biometricAvailable = true;
              _biometricUserEmail = k.toString();
            });
            return;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loginWithBiometric() async {
    if (_biometricUserEmail == null) return;
    final ok = await BiometricService.authenticate();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autentikasi biometrik gagal')));
      return;
    }
    try {
      final hive = HiveDatabase();
      // set current user keys
      await hive.getUserBox();
      await hive.updateUser(_biometricUserEmail!, {}); // no-op to ensure key exists
      final box = await hive.getUserBox();
      await box.put('current_email', _biometricUserEmail);
      await box.put('currentUser', _biometricUserEmail);
      await UserStatusService.refreshUsername();
      final u = box.get(_biometricUserEmail);
      final username = (u is Map) ? (u['username'] ?? 'User') : 'User';
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(username: username)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal login: $e')));
    }
  }
}
