import 'package:cloud_firestore/cloud_firestore.dart';

class MoodJournal {
  String? docId;
  int? id;
  String mood;
  String emoji;
  String note;
  String date;

  MoodJournal({this.docId, this.id, required this.mood, required this.emoji, required this.note, required this.date});

  Map<String, dynamic> toMap() => {
    'mood': mood,
    'emoji': emoji,
    'note': note,
    'date': date,
  };

  factory MoodJournal.fromMap(Map<String, dynamic> map) => MoodJournal(
    mood: map['mood'],
    emoji: map['emoji'],
    note: map['note'],
    date: map['date'],
  );

  factory MoodJournal.fromFirestore(DocumentSnapshot doc) => MoodJournal(
    docId: doc.id,
    mood: doc['mood'],
    emoji: doc['emoji'].toString().contains('/') ? doc['emoji'] : 'assets/emojis/${doc['emoji']}',
    note: doc['note'],
    date: (doc['date'] is Timestamp)
        ? (doc['date'] as Timestamp).toDate().toIso8601String()
        : doc['date'].toString(),
  );
} 