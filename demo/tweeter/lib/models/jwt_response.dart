import 'user.dart';

class JwtResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  JwtResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      user: User(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        roles: (json['roles'] as List<dynamic>? ?? [])
            .map((role) => role.toString())
            .toList(),
      ),
    );
  }
}