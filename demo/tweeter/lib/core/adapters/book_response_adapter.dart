import '../../models/book_post.dart';

class BookResponseAdapter {
  const BookResponseAdapter._();

  static List<BookPost> extractBooks(dynamic response) {
    if (response is List) {
      return _mapBooks(response);
    }

    if (response is Map<String, dynamic>) {
      final content = response['content'];
      if (content is List) {
        return _mapBooks(content);
      }
    }

    throw const FormatException('Unexpected book response format');
  }

  static List<BookPost> _mapBooks(List<dynamic> items) {
    return items
        .map((item) => BookPost.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}