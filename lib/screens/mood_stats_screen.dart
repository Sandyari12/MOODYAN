import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import 'package:intl/intl.dart';
import '../models/mood_journal.dart';

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);
const Color textDark = Color(0xFF222222);

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  int _touchedIndex = -1;

  final List<String> moodOrder = [
    'Menangis', 'Sedih', 'Kecewa', 'Frustasi', 'Canggung', 'Malu', 'Takut', 'Lelah', 'Sakit',
    'Biasa', 'Santai', 'Optimis', 'Bahagia', 'Senang', 'Bersyukur', 'Excited', 'Pesta'
  ];
  final Map<String, int> moodScore = {
    'Menangis': 1, 'Sedih': 2, 'Kecewa': 3, 'Frustasi': 4, 'Canggung': 5, 'Malu': 6, 'Takut': 7, 'Lelah': 8, 'Sakit': 9,
    'Biasa': 10, 'Santai': 11, 'Optimis': 12, 'Bahagia': 13, 'Senang': 14, 'Bersyukur': 15, 'Excited': 16, 'Pesta': 17
  };

  Map<String, int> _calculateMoodCountPerDay(List<MoodJournal> moods) {
    final Map<String, int> count = {};
    for (var mood in moods) {
      final date = DateFormat('dd MMM').format(DateTime.parse(mood.date));
      count[date] = (count[date] ?? 0) + 1;
    }
    return count;
  }

  String? _getMostFrequentMood(List<MoodJournal> moods) {
    if (moods.isEmpty) return null;
    final freq = <String, int>{};
    for (var mood in moods) {
      freq[mood.mood] = (freq[mood.mood] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String? _getMostFrequentEmoji(List<MoodJournal> moods) {
    if (moods.isEmpty) return null;
    final freq = <String, int>{};
    final emojiMap = <String, String>{};
    for (var mood in moods) {
      freq[mood.mood] = (freq[mood.mood] ?? 0) + 1;
      emojiMap[mood.mood] = mood.emoji;
    }
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return emojiMap[sorted.first.key];
  }

  double? _getAverageMoodValue(List<MoodJournal> moods) {
    if (moods.isEmpty) return null;
    final values = moods.map((m) => moodScore[m.mood] ?? 10).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  String? _getAverageMoodLabel(double? value) {
    if (value == null) return null;
    final idx = value.round().clamp(1, moodOrder.length) - 1;
    return moodOrder[idx];
  }

  @override
  Widget build(BuildContext context) {
    final barColors = [bossyPinkDark, bossyPink, bossyPinkMedium];
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final moods = moodProvider.moods;
        final isLoading = moodProvider.isLoading;
        final moodCountPerDay = _calculateMoodCountPerDay(moods);
        final mostFrequentMood = _getMostFrequentMood(moods);
        final mostFrequentEmoji = _getMostFrequentEmoji(moods);
        final averageMoodValue = _getAverageMoodValue(moods);

        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Mood per Hari',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bossyPinkDark),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: bossyPinkLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: moodCountPerDay.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 32),
                                  Icon(Icons.bar_chart, size: 64, color: bossyPinkMedium),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada data mood untuk ditampilkan',
                                    style: TextStyle(fontSize: 16, color: textDark),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              )
                            : SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (moodCountPerDay.values.isEmpty ? 1 : moodCountPerDay.values.reduce((a, b) => a > b ? a : b).toDouble() + 1),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: bossyPinkMedium,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final date = moodCountPerDay.keys.elementAt(group.x.toInt());
                                          final count = moodCountPerDay.values.elementAt(group.x.toInt());
                                          return BarTooltipItem(
                                            '$date\n',
                                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            children: [
                                              TextSpan(
                                                text: '$count mood',
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      touchCallback: (event, response) {
                                        setState(() {
                                          _touchedIndex = response?.spot?.touchedBarGroupIndex ?? -1;
                                        });
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) {
                                          if (value % 1 != 0) return const SizedBox();
                                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, color: textDark));
                                        }),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final idx = value.toInt();
                                            if (idx < 0 || idx >= moodCountPerDay.keys.length) return const SizedBox();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(moodCountPerDay.keys.elementAt(idx), style: const TextStyle(fontSize: 12, color: textDark)),
                                            );
                                          },
                                          reservedSize: 36,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(show: true, horizontalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: bossyPinkMedium, strokeWidth: 1)),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(moodCountPerDay.length, (idx) {
                                      final isTouched = idx == _touchedIndex;
                                      return BarChartGroupData(
                                        x: idx,
                                        barRods: [
                                          BarChartRodData(
                                            toY: moodCountPerDay.values.elementAt(idx).toDouble(),
                                            gradient: LinearGradient(
                                              colors: isTouched ? [bossyPinkDark, bossyPink] : barColors,
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            width: 22,
                                            borderRadius: BorderRadius.circular(8),
                                            backDrawRodData: BackgroundBarChartRodData(
                                              show: true,
                                              toY: 0,
                                              color: bossyPinkLight,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: bossyPinkLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('Mood Terbanyak', style: TextStyle(fontSize: 14, color: bossyPinkDark)),
                                const SizedBox(height: 4),
                                mostFrequentEmoji != null
                                    ? (mostFrequentEmoji.endsWith('.png')
                                        ? SizedBox(
                                            width: 56,
                                            height: 56,
                                            child: Image.asset(mostFrequentEmoji, fit: BoxFit.contain),
                                          )
                                        : Text(mostFrequentEmoji, style: const TextStyle(fontSize: 48)))
                                    : const Text('-', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 2),
                                Text(mostFrequentMood ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                              ],
                            ),
                            Container(width: 1, height: 48, color: bossyPinkMedium),
                            Column(
                              children: [
                                const Text('Rata-rata Mood', style: TextStyle(fontSize: 14, color: bossyPinkDark)),
                                const SizedBox(height: 4),
                                averageMoodValue != null
                                    ? Text(_getAverageMoodLabel(averageMoodValue) ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark))
                                    : const Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
} 