import '../../models/book_comment.dart';
import '../../models/book_post.dart';
import '../../models/jwt_response.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';

class LibraryFacade {
  LibraryFacade({
    required AuthService authService,
    required BookService bookService,
  }) : _authService = authService,
       _bookService = bookService;

  final AuthService _authService;
  final BookService _bookService;

  Future<void> init() => _authService.init();

  bool isAuthenticated() => _authService.isAuthenticated();

  User? getUser() => _authService.getUser();

  Future<JwtResponse> login(String username, String password) {
    return _authService.login(username, password);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _authService.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _authService.logout();

  Future<List<BookPost>> fetchBooks() {
    return _bookService.fetchBooks();
  }

  Future<BookPost> createBook({
    required String nombreLibro,
    required String imagen,
    required String autor,
    required String descripcion,
  }) {
    return _bookService.createBook(
      nombreLibro: nombreLibro,
      imagen: imagen,
      autor: autor,
      descripcion: descripcion,
    );
  }

  Future<void> deleteBook(int id) {
    return _bookService.deleteBook(id);
  }

  Future<List<BookComment>> fetchBookComments(int bookPostId) {
    return _bookService.fetchBookComments(bookPostId);
  }

  Future<BookComment> createBookComment({
    required int bookPostId,
    required String content,
  }) {
    return _bookService.createBookComment(
      bookPostId: bookPostId,
      content: content,
    );
  }

  Future<void> reactToBook({required int bookPostId, required String type}) {
    return _bookService.reactToBook(bookPostId: bookPostId, type: type);
  }

  void dispose() {
    _bookService.dispose();
  }
}
