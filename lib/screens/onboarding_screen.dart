import 'package:flutter/material.dart';

// Palet warna Bossy Pink
const Color bossyPinkLight = Color(0xFFF8C6D8);
const Color bossyPink = Color(0xFFE94B77);
const Color bossyPinkMedium = Color(0xFFF49CB7);
const Color bossyPinkDark = Color(0xFFB8325B);
const Color textDark = Color(0xFF222222);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _pageIndex = 0;

  void _nextPage() {
    setState(() {
      _pageIndex = (_pageIndex + 1).clamp(0, 1);
    });
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bossyPinkLight,
      body: Stack(
        children: [
          // Background balon dengan opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/balon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: _pageIndex == 0 ? _buildWelcomePage() : _buildGetStartedPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hapus gambar balon di sini
        const SizedBox(height: 32),
        Text(
          'Welcome to',
          style: TextStyle(fontSize: 22, color: bossyPinkDark, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'MOODYAN',
          style: TextStyle(fontSize: 38, color: bossyPink, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Text(
          'Track your mood, understand yourself.',
          style: TextStyle(fontSize: 16, color: textDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bossyPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          onPressed: _nextPage,
          child: const Text('Get Started'),
        ),
      ],
    );
  }

  Widget _buildGetStartedPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hapus gambar balon di sini
        const SizedBox(height: 32),
        Text(
          'MOODYAN\nfor Everyone',
          style: TextStyle(fontSize: 28, color: bossyPinkDark, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Catat suasana hati, lihat statistik, dan pahami dirimu lebih baik setiap hari.',
          style: TextStyle(fontSize: 16, color: textDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bossyPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          onPressed: _goToLogin,
          child: const Text('Continue'),
        ),
      ],
    );
  }
} 