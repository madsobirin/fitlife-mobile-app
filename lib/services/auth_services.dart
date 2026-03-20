import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Login Manual ──
Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse('${Config.baseUrl}/auth/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = UserModel.fromJson({
        ...data['user'],
        'token': data['token'],
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('token', data['token']);

      return {'success': true, 'user': user};
    } else {
      // Ambil pesan error dari API
      final message = data['message'] ?? 'Email atau password salah.';
      return {'success': false, 'message': message};
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan koneksi.'};
  }
}

// ── Register ──
Future<Map<String, dynamic>> register(
  String name,
  String email,
  String password,
) async {
  final url = Uri.parse('${Config.baseUrl}/auth/register');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Register berhasil — ada token langsung
      if (data['token'] != null) {
        final user = UserModel.fromJson({
          ...data['user'],
          'token': data['token'],
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        await prefs.setString('token', data['token']);

        return {'success': true, 'user': user};
      }
      // Register berhasil tanpa token (perlu login)
      return {'success': true, 'user': null};
    } else {
      // Handle validation errors
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final message = firstError is List
            ? firstError.first
            : firstError.toString();
        return {'success': false, 'message': message};
      }
      final message = data['message'] ?? 'Registrasi gagal.';
      return {'success': false, 'message': message};
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan koneksi.'};
  }
}

// ── Login Google ──
Future<Map<String, dynamic>> loginWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: Config.googleClientId,
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return {'success': false, 'message': 'Login dibatalkan.'};
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      return {'success': false, 'message': 'Gagal mendapatkan token Google.'};
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'id_token': idToken}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = UserModel.fromJson({
        ...data['user'],
        'token': data['token'],
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('token', data['token']);

      return {'success': true, 'user': user};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Login Google gagal.',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

// ── Logout ──
Future<void> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Hit logout API
    if (token != null) {
      await http.post(
        Uri.parse('${Config.baseUrl}/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
  } catch (_) {}

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
  } catch (_) {}

  // Hapus semua local storage
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user');
  await prefs.remove('token');
}

// ── Get current user dari local storage ──
Future<UserModel?> getCurrentUser() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  } catch (_) {
    return null;
  }
}

// ── Get token ──
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
