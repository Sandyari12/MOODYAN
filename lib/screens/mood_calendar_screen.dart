import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/mood_prefs_service.dart';
import 'package:intl/intl.dart';
import '../models/mood_journal.dart';

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);
const Color textDark = Color(0xFF222222);

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  Map<DateTime, MoodJournal> _moodMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final moods = await MoodPrefsService.getAll();
    final map = <DateTime, MoodJournal>{};
    for (var mood in moods) {
      final date = DateTime.parse(mood.date);
      final key = DateTime(date.year, date.month, date.day);
      // Only keep the latest mood for each day
      if (!map.containsKey(key) || date.isAfter(DateTime.parse(map[key]!.date))) {
        map[key] = mood;
      }
    }
    setState(() {
      _moodMap = map;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final mood = _moodMap[DateTime(day.year, day.month, day.day)];
                      if (mood != null) {
                        return Center(
                          child: mood.emoji != null && mood.emoji.endsWith('.png')
                            ? SizedBox(width: 56, height: 56, child: Image.asset(mood.emoji, fit: BoxFit.contain))
                            : Text(mood.emoji ?? '', style: const TextStyle(fontSize: 22, color: textDark)),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final mood = _moodMap[DateTime(day.year, day.month, day.day)];
                      return Container(
                        decoration: BoxDecoration(
                          color: bossyPinkMedium,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: mood != null && mood.emoji != null && mood.emoji.endsWith('.png')
                            ? SizedBox(width: 40, height: 40, child: Image.asset(mood.emoji, fit: BoxFit.contain))
                            : Text(mood?.emoji ?? '', style: const TextStyle(fontSize: 22, color: bossyPinkDark)),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final mood = _moodMap[DateTime(day.year, day.month, day.day)];
                      return Container(
                        decoration: BoxDecoration(
                          color: bossyPink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: mood != null && mood.emoji != null && mood.emoji.endsWith('.png')
                            ? SizedBox(width: 40, height: 40, child: Image.asset(mood.emoji, fit: BoxFit.contain))
                            : Text(mood?.emoji ?? '', style: const TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (_selectedDay != null && _moodMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] != null)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: bossyPinkLight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy').format(_selectedDay!),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: bossyPinkDark),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Mood: ', style: const TextStyle(fontSize: 16, color: textDark)),
                              const SizedBox(width: 6),
                              _moodMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.emoji.endsWith('.png')
                                ? Image.asset(_moodMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.emoji, width: 40, height: 40)
                                : Text(_moodMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.emoji, style: const TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Catatan: ${_moodMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.note}',
                            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: textDark),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
} 