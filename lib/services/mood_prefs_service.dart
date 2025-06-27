import '../models/mood_journal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodPrefsService {
  static Future<List<MoodJournal>> getAll() async {
    final snapshot = await FirebaseFirestore.instance.collection('mood').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => MoodJournal.fromFirestore(doc)).toList();
  }

  static Future<void> add(MoodJournal mood) async {
    await FirebaseFirestore.instance.collection('mood').add({
      'mood': mood.mood,
      'emoji': mood.emoji,
      'note': mood.note,
      'date': DateTime.tryParse(mood.date) ?? mood.date, // simpan sebagai Timestamp jika bisa
    });
  }

  static Future<void> delete(String docId) async {
    await FirebaseFirestore.instance.collection('mood').doc(docId).delete();
  }

  static Future<int> update(MoodJournal updatedMood) async {
    if (updatedMood.docId == null) return 0;
    await FirebaseFirestore.instance.collection('mood').doc(updatedMood.docId).update({
      'mood': updatedMood.mood,
      'emoji': updatedMood.emoji,
      'note': updatedMood.note,
      'date': DateTime.tryParse(updatedMood.date) ?? updatedMood.date, // simpan sebagai Timestamp jika bisa
    });
    return 1;
  }
} 