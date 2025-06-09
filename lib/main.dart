import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kids_apps2/Logins/Principal.dart';
import 'package:kids_apps2/logic/music.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:math';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundMusicManager.forceStop();
  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://ludaskqazclnfyavtpkk.supabase.co/',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1ZGFza3FhemNsbmZ5YXZ0cGtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwOTI5ODUsImV4cCI6MjA2NDY2ODk4NX0.E8WxKdv4jbQNZV1k9Rj6SOthsgCwlYEwAmKZfwH6zEQ',
  );

  if (Platform.isWindows) {
    // Configuración de ventana
    doWhenWindowReady(() {
      const minWidth = 360.0;
      const minHeight = 500.0;

      appWindow.minSize = Size(minWidth, minHeight);
      appWindow.maxSize = Size(1980, 1080);
      appWindow.size = Size(
        max(minWidth, 850.0),
        max(minHeight, 730.0),
      );
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Inicio(),
    );
  }
}
