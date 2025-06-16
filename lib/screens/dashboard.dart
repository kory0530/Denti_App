import 'package:flutter/material.dart';

// Importa tus pantallas reales
import 'directory.dart';
import 'appointments.dart';
import 'self_diagnosis.dart';
import 'reminders.dart';
import 'blog.dart';
import 'recommendations_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DentistListScreen(),    // '/directory'
    const AppointmentsScreen(),   // '/appointments'
    const SelfDiagnosisScreen(),  // '/self_diagnosis'
    const RemindersScreen(),      // '/reminders'
    const BlogScreen(),           // '/blog'
    const RecommendationsScreen(),// '/recommendations'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],  // Muestra pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed, // Para más de 3 items sin scroll
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Directorio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Diagnosticos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Autodiagnóstico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Recordatorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recomendaciones',
          ),
        ],
      ),
    );
  }
}


