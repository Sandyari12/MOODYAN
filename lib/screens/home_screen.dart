import 'package:flutter/material.dart';
import 'mood_entry_screen.dart';
import '../services/mood_prefs_service.dart';
import '../services/user_prefs_service.dart';
import '../services/session_service.dart';
import 'mood_detail_screen.dart';
import 'mood_stats_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';
import 'mood_calendar_screen.dart';
import '../models/mood_journal.dart';

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);
const Color textDark = Color(0xFF222222);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Home tab state
  List<MoodJournal> _moods = [];
  bool _isLoading = true;
  String? _userEmail;
  String? _userName;
  String? _mostFrequentMood;
  String? _mostFrequentEmoji;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadMoods();
    await _loadUserName();
    _calculateStats();
    setState(() {});
  }

  Future<void> _loadMoods() async {
    final moods = await MoodPrefsService.getAll();
    setState(() {
      _moods = moods;
      _isLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    _userEmail = await SessionService.getLoggedInEmail();
    if (_userEmail != null) {
      final name = await UserPrefsService.getUserName(_userEmail!);
      setState(() {
        _userName = name;
      });
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    final thisMonth = _moods.where((mood) {
      final date = DateTime.parse(mood.date);
      return date.month == now.month && date.year == now.year;
    }).toList();
    if (thisMonth.isNotEmpty) {
      final freq = <String, int>{};
      final emojiMap = <String, String>{};
      for (var mood in thisMonth) {
        freq[mood.mood] = (freq[mood.mood] ?? 0) + 1;
        emojiMap[mood.mood] = mood.emoji;
      }
      final sorted = freq.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _mostFrequentMood = sorted.first.key;
      _mostFrequentEmoji = emojiMap[_mostFrequentMood];
    } else {
      _mostFrequentMood = null;
      _mostFrequentEmoji = null;
    }
    final dates = _moods.map((m) => DateFormat('yyyy-MM-dd').format(DateTime.parse(m.date))).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime day = DateTime.now();
    while (dates.contains(DateFormat('yyyy-MM-dd').format(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    _streak = streak;
  }

  Future<void> _navigateToAddMood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodEntryScreen()),
    );
    if (result == true) {
      await _loadAll();
    }
  }

  Future<void> _navigateToMoodDetail(MoodJournal mood) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoodDetailScreen(mood: mood)),
    );
    if (result != null) {
      await _loadAll();
    }
  }

  Widget _buildHomeTab() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    MoodJournal? todayMood;
    try {
      todayMood = _moods.firstWhere(
        (mood) => DateFormat('yyyy-MM-dd').format(DateTime.parse(mood.date)) == today,
      );
    } catch (e) {
      todayMood = null;
    }
    String greeting = 'Halo, selamat datang! 👋';
    if ((_userName ?? '').isNotEmpty) {
      greeting = 'Hope your day is as amazing as you are!';
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.deepPurple.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_mostFrequentMood != null && _mostFrequentEmoji != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _mostFrequentEmoji!.endsWith('.png')
                          ? SizedBox(
                              width: 56,
                              height: 56,
                              child: Image.asset(_mostFrequentEmoji!, fit: BoxFit.contain),
                            )
                          : Text(_mostFrequentEmoji!, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          'Mood terbanyak bulan ini: $_mostFrequentMood',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.deepPurple, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Streak: $_streak hari berturut-turut',
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_emotions_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'Belum ada data mood bulan ini',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.grey, size: 22),
                            const SizedBox(width: 8),
                            const Text('-', style: TextStyle(fontSize: 15, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  if (_mostFrequentMood != null && _mostFrequentEmoji != null)
                    const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Riwayat Mood & Jurnal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _moods.isEmpty
                    ? const Center(child: Text('Belum ada data mood/jurnal.'))
                    : ListView.builder(
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final date = DateFormat('dd MMM').format(DateTime.parse(mood.date));
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: mood.emoji != null
                                  ? SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Image.asset(mood.emoji, fit: BoxFit.contain),
                                    )
                                  : Icon(Icons.emoji_emotions, size: 48),
                              title: Text(mood.mood),
                              subtitle: Text('"${mood.note}"'),
                              trailing: Text(date),
                              onTap: () => _navigateToMoodDetail(mood),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) return _buildHomeTab();
    if (_selectedIndex == 1) return const MoodStatsScreen();
    if (_selectedIndex == 2) return const MoodCalendarScreen();
    return const ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'MOODYAN';
    if (_selectedIndex == 1) appBarTitle = 'Statistik Mood';
    if (_selectedIndex == 2) appBarTitle = 'Kalender Mood';
    if (_selectedIndex == 3) appBarTitle = 'Profil';
    return Scaffold(
      backgroundColor: bossyPinkLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bossyPink,
        foregroundColor: Colors.white,
        elevation: 2,
        title: _selectedIndex == 0
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo2.png', width: 36, height: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'MOODYAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            : Text(
                appBarTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        centerTitle: false,
        leading: _selectedIndex == 0 ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali ke Home',
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
        actions: _selectedIndex == 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              ]
            : null,
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: bossyPink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mood'),
              onPressed: _navigateToAddMood,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: bossyPinkDark,
        unselectedItemColor: bossyPinkMedium,
        backgroundColor: bossyPinkLight,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
        ],
      ),
    );
  }
} 