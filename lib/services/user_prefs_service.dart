import '../models/user.dart';
import 'db_service.dart';

class UserPrefsService {
  // Register user (insert ke SQLite)
  static Future<bool> registerUser(String name, String email, String password) async {
    final user = User(name: name, email: email, password: password);
    try {
      await DBService.insertUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek apakah email sudah terdaftar
  static Future<bool> isEmailRegistered(String email) async {
    final user = await DBService.getUserByEmail(email);
    return user != null;
  }

  // Validasi login
  static Future<bool> validateLogin(String email, String password) async {
    final user = await DBService.validateLogin(email, password);
    return user != null;
  }

  // Ambil nama user
  static Future<String?> getUserName(String email) async {
    final user = await DBService.getUserByEmail(email);
    return user?.name;
  }

  // Logout (tidak perlu hapus data di SQLite, cukup hapus session di app jika ada)
  static Future<void> logout() async {
    // Implementasi logout bisa berupa hapus session di app, bukan di database
    // Kosongkan saja jika tidak pakai session
  }

  // Tambahkan fungsi update nama user
  static Future<void> updateUserName(String email, String newName) async {
    final user = await DBService.getUserByEmail(email);
    if (user != null) {
      final updatedUser = user.copyWith(name: newName);
      await DBService.updateUser(updatedUser);
    }
  }
} 