import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../facades/library_facade.dart';

class AppServiceFactory {
  const AppServiceFactory._();

  static AuthService authService() {
    return AuthService();
  }

  static BookService bookService() {
    return BookService();
  }

  static LibraryFacade libraryFacade() {
    return LibraryFacade(
      authService: authService(),
      bookService: bookService(),
    );
  }
}
