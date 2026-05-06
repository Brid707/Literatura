import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/adapters/book_response_adapter.dart';
import '../core/api_config.dart';
import '../models/book_comment.dart';
import '../models/book_post.dart';
import '../repositories/book_repository.dart';
import 'auth_service.dart';

class BookService implements IBookRepository {
  static final BookService _instance = BookService._internal();

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

  String get _baseUrl => ApiConfig.booksUrl;

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    final token = await _authService.getTokenOrRestore();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  @override
  Future<List<BookPost>> fetchBooks() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(_baseUrl),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        return BookResponseAdapter.extractBooks(jsonData);
      }

      throw Exception(
        'No se pudieron cargar los libros (${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Error cargando libros: $e');
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
        Uri.parse('$_baseUrl/create'),
        headers: await _headers(),
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
      }

      throw Exception('No se pudo crear el libro (${response.statusCode})');
    } catch (e) {
      throw Exception('Error creando libro: $e');
    }
  }

  @override
  Future<void> deleteBook(int id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'No se pudo eliminar el libro (${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error eliminando libro: $e');
    }
  }

  Future<List<BookComment>> fetchBookComments(int bookPostId) async {
    final response = await _httpClient.get(
      Uri.parse('${ApiConfig.baseUrl}/book-comments/book/$bookPostId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los comentarios (${response.statusCode})',
      );
    }

    final jsonData = jsonDecode(response.body);

    final List<dynamic> content = jsonData is Map<String, dynamic>
        ? (jsonData['content'] as List<dynamic>? ?? [])
        : (jsonData as List<dynamic>? ?? []);

    return content
        .map(
          (item) =>
              BookComment.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<BookComment> createBookComment({
    required int bookPostId,
    required String content,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}/book-comments'),
      headers: await _headers(),
      body: jsonEncode({'bookPostId': bookPostId, 'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'No se pudo crear el comentario (${response.statusCode})',
      );
    }

    return BookComment.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  Future<void> reactToBook({
    required int bookPostId,
    required String type,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${ApiConfig.baseUrl}/book-reactions'),
      headers: await _headers(),
      body: jsonEncode({'bookPostId': bookPostId, 'type': type}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'No se pudo reaccionar al libro (${response.statusCode})',
      );
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
