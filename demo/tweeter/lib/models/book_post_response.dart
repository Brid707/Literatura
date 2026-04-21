import 'book_post.dart';

class BookPostResponse {
  final List<BookPost> content;

  BookPostResponse({
    required this.content,
  });

  factory BookPostResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];

    return BookPostResponse(
      content: contentList
          .map((item) => BookPost.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  @override
  String toString() => 'BookPostResponse(content: ${content.length})';
}