import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../services/article_service.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Blog de Salud Dental',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/article_create');
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A56F9)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
              ),
            );
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(
              child: Text(
                'No hay artículos disponibles',
                style:
                    TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
              ),
            );
          }
          return MasonryGridView.count(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                color: const Color(0xFF2A2A3D),
                margin: const EdgeInsets.all(6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article['image_url'] != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            article['image_url'],
                            fit: BoxFit.cover,
                            height: (150 + (index % 3) * 30).toDouble(),
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: (150 + (index % 3) * 30).toDouble(),
                                color: Colors.grey[800],
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(color: Color(0xFF6A56F9)),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: (150 + (index % 3) * 30).toDouble(),
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.white54, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          article['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                        child: Text(
                          (article['content'] ?? '').length > 100
                              ? '${article['content'].substring(0, 100)}...'
                              : (article['content'] ?? ''),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text(
          article['title'] ?? '',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article['image_url'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6A56F9)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white54, size: 50),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Text(
              article['title'] ?? '',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article['content'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Montserrat',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
