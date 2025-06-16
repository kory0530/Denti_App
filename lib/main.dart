import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard.dart';
import 'screens/directory.dart';
import 'screens/appointments.dart';
import 'screens/self_diagnosis.dart';
import 'screens/reminders.dart';
import 'screens/blog.dart';
import 'screens/article_create_page.dart';
import 'screens/recommendations_screen.dart'; // 🔹 Agregamos la importación

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://prxzgxtfvmlerivasdyn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeHpneHRmdm1sZXJpdmFzZHluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5OTc3OTcsImV4cCI6MjA2NDU3Mzc5N30.14W-OUpmD-FND8fJC2C4Zw5fVWTU_DX7WEQtDv8vuGE',
  );

  runApp(const DentiApp());
}

class DentiApp extends StatelessWidget {
  const DentiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/directory': (context) => const DentistListScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/self_diagnosis': (context) => const SelfDiagnosisScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/blog': (context) => const BlogScreen(),
        '/article_create': (context) => const ArticleCreateScreen(),
        '/recommendations': (context) => const RecommendationsScreen(), // 🔹 Agregamos la ruta
      },
    );
  }
}
