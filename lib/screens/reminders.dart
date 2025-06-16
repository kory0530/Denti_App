import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// ignore: library_prefixes
import 'package:timezone/data/latest.dart' as tzData;
import 'package:logger/logger.dart';

final logger = Logger();

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<Map<String, dynamic>> _reminders = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleReminder(BuildContext context) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final timeString = _timeController.text.trim();

    if (title.isEmpty || description.isEmpty || timeString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      final dateTime = DateTime.parse(timeString);
      if (dateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora seleccionada ya ha pasado')),
        );
        return;
      }

      final scheduledNotificationDateTime = tz.TZDateTime.from(dateTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        _reminders.length,
        title,
        description,
        scheduledNotificationDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'denti_reminders',
            'Recordatorios Denti',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      setState(() {
        _reminders.add({
          'title': title,
          'description': description,
          'time': dateTime,
        });
      });

      _titleController.clear();
      _descriptionController.clear();
      _timeController.clear();

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio programado con éxito')),
      );
    } catch (e) {
      logger.e('Error al programar el recordatorio: $e');
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al programar el recordatorio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Montserrat',
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF2A2A3D),
      labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Recordatorios de Higiene Bucal',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                  decoration: inputDecoration.copyWith(labelText: 'Título del Recordatorio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                  decoration: inputDecoration.copyWith(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _timeController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Hora (YYYY-MM-DD HH:MM)',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _scheduleReminder(context),
                  icon: const Icon(Icons.alarm, color: Colors.white),
                  label: const Text('Programar Recordatorio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 97, 167), // azul moderno
                    foregroundColor: Colors.white, // texto blanco
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Recordatorios Programados:', style: titleStyle),
                const SizedBox(height: 12),
                Expanded(
                  child: _reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay recordatorios programados',
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return Card(
                              color: const Color(0xFF2A2A3D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  reminder['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${reminder['description']} \n${reminder['time']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
