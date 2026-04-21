import '../models/jwt_response.dart';

abstract class IAuthRepository {
  Future<JwtResponse> login(String username, String password);

  Future<void> logout();

  Future<void> init();

  bool isAuthenticated();

  String? getToken();
}