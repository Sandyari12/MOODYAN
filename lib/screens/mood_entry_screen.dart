import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import 'package:intl/intl.dart';
import '../models/mood_journal.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);
const Color textDark = Color(0xFF222222);

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMood;
  String? _selectedEmoji;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> moods = [
    {'emoji': 'assets/emojis/senang.png', 'label': 'Senang'},
    {'emoji': 'assets/emojis/sedih.png', 'label': 'Sedih'},
    {'emoji': 'assets/emojis/kecewa.png', 'label': 'Kecewa'},
    {'emoji': 'assets/emojis/kaget.png', 'label': 'Kaget'},
    {'emoji': 'assets/emojis/frustasi.png', 'label': 'Frustasi'},
    {'emoji': 'assets/emojis/sakit.png', 'label': 'Sakit'},
    {'emoji': 'assets/emojis/bahagia.png', 'label': 'Bahagia'},
    {'emoji': 'assets/emojis/bingung.png', 'label': 'Bingung'},
    {'emoji': 'assets/emojis/marah.png', 'label': 'Marah'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bossyPinkLight,
      appBar: AppBar(
        backgroundColor: bossyPink,
        foregroundColor: Colors.white,
        title: const Text('Tambah Mood/Jurnal', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Mood:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bossyPinkDark),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: moods.map((mood) {
                  final isSelected = _selectedMood == mood['label'];
                  return Material(
                    color: Colors.transparent,
                    child: ChoiceChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(mood['emoji'], width: 64, height: 64, fit: BoxFit.contain),
                          const SizedBox(height: 6),
                          Text(
                            mood['label'],
                            style: const TextStyle(fontSize: 11, color: textDark),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: bossyPinkMedium,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          _selectedMood = mood['label'];
                          _selectedEmoji = mood['emoji'];
                        });
                      },
                      pressElevation: 0,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Catatan/Jurnal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bossyPinkDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis catatan atau cerita hari ini... ',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: textDark),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bossyPink,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_selectedMood == null || _selectedEmoji == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih mood terlebih dahulu!')),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      final now = DateTime.now().toLocal();
                      final date = now.toIso8601String();
                      final success = await context.read<MoodProvider>().addMood(
                        MoodJournal(
                          mood: _selectedMood!,
                          emoji: _selectedEmoji!,
                          note: _noteController.text,
                          date: date,
                        ),
                      );
                      if (mounted) {
                        if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mood berhasil ditambahkan!')),
                        );
                        Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal menambahkan mood!')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 