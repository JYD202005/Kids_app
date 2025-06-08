// music.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackgroundMusicManager {
  static AudioPlayer? _player;
  static bool _isPlaying = false;
  static bool _isDisposed = true;

// Método para limpieza segura con reintentos
  static Future<void> _safeDispose() async {
    for (int i = 0; i < 3; i++) {
      try {
        await _player?.stop();
        await _player?.release();
        await _player?.dispose();
        _player = null;
        _isPlaying = false;
        _isDisposed = true;
        await Future.delayed(
            Duration(milliseconds: 100 * (i + 1))); // Removido 'const'
        break;
      } catch (e) {
        debugPrint('Intento $i: Error en dispose: $e');
        if (i == 2) rethrow;
      }
    }
  }

  // Detener música forzosamente
  static Future<void> forceStop() async {
    await _safeDispose();
  }

  // Iniciar música con manejo de errores robusto
  static Future<void> start() async {
    await forceStop(); // Limpieza completa antes de iniciar

    try {
      _player = AudioPlayer()
        ..setReleaseMode(ReleaseMode.loop)
        ..setVolume(0.3);

      await _player!.play(AssetSource('sounds/background_music.mp3'));
      _isPlaying = true;
      _isDisposed = false;
    } catch (e) {
      debugPrint('Error al iniciar música: $e');
      await forceStop();
      throw e;
    }
  }

  // Alternar reproducción
  static Future<void> toggle() async {
    if (_isDisposed) return;

    try {
      if (_isPlaying) {
        await _player?.pause();
      } else {
        await _player?.resume();
      }
      _isPlaying = !_isPlaying;
    } catch (e) {
      debugPrint('Error en toggle: $e');
      await forceStop();
    }
  }

  // Limpieza al cerrar la app
  static Future<void> dispose() async {
    await _safeDispose();
  }
}
