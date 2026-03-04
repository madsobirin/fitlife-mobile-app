import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserModel?> login(String email, String password) async {
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('🔍 API Response data: $data');
      print('🔍 User data: ${data['user']}');

      final user = UserModel.fromJson({
        ...data['user'],
        'token': data['token'],
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } else {
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

Future<UserModel?> register(String name, String email, String password) async {
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

    print('🔍 Register status: ${response.statusCode}');
    print('🔍 Register body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Handle different response structures:
      // Case 1: { user: {...}, token: "..." }
      // Case 2: { id, name, email, ... } (flat response)
      // Case 3: { message: "...", user: {...} } (no token)
      Map<String, dynamic> userData;
      if (data['user'] != null && data['user'] is Map) {
        userData = {...data['user'], 'token': data['token'] ?? ''};
      } else if (data['id'] != null) {
        userData = {...data, 'token': data['token'] ?? ''};
      } else {
        // Registration succeeded but no user data returned — build minimal
        userData = {
          'id': 0,
          'name': name,
          'email': email,
          'role': data['role'] ?? 'user',
          'token': data['token'] ?? '',
        };
      }

      final user = UserModel.fromJson(userData);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } else {
      print('🔍 Register failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print("Register Error: $e");
    return null;
  }
}

Future<UserModel?> loginWithGoogle() async {
  try {
    // TODO: Replace with your Web Client ID from Google Cloud Console
    // Go to: https://console.cloud.google.com → APIs & Services → Credentials
    // Copy the "Web application" OAuth 2.0 Client ID
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: Config.googleClientId,
    );

    print('🔍 Google Sign-In: Starting sign in...');
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print('🔍 Google Sign-In: User cancelled sign in');
      return null;
    }

    print('🔍 Google Sign-In: Got user: ${googleUser.email}');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    print(
      '🔍 Google Sign-In: idToken is ${idToken != null ? "present" : "NULL"}',
    );
    print(
      '🔍 Google Sign-In: accessToken is ${accessToken != null ? "present" : "NULL"}',
    );

    if (idToken == null) {
      print(
        '❌ Google Sign-In: idToken is null! You need to set serverClientId in GoogleSignIn()',
      );
      return null;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'id_token': idToken}),
    );

    print('🔍 Google Sign-In: API response status: ${response.statusCode}');
    print('🔍 Google Sign-In: API response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final user = UserModel.fromJson({
        ...data['user'],
        'token': data['token'],
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } else {
      print('❌ Google Sign-In: API failed with status ${response.statusCode}');
      return null;
    }
  } catch (e, stackTrace) {
    print('❌ Google Sign-In Error: $e');
    print('❌ Google Sign-In StackTrace: $stackTrace');
    return null;
  }
}
