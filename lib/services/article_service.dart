import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> fetchArticles() async {
  try {
    final data = await supabase
        .from('articles')
        .select()
        .order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  } catch (e) {
    throw Exception('Error al cargar artículos: $e');
  }
}

Future<void> createArticle(String title, String content) async {
  try {
    await supabase.from('articles').insert({
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    throw Exception('Error al crear artículo: $e');
  }
}



