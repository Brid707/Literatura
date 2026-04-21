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
    final id = json['id'];

    return BookPost(
      id: id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0),
      nombreLibro: json['nombreLibro']?.toString() ?? '',
      imagen: json['imagen']?.toString() ?? '',
      autor: json['autor']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
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

  @override
  String toString() {
    return 'BookPost(id: $id, nombreLibro: $nombreLibro, autor: $autor)';
  }
}
