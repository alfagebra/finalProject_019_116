import 'dart:io';
import 'package:flutter/material.dart';
// hive access via HiveDatabase
import '../database/hive_database.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _profileImagePath;

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

    String? img;
    if (currentEmail != null && currentEmail.isNotEmpty) {
      img = await hiveDb.getUserProfileImage(currentEmail);
    }

    setState(() {
      _username = userBox.get('username', defaultValue: 'User');
      _email = currentEmail ?? userBox.get('current_email', defaultValue: '-');
      _profileImagePath = img ?? userBox.get('profile_image');
    });
  }

  /// 🔹 Pilih gambar profil
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  /// 🔹 Simpan perubahan ke Hive
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

  final hiveDb = HiveDatabase();
  final userBox = await hiveDb.getUserBox();
    // Simpan ke struktur user per-email jika ada, supaya perubahan
    // username/profile terlihat di ProfileScreen yang membaca data per-email.
    final oldEmail = (userBox.get('current_email') ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final newEmail = (_email ?? '').toString().trim().toLowerCase();

    if (oldEmail.isNotEmpty && userBox.containsKey(oldEmail)) {
      // ambil existing map dan update
      final existing = userBox.get(oldEmail);
      if (existing is Map) {
        final updated = {
          ...Map<String, dynamic>.from(existing),
          'username': _username?.trim() ?? '',
          'email': newEmail,
        };

        if (newEmail.isNotEmpty && newEmail != oldEmail) {
          // pindahkan ke key baru
          await userBox.put(newEmail, updated);
          await userBox.delete(oldEmail);
        } else {
          await userBox.put(oldEmail, updated);
        }
      }
    } else if (newEmail.isNotEmpty) {
      // tidak ada oldEmail => simpan minimal data di key baru
      await userBox.put(newEmail, {
        'username': _username?.trim() ?? '',
        'email': newEmail,
        'password': '',
        'isPremium': false,
        'progress': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // update convenience/top-level keys as well
    // update convenience/top-level keys as well
    await userBox.put('username', _username);
    await userBox.put(
      'current_email',
      newEmail.isNotEmpty ? newEmail : oldEmail,
    );

    // Save profile image per-user (preferred). Also update top-level key for
    // backward compatibility.
    final targetEmail = (newEmail.isNotEmpty ? newEmail : oldEmail);
    if (targetEmail.isNotEmpty) {
      await hiveDb.setUserProfileImage(targetEmail, _profileImagePath);
    }
    await userBox.put('profile_image', _profileImagePath);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );

    // Refresh global username notifier so other screens update immediately
    await UserStatusService.refreshUsername();

    Navigator.pop(context); // balik ke ProfileScreen
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
              // 🔹 Foto profil
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : null,
                  child: _profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.orangeAccent,
                          size: 70,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Ketuk foto untuk mengubah gambar profil",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 30),

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
                  if (value == null || value.isEmpty) {
                    return "Nama tidak boleh kosong";
                  }
                  return null;
                },
                onSaved: (val) => _username = val,
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
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains("@")) {
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
