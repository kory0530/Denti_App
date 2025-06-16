import 'package:supabase_flutter/supabase_flutter.dart';

// Reemplaza estos valores con tus credenciales de Supabase
const supabaseUrl = 'https://prxzgxtfvmlerivasdyn.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeHpneHRmdm1sZXJpdmFzZHluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5OTc3OTcsImV4cCI6MjA2NDU3Mzc5N30.14W-OUpmD-FND8fJC2C4Zw5fVWTU_DX7WEQtDv8vuGE';

// ✅ Singleton para usar en toda la app
final supabase = Supabase.instance.client;
