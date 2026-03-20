import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/bmi_page.dart';
import '../dashboard/artikel_page.dart';
import 'package:fitlife/pages/dashboard/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<int> _history = [];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      _history.add(_selectedIndex);
      setState(() => _selectedIndex = index);
    }
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _selectedIndex = _history.removeLast();
      });
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  //HOME CONTENT
  Widget _buildHomeContent() {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 370;

    return ListView(
      children: [
        /// HERO SECTION
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isSmall ? 20 : 24,
            isSmall ? 24 : 30,
            isSmall ? 20 : 24,
            45,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FFF3), Color(0xFFCFFFEA)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(45),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF66).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, Welcome Back!",
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563), // soft dark
                ),
              ),
              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 26 : 30,
                    fontWeight: FontWeight.w800,
                  ),
                  children: const [
                    TextSpan(
                      text: "FitLife.id",
                      style: TextStyle(color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Track your health journey in a smarter way.",
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13 : 14,
                  height: 1.4,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 35),

        /// FEATURE SECTION
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
          child: Column(
            children: [
              Text(
                'Fitur Unggulan',
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua kebutuhan kesehatan dalam satu aplikasi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: isSmall ? 12 : 13,
                ),
              ),
              const SizedBox(height: 25),

              _buildFeatureCard(
                Icons.calculate,
                'Kalkulator BMI',
                'Hitung indeks massa tubuh anda.',
                Colors.orange,
                isSmall,
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                Icons.restaurant_menu,
                'Menu Sehat',
                'Temukan berbagai pilihan menu sehat.',
                Colors.pink,
                isSmall,
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                Icons.article,
                'Artikel & Tips',
                'Baca artikel dan tips diet sehat.',
                Colors.blue,
                isSmall,
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                Icons.person,
                'Profil',
                'Kelola informasi pribadi anda.',
                Colors.purple,
                isSmall,
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  // ================= FEATURE CARD =================

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String desc,
    Color iconColor,
    bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF66).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 48 : 55,
            height: isSmall ? 48 : 55,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: isSmall ? 22 : 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            BmiPage(onBack: _goBack),
            const Center(child: Text("Halaman Menu")),
            ArtikelPage(onBack: _goBack),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          final isActive = _selectedIndex == index;

          final icons = [
            Icons.home,
            Icons.calculate,
            Icons.restaurant_menu,
            Icons.article,
            Icons.person,
          ];

          final labels = ["Home", "BMI", "Menu", "Artikel", "Profil"];

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00FF66).withOpacity(0.15)
                    : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    icons[index],
                    size: isActive ? 26 : 22,
                    color: isActive ? const Color(0xFF00FF66) : Colors.grey,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Text(
                      labels[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00FF66),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
