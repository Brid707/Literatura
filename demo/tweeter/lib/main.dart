import 'package:flutter/material.dart';
import 'services/book_service.dart';
import 'models/book_post.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literatura Rusa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Literatura Rusa'),
    );
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
  late Future<List<BookPost>> _booksFuture;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookService = BookService();
    _loadBooks();
  }

  void _loadBooks() {
    _booksFuture = _bookService.fetchBooks();
  }

  Future<void> _createBook() async {
    try {
      final nombreLibro = _nombreController.text.trim();
      final imagen = _imagenController.text.trim();
      final autor = _autorController.text.trim();
      final descripcion = _descripcionController.text.trim();

      if (nombreLibro.isEmpty ||
          imagen.isEmpty ||
          autor.isEmpty ||
          descripcion.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')),
        );
        return;
      }

      await _bookService.createBook(
        nombreLibro,
        imagen,
        autor,
        descripcion,
      );

      _nombreController.clear();
      _imagenController.clear();
      _autorController.clear();
      _descripcionController.clear();

      setState(() {
        _loadBooks();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro agregado')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar libro: $e')),
      );
    }
  }

  Future<void> _deleteBook(int id) async {
    try {
      await _bookService.deleteBook(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado')),
      );

      setState(() {
        _loadBooks();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar libro'),
          content: Text('¿Seguro que quieres eliminar el libro con ID $id?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteBook(id);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _imagenController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    _bookService.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre del libro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _imagenController,
            decoration: const InputDecoration(
              labelText: 'Link de imagen',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _autorController,
            decoration: const InputDecoration(
              labelText: 'Autor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descripcionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createBook,
              child: const Text('Agregar libro'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookPost book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    return const SizedBox(
                      height: 180,
                      child: Center(child: Text('No se pudo cargar la imagen')),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            Text(
              book.nombreLibro,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
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
                onPressed: () => _confirmDelete(book.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildForm(),
          Expanded(
            child: FutureBuilder<List<BookPost>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
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
                      return _buildBookCard(books[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _loadBooks();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
