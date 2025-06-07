import 'package:flutter/material.dart';
import 'package:kids_apps2/Logins/Principal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
  await Supabase.initialize(
    url: 'https://ludaskqazclnfyavtpkk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1ZGFza3FhemNsbmZ5YXZ0cGtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwOTI5ODUsImV4cCI6MjA2NDY2ODk4NX0.E8WxKdv4jbQNZV1k9Rj6SOthsgCwlYEwAmKZfwH6zEQ',
  );
  doWhenWindowReady(() async {
    WidgetsFlutterBinding.ensureInitialized();

    const minWidth = 360.0; // Ancho mínimo para móviles pequeños
    const minHeight = 500.0; // Alto mínimo para contenido básico

    appWindow.minSize = Size(minWidth, minHeight); // Tamaño mínimo
    appWindow.maxSize = Size(1980, 1080); // Tamaño máximo (opcional)
    appWindow.size = Size(
      max(minWidth, 850.0), // Usa 850px o el mínimo (lo que sea mayor)
      max(minHeight, 730.0), // Usa 730px o el mínimo
    );
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Inicio(),
    );
  }
}
