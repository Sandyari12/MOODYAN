import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../services/session_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Initialize user from session
  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      final email = await SessionService.getLoggedInEmail();
      if (email != null) {
        final user = await DBService.getUserByEmail(email);
        if (user != null) {
          _currentUser = user;
        }
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize user: $e';
      if (kDebugMode) {
        print('Error initializing user: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> registerUser(String name, String email, String password) async {
    _setLoading(true);
    try {
      // Check if email already exists
      final existingUser = await DBService.getUserByEmail(email);
      if (existingUser != null) {
        _error = 'Email already registered';
        return false;
      }

      // Create new user
      final user = User(name: name, email: email, password: password);
      await DBService.insertUser(user);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to register user: $e';
      if (kDebugMode) {
        print('Error registering user: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> loginUser(String email, String password) async {
    _setLoading(true);
    try {
      final user = await DBService.validateLogin(email, password);
      if (user != null) {
        _currentUser = user;
        await SessionService.setLoggedInEmail(email);
        _error = null;
        return true;
      } else {
        _error = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      _error = 'Failed to login: $e';
      if (kDebugMode) {
        print('Error logging in: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await SessionService.clearSession();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to logout: $e';
      if (kDebugMode) {
        print('Error logging out: $e');
      }
    }
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateUserProfile(String newName) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      final updatedUser = _currentUser!.copyWith(name: newName);
      await DBService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user name
  String? getUserName() {
    return _currentUser?.name;
  }

  // Get user email
  String? getUserEmail() {
    return _currentUser?.email;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 