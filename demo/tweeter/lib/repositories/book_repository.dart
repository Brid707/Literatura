import '../models/book_post.dart';

abstract class IBookRepository {
  Future<List<BookPost>> fetchBooks();
  Future<BookPost> createBook(
    String nombreLibro,
    String imagen,
    String autor,
    String descripcion,
  );
  Future<void> deleteBook(int id);
  void dispose();
}
