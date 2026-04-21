import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book_post.dart';
import '../repositories/book_repository.dart';
import 'auth_service.dart';

class BookService implements IBookRepository {
  static final BookService _instance = BookService._internal();

  final String baseUrl = 'https://literatura-8l0q.onrender.com/api';
  late http.Client _httpClient;
  late AuthService _authService;

  BookService._internal() {
    _httpClient = http.Client();
    _authService = AuthService();
  }

  factory BookService() {
    return _instance;
  }

  static BookService getInstance() {
    return _instance;
  }

  Map<String, String> _getHeaders() {
    final token = _authService.getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  @override
  Future<List<BookPost>> fetchBooks() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);

        if (jsonData is List) {
          return jsonData
              .map((item) => BookPost.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('content')) {
          final content = jsonData['content'] as List<dynamic>? ?? [];
          return content
              .map((item) => BookPost.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception(
          'Failed to load books. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  @override
  Future<BookPost> createBook({
    required String nombreLibro,
    required String imagen,
    required String autor,
    required String descripcion,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/create'),
        headers: _getHeaders(),
        body: jsonEncode({
          'nombreLibro': nombreLibro,
          'imagen': imagen,
          'autor': autor,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return BookPost.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to create book. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating book: $e');
    }
  }

  @override
  Future<void> deleteBook(int id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete book. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}