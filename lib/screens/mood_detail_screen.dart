import 'package:flutter/material.dart';
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

class MoodDetailScreen extends StatefulWidget {
  final MoodJournal mood;
  
  const MoodDetailScreen({super.key, required this.mood});

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen> {
  late MoodJournal _currentMood;
  bool _isEditing = false;
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentMood = widget.mood;
    _noteController.text = _currentMood.note;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _deleteMood() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mood'),
        content: const Text('Apakah Anda yakin ingin menghapus mood ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<MoodProvider>().deleteMood(_currentMood.date);
      if (mounted) {
        if (success) {
          Navigator.pop(context, 'deleted');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus mood!')),
          );
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedMood = MoodJournal(
        docId: _currentMood.docId,
        id: _currentMood.id,
        mood: _currentMood.mood,
        emoji: _currentMood.emoji,
        note: _noteController.text,
        date: _currentMood.date,
      );
      
      final success = await context.read<MoodProvider>().updateMood(updatedMood);
      
      if (success) {
        setState(() {
          _isEditing = false;
          _currentMood = updatedMood;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mood berhasil diperbarui!')),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context, 'updated');
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan perubahan!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(_currentMood.date);
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final time = DateFormat('HH:mm').format(date);
    final canEditDelete = _currentMood.docId != null;

    return Scaffold(
      backgroundColor: bossyPinkLight,
      appBar: AppBar(
        backgroundColor: bossyPink,
        foregroundColor: Colors.white,
        title: const Text('Detail Mood', style: TextStyle(color: Colors.white)),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: canEditDelete
                  ? () {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data ini tidak bisa diedit karena tidak valid. Tambahkan mood lewat aplikasi!')),
                      );
                    },
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: canEditDelete
                  ? _deleteMood
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data ini tidak bisa dihapus karena tidak valid. Tambahkan mood lewat aplikasi!')),
                      );
                    },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan emoji dan mood
              Center(
                child: Column(
                  children: [
                    _currentMood.emoji.endsWith('.png')
                      ? SizedBox(
                          width: 120,
                          height: 120,
                          child: Image.asset(_currentMood.emoji, fit: BoxFit.contain),
                        )
                      : Text(_currentMood.emoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 8),
                    Text(
                      _currentMood.mood,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: bossyPinkDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Informasi tanggal dan waktu
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: bossyPinkLight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: bossyPinkDark),
                          const SizedBox(width: 8),
                          const Text(
                            'Tanggal & Waktu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: bossyPinkDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 16, color: textDark),
                      ),
                      Text(
                        'Pukul $time',
                        style: TextStyle(
                          fontSize: 14,
                          color: bossyPinkMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Catatan/Jurnal
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: bossyPinkLight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: bossyPinkDark),
                          const SizedBox(width: 8),
                          const Text(
                            'Catatan/Jurnal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: bossyPinkDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isEditing)
                        TextFormField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Tulis catatan atau cerita hari ini...',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: textDark),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Catatan tidak boleh kosong';
                            }
                            return null;
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bossyPinkLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: bossyPinkMedium),
                          ),
                          child: Text(
                            _currentMood.note,
                            style: const TextStyle(fontSize: 16, color: textDark),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Tombol aksi saat editing
              if (_isEditing) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _noteController.text = _currentMood.note;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: bossyPinkDark,
                          side: const BorderSide(color: bossyPinkDark),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canEditDelete ? _saveChanges : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data ini tidak bisa diedit karena tidak valid. Tambahkan mood lewat aplikasi!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bossyPink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 