import '../models/book_post.dart';

abstract class IBookRepository {
  Future<List<BookPost>> fetchBooks();

  Future<BookPost> createBook({
    required String nombreLibro,
    required String imagen,
    required String autor,
    required String descripcion,
  });

  Future<void> deleteBook(int id);

  void dispose();
}