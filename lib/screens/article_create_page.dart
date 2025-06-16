import 'package:flutter/material.dart';
import '../services/article_service.dart';

class ArticleCreateScreen extends StatefulWidget {
  const ArticleCreateScreen({super.key});

  @override
  State<ArticleCreateScreen> createState() => _ArticleCreateScreenState();
}

class _ArticleCreateScreenState extends State<ArticleCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createArticle() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await createArticle(title, content);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo creado exitosamente')),
      );
      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear artículo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Artículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 8,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createArticle,
                    child: const Text('Publicar'),
                  ),
          ],
        ),
      ),
    );
  }
}

