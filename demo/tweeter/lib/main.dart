import 'package:flutter/material.dart';
import 'services/book_service.dart';
import 'services/auth_service.dart';
import 'models/book_post.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literatura Rusa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _buildHome(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(title: 'Literatura Rusa'),
      },
    );
  }

  Widget _buildHome() {
    final authService = AuthService();
    if (authService.isAuthenticated()) {
      return const MyHomePage(title: 'Literatura Rusa');
    } else {
      return const LoginScreen();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BookService _bookService;
  late AuthService _authService;
  late Future<List<BookPost>> _booksFuture;

  final TextEditingController _nombreLibroController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookService = BookService();
    _authService = AuthService();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _booksFuture = _bookService.fetchBooks();
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada')),
    );
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
      _showErrorDialog('Todos los campos son obligatorios');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _bookService.createBook(
        nombreLibro: nombreLibro,
        imagen: imagen,
        autor: autor,
        descripcion: descripcion,
      );

      _nombreLibroController.clear();
      _imagenController.clear();
      _autorController.clear();
      _descripcionController.clear();

      _loadBooks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro agregado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error al crear libro: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBook(int id) async {
    setState(() => _isLoading = true);

    try {
      await _bookService.deleteBook(id);
      _loadBooks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro eliminado correctamente'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error al eliminar libro: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar libro'),
          content: const Text('¿Seguro que quieres eliminar este libro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(id);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nombreLibroController.dispose();
    _imagenController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    _bookService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Usuario: ${user?.username ?? "Desconocido"}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCreateBookSection(),
          Expanded(
            child: FutureBuilder<List<BookPost>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadBooks,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay libros disponibles'),
                  );
                } else {
                  final books = snapshot.data!;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _buildBookCard(book);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBookSection() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nombreLibroController,
            decoration: InputDecoration(
              hintText: 'Nombre del libro',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imagenController,
            decoration: InputDecoration(
              hintText: 'URL de la imagen',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _autorController,
            decoration: InputDecoration(
              hintText: 'Autor',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Descripción',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createBook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Agregar libro'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookPost book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.imagen.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imagen,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No se pudo cargar la imagen'),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Text(
              book.nombreLibro,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Autor: ${book.autor}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(book.descripcion),
            const SizedBox(height: 8),
            Text(
              'ID: ${book.id}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(book.id),
                tooltip: 'Eliminar libro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}