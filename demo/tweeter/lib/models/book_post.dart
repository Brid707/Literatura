class BookPost {
  final int id;
  final String nombreLibro;
  final String imagen;
  final String autor;
  final String descripcion;

  BookPost({
    required this.id,
    required this.nombreLibro,
    required this.imagen,
    required this.autor,
    required this.descripcion,
  });

  factory BookPost.fromJson(Map<String, dynamic> json) {
    return BookPost(
      id: json['id'],
      nombreLibro: json['nombreLibro'],
      imagen: json['imagen'],
      autor: json['autor'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreLibro': nombreLibro,
      'imagen': imagen,
      'autor': autor,
      'descripcion': descripcion,
    };
  }
}
