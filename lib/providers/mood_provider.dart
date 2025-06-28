import 'package:flutter/foundation.dart';
import '../models/mood_journal.dart';
import '../services/mood_prefs_service.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodJournal> _moods = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MoodJournal> get moods => _moods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load moods from Firestore only
  Future<void> loadMoods() async {
    _setLoading(true);
    try {
      final cloudMoods = await MoodPrefsService.getAll();
      cloudMoods.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      _moods = cloudMoods;
      _error = null;
    } catch (e) {
      _error = 'Failed to load moods: $e';
      if (kDebugMode) {
        print('Error loading moods: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Add new mood (Firestore only)
  Future<bool> addMood(MoodJournal mood) async {
    try {
      await MoodPrefsService.add(mood);
      await loadMoods();
      return true;
    } catch (e) {
      _error = 'Failed to add mood: $e';
      if (kDebugMode) {
        print('Error adding mood: $e');
      }
      return false;
    }
  }

  // Update mood (Firestore only)
  Future<bool> updateMood(MoodJournal mood) async {
    try {
      await MoodPrefsService.update(mood);
      await loadMoods();
      return true;
    } catch (e) {
      _error = 'Failed to update mood: $e';
      if (kDebugMode) {
        print('Error updating mood: $e');
      }
      return false;
    }
  }

  // Delete mood (Firestore only)
  Future<bool> deleteMood(String date) async {
    try {
      // Cari mood berdasarkan tanggal
      final moodToDelete = _moods.firstWhere((m) => m.date == date);
      if (moodToDelete.docId != null) {
        await MoodPrefsService.delete(moodToDelete.docId!);
      }
      await loadMoods();
      return true;
    } catch (e) {
      _error = 'Failed to delete mood: $e';
      if (kDebugMode) {
        print('Error deleting mood: $e');
      }
      return false;
    }
  }

  // Get mood by date
  MoodJournal? getMoodByDate(String date) {
    try {
      return _moods.firstWhere((mood) => mood.date == date);
    } catch (e) {
      return null;
    }
  }

  // Get moods for specific month
  List<MoodJournal> getMoodsForMonth(int year, int month) {
    return _moods.where((mood) {
      final date = DateTime.parse(mood.date);
      return date.year == year && date.month == month;
    }).toList();
  }

  // Get most frequent mood
  String? getMostFrequentMood() {
    if (_moods.isEmpty) return null;
    final freq = <String, int>{};
    for (var mood in _moods) {
      freq[mood.mood] = (freq[mood.mood] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  // Get current streak
  int getCurrentStreak() {
    if (_moods.isEmpty) return 0;
    final dates = _moods.map((m) => m.date).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime day = DateTime.now();
    while (dates.contains(day.toIso8601String().split('T')[0])) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
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