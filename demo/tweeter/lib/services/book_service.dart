import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_post.dart';
import '../repositories/book_repository.dart';

class BookService implements IBookRepository {
  static final BookService _instance = BookService._internal();

  final String baseUrl = 'https://literatura-8l0q.onrender.com/api/books';
  late http.Client _httpClient;

  BookService._internal() {
    _httpClient = http.Client();
  }

  factory BookService() {
    return _instance;
  }

  static BookService getInstance() {
    return _instance;
  }

  @override
  Future<List<BookPost>> fetchBooks() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => BookPost.fromJson(item)).toList();
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
  Future<BookPost> createBook(
    String nombreLibro,
    String imagen,
    String autor,
    String descripcion,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
