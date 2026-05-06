class BookPost {
  final int id;
  final String nombreLibro;
  final String imagen;
  final String autor;
  final String descripcion;
  final String? postedByUsername;
  final int? postedByUserId;
  final int commentsCount;
  final int reactionsCount;

  BookPost({
    required this.id,
    required this.nombreLibro,
    required this.imagen,
    required this.autor,
    required this.descripcion,
    this.postedByUsername,
    this.postedByUserId,
    required this.commentsCount,
    required this.reactionsCount,
  });

  factory BookPost.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return BookPost(
      id: parseInt(json['id']),
      nombreLibro: json['nombreLibro']?.toString() ?? '',
      imagen: json['imagen']?.toString() ?? '',
      autor: json['autor']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      postedByUsername: json['postedByUsername']?.toString(),
      postedByUserId: json['postedByUserId'] == null
          ? null
          : parseInt(json['postedByUserId']),
      commentsCount: parseInt(json['commentsCount']),
      reactionsCount: parseInt(json['reactionsCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreLibro': nombreLibro,
      'imagen': imagen,
      'autor': autor,
      'descripcion': descripcion,
      'postedByUsername': postedByUsername,
      'postedByUserId': postedByUserId,
      'commentsCount': commentsCount,
      'reactionsCount': reactionsCount,
    };
  }

  @override
  String toString() {
    return 'BookPost(id: $id, nombreLibro: $nombreLibro, autor: $autor)';
  }
}