import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/jwt_response.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthService implements IAuthRepository {
  static final AuthService _instance = AuthService._internal();

  final String baseUrl = 'http://localhost:8080/api/auth';
  late http.Client _httpClient;

  SharedPreferences? _prefs;
  String? _token;
  User? _user;

  AuthService._internal() {
    _httpClient = http.Client();
  }

  factory AuthService() {
    return _instance;
  }

  static AuthService getInstance() {
    return _instance;
  }

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    _token = _prefs!.getString('token');

    final userJson = _prefs!.getString('user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  @override
  Future<JwtResponse> login(String username, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final jwtResponse = JwtResponse.fromJson(jsonData);

        _token = jwtResponse.accessToken;
        _user = jwtResponse.user;

        _prefs ??= await SharedPreferences.getInstance();
        await _prefs!.setString('token', _token!);
        await _prefs!.setString('user', jsonEncode(_user!.toJson()));

        return jwtResponse;
      } else {
        throw Exception(
          'Login failed. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  @override
  Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove('token');
    await _prefs!.remove('user');

    _token = null;
    _user = null;
  }

  @override
  bool isAuthenticated() {
    return _token != null && _token!.isNotEmpty;
  }

  @override
  String? getToken() {
    return _token;
  }

  User? getUser() {
    return _user;
  }
}