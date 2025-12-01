import 'package:flutter/material.dart';
// hive access via HiveDatabase
import '../database/hive_database.dart';
import '../services/user_status_service.dart';
import '../widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Ambil data user dari Hive
  Future<void> _loadUserData() async {
    final hiveDb = HiveDatabase();
    final userBox = await hiveDb.getUserBox();
    final currentEmail = await hiveDb.getCurrentUserEmail();

    setState(() {
      _username = userBox.get('username', defaultValue: 'User');
      _email = currentEmail ?? userBox.get('current_email', defaultValue: '-');
    });
  }

  /// 🔹 Simpan perubahan ke Hive
  Future<void> _saveProfile() async {
    // Allow partial updates: if a field is left empty, keep existing value.
    _formKey.currentState!.save();

    await _applyProfileUpdates(newUsername: _username, newEmail: _email);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );

    Navigator.pop(context); // kembali ke ProfileScreen
  }

  /// Apply only the provided (non-empty) updates to the stored user data.
  Future<void> _applyProfileUpdates({String? newUsername, String? newEmail}) async {
    final hiveDb = HiveDatabase();
    final userBox = await hiveDb.getUserBox();

    final rawCurrent = (userBox.get('current_email') ?? '').toString();
    final oldEmail = rawCurrent.trim().toLowerCase();

    final usernameToSet = (newUsername ?? '').toString().trim();
    final emailToSet = (newEmail ?? '').toString().trim().toLowerCase();

    // Fetch existing user map if present
    Map<String, dynamic>? existingMap;
    if (oldEmail.isNotEmpty && userBox.containsKey(oldEmail)) {
      final e = userBox.get(oldEmail);
      if (e is Map) existingMap = Map<String, dynamic>.from(e);
    }

    // If emailToSet provided and valid and different -> move key
    if (emailToSet.isNotEmpty && emailToSet.contains('@')) {
      // If existing map present, copy it to new key
      final updated = existingMap != null ? {...existingMap} : <String, dynamic>{};
      if (usernameToSet.isNotEmpty) updated['username'] = usernameToSet;
      updated['email'] = emailToSet;

      await userBox.put(emailToSet, updated);

      // remove old key if different
      if (oldEmail.isNotEmpty && oldEmail != emailToSet && userBox.containsKey(oldEmail)) {
        await userBox.delete(oldEmail);
      }

      await userBox.put('current_email', emailToSet);
    } else {
      // No email change — update existing map if present
      if (existingMap != null) {
        final updated = {...existingMap};
        if (usernameToSet.isNotEmpty) updated['username'] = usernameToSet;
        // keep existing email
        await userBox.put(oldEmail, updated);
      }
    }

    // Update top-level convenience keys
    if (usernameToSet.isNotEmpty) await userBox.put('username', usernameToSet);
    if (existingMap != null && existingMap['profile_image'] != null) {
      await userBox.put('profile_image', existingMap['profile_image']);
    }

    // Refresh username notifier
    await UserStatusService.refreshUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: const CustomAppBar(
        title: 'Edit Profil',
        backgroundColor: Color(0xFF012D5A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 6),

              // 🔹 Field Username
              TextFormField(
                initialValue: _username,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nama Pengguna",
                  labelStyle: const TextStyle(color: Colors.orangeAccent),
                  filled: true,
                  fillColor: const Color(0xFF00345B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.trim().isEmpty) {
                    return "Nama tidak boleh kosong";
                  }
                  return null;
                },
                onSaved: (val) => _username = val,
                onFieldSubmitted: (val) async {
                  final trimmed = val.trim();
                  if (trimmed.isEmpty) return;
                  await _applyProfileUpdates(newUsername: trimmed);
                  if (!mounted) return;
                  setState(() => _username = trimmed);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama pengguna disimpan')));
                },
              ),
              const SizedBox(height: 20),

              // 🔹 Field Email
              TextFormField(
                initialValue: _email,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.orangeAccent),
                  filled: true,
                  fillColor: const Color(0xFF00345B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains("@")) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
                onSaved: (val) => _email = val,
              ),
              const SizedBox(height: 40),

              // 🔹 Tombol Simpan
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}