import 'package:flutter/material.dart';

import '../core/facades/library_facade.dart';
import '../models/book_comment.dart';
import '../models/book_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.facade, required this.title});

  final LibraryFacade facade;
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<BookPost>> _booksFuture;

  final TextEditingController _nombreLibroController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _isSavingBook = false;

  LibraryFacade get _facade => widget.facade;

  String? get _username => _facade.getUser()?.username;

  @override
  void initState() {
    super.initState();
    _booksFuture = _facade.fetchBooks();
  }

  @override
  void dispose() {
    _nombreLibroController.dispose();
    _imagenController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = _facade.fetchBooks();
    });
  }

  Future<void> _logout() async {
    await _facade.logout();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _createBook() async {
    final nombreLibro = _nombreLibroController.text.trim();
    final imagen = _imagenController.text.trim();
    final autor = _autorController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (nombreLibro.isEmpty ||
        imagen.isEmpty ||
        autor.isEmpty ||
        descripcion.isEmpty) {
      _showSnack('Todos los campos del libro son obligatorios', isError: true);
      return;
    }

    setState(() => _isSavingBook = true);

    try {
      await _facade.createBook(
        nombreLibro: nombreLibro,
        imagen: imagen,
        autor: autor,
        descripcion: descripcion,
      );

      _nombreLibroController.clear();
      _imagenController.clear();
      _autorController.clear();
      _descripcionController.clear();

      _refreshBooks();

      _showSnack('Libro publicado correctamente');
    } catch (e) {
      _showSnack('Error al publicar libro: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSavingBook = false);
      }
    }
  }

  Future<void> _deleteBook(int id) async {
    try {
      await _facade.deleteBook(id);
      _refreshBooks();
      _showSnack('Libro eliminado');
    } catch (e) {
      _showSnack('Error al eliminar libro: $e', isError: true);
    }
  }

  Future<void> _reactToBook(int bookPostId, String type) async {
    try {
      await _facade.reactToBook(bookPostId: bookPostId, type: type);

      _refreshBooks();

      _showSnack('Reacción guardada');
    } catch (e) {
      _showSnack('No se pudo reaccionar: $e', isError: true);
    }
  }

  Future<void> _openComments(BookPost book) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _BookCommentsSheet(
          facade: _facade,
          book: book,
          onChanged: _refreshBooks,
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _facade.getUser();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FC),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        backgroundColor: const Color(0xFF4D2C7A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('@${user?.username ?? 'desconocido'}'),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshBooks();
          await _booksFuture;
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildCreateBookCard(),
            const SizedBox(height: 18),
            _buildSectionTitle(),
            const SizedBox(height: 10),
            _buildBooksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D2C7A), Color(0xFF7A55BD)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biblioteca de Literatura Rusa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Publica libros, comenta y reacciona a las recomendaciones.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBookCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publicar libro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E2243),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nombreLibroController,
              label: 'Nombre del libro',
              icon: Icons.book_outlined,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _autorController,
              label: 'Autor',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _imagenController,
              label: 'Imagen URL',
              icon: Icons.image_outlined,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSavingBook ? null : _createBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D2C7A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isSavingBook
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.publish_rounded),
                label: Text(_isSavingBook ? 'Guardando...' : 'Publicar libro'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE7DDF5)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      children: [
        Icon(Icons.library_books_rounded, color: Color(0xFF4D2C7A)),
        SizedBox(width: 8),
        Text(
          'Libros publicados',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E2243),
          ),
        ),
      ],
    );
  }

  Widget _buildBooksList() {
    return FutureBuilder<List<BookPost>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Error libros: ${snapshot.error}'),
            ),
          );
        }

        final books = snapshot.data ?? <BookPost>[];

        if (books.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Todavía no hay libros publicados.'),
            ),
          );
        }

        return Column(children: books.map(_buildBookCard).toList());
      },
    );
  }

  Widget _buildBookCard(BookPost book) {
    final isMine = book.postedByUsername == _username;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.imagen.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  book.imagen,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: const Color(0xFFEDE6F7),
                      alignment: Alignment.center,
                      child: const Text('No se pudo cargar la imagen'),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    book.nombreLibro,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E2243),
                    ),
                  ),
                ),
                if (isMine)
                  IconButton(
                    tooltip: 'Eliminar libro',
                    onPressed: () => _deleteBook(book.id),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            Text(
              'Autor: ${book.autor}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF675978),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.descripcion,
              style: const TextStyle(height: 1.35, color: Color(0xFF3F354D)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _CounterChip(
                  icon: Icons.favorite_rounded,
                  label: '${book.reactionsCount} reacciones',
                ),
                const SizedBox(width: 8),
                _CounterChip(
                  icon: Icons.comment_rounded,
                  label: '${book.commentsCount} comentarios',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openComments(book),
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comentar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _reactToBook(book.id, 'REACTION_LIKE'),
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Me gusta'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _reactToBook(book.id, 'REACTION_LOVE'),
                  icon: const Icon(Icons.favorite_border_rounded),
                  label: const Text('Me encanta'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _reactToBook(book.id, 'REACTION_FAVORITE'),
                  icon: const Icon(Icons.bookmark_border_rounded),
                  label: const Text('Favorito'),
                ),
              ],
            ),
            if (book.postedByUsername != null) ...[
              const SizedBox(height: 8),
              Text(
                'Publicado por @${book.postedByUsername}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7B7289)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  const _CounterChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF4D2C7A)),
      label: Text(label),
      backgroundColor: const Color(0xFFF1EAFB),
      side: BorderSide.none,
    );
  }
}

class _BookCommentsSheet extends StatefulWidget {
  const _BookCommentsSheet({
    required this.facade,
    required this.book,
    required this.onChanged,
  });

  final LibraryFacade facade;
  final BookPost book;
  final VoidCallback onChanged;

  @override
  State<_BookCommentsSheet> createState() => _BookCommentsSheetState();
}

class _BookCommentsSheetState extends State<_BookCommentsSheet> {
  late Future<List<BookComment>> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.facade.fetchBookComments(widget.book.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = widget.facade.fetchBookComments(widget.book.id);
    });
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    try {
      await widget.facade.createBookComment(
        bookPostId: widget.book.id,
        content: text,
      );

      _commentController.clear();
      _refreshComments();
      widget.onChanged();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDFBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7C8EA),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                title: Text(
                  'Comentarios',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(widget.book.nombreLibro),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<BookComment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final comments = snapshot.data ?? <BookComment>[];

                    if (comments.isEmpty) {
                      return const Center(
                        child: Text('Todavía no hay comentarios.'),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEEE5F8),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF4D2C7A),
                              ),
                            ),
                            title: Text(comment.content),
                            subtitle: Text('@${comment.commentedByUsername}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 10,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 50,
                        width: 54,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D2C7A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
