import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const String _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get _host {
    if (_baseUrlOverride.isNotEmpty) {
      return '';
    }

    if (kIsWeb) {
      return 'localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  static String get _baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride.replaceAll(RegExp(r'/$'), '');
    }

    return 'http://$_host:8080/api';
  }

  static String get baseUrl => _baseUrl;
  static String get authUrl => '$_baseUrl/auth';
  static String get booksUrl => '$_baseUrl/books';
}
