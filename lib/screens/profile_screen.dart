import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_prefs_service.dart';
import '../services/session_service.dart';

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String? _userEmail;
  String? _userName;
  String? _joinDate = "1 Januari 2024";
  String? _avatarPath;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _userEmail = await SessionService.getLoggedInEmail();
    if (_userEmail != null) {
      final name = await UserPrefsService.getUserName(_userEmail!);
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = name;
        _avatarPath = prefs.getString('avatar_path');
      });
    }
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    await UserPrefsService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('avatar_path', picked.path);
                  setState(() {
                    _avatarPath = picked.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('avatar_path', picked.path);
                  setState(() {
                    _avatarPath = picked.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hapus Foto Profil'),
              onTap: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('avatar_path');
                setState(() {
                  _avatarPath = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfileDialog() {
    final nameController = TextEditingController(text: _userName ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: bossyPinkDark,
                          side: const BorderSide(color: bossyPinkDark, width: 2),
                          backgroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bossyPink,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (nameController.text.trim().isNotEmpty) {
                            await UserPrefsService.updateUserName(_userEmail!, nameController.text.trim());
                            setState(() {
                              _userName = nameController.text.trim();
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bossyPinkLight,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                    radius: 48,
                    backgroundColor: bossyPinkMedium,
                      backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                      child: _avatarPath == null
                          ? Text(
                              (_userName != null && _userName!.isNotEmpty)
                                  ? _userName![0].toUpperCase()
                                  : '',
                              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Nama
                  Text(
                    _userName ?? 'User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bossyPinkDark),
                  ),
                  const SizedBox(height: 6),
                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, color: bossyPink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _userEmail ?? '-',
                        style: const TextStyle(fontSize: 15, color: bossyPinkDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Tanggal gabung
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, color: bossyPink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Gabung: $_joinDate',
                        style: const TextStyle(fontSize: 15, color: bossyPinkDark),
                  ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tombol Edit Profil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, color: bossyPinkDark),
                      label: const Text('Edit Profil', style: TextStyle(color: bossyPinkDark)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: bossyPinkDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
              ),
                      onPressed: _editProfileDialog,
            ),
          ),
                  const SizedBox(height: 12),
                  // Tombol Logout
          SizedBox(
                    width: double.infinity,
            child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: bossyPink,
                foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                      onPressed: _logout,
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