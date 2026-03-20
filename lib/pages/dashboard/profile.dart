import 'dart:convert';
import 'package:fitlife/models/user_model.dart';
import 'package:fitlife/services/auth_services.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<UserModel?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  void _handleLogout(BuildContext context) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keluar Akun?',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda akan keluar dari akun ini.\nLogin ulang diperlukan untuk melanjutkan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    // Panggil auth.logout() — hapus token + sign out Google
    await auth.logout();

    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: {'message': 'Berhasil keluar dari akun'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: FutureBuilder<UserModel?>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          return Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    user?.name ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    user?.email ?? '-',
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),

                  // Role badge
                  if (user?.role != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user!.role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
