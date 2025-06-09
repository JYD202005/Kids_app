import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener progreso actual
  Future<Map<String, dynamic>?> getProgress(String userId) async {
    final response = await _supabase
        .from('Progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  // Actualizar progreso para un nivel específico
  Future<void> updateProgress(String userId, String level) async {
    final progress = await getProgress(userId);

    Map<String, dynamic> timesPlayedMap = {};
    int currentPoints = 0;

    if (progress != null) {
      // Si ya existe progreso
      if (progress['times_played'] != null) {
        timesPlayedMap = Map<String, dynamic>.from(progress['times_played']);
      }
      if (progress['points'] != null) {
        currentPoints = progress['points'] as int;
      }
    }

    // Obtener veces jugadas en este nivel
    int timesPlayed =
        (timesPlayedMap[level] != null) ? (timesPlayedMap[level] as int) : 0;

    // Lógica de puntos
    int basePoints = 100;
    int penalty = (timesPlayed) * 10;
    int earnedPoints = (basePoints - penalty).clamp(10, basePoints);

    // Actualizamos valores
    timesPlayed += 1;
    currentPoints += earnedPoints;
    timesPlayedMap[level] = timesPlayed;

    if (progress == null) {
      // Si no existe, insertamos
      await _supabase.from('Progress').insert({
        'user_id': userId,
        'points': currentPoints,
        'times_played': timesPlayedMap,
      });
    } else {
      // Si existe, actualizamos
      await _supabase.from('Progress').update({
        'points': currentPoints,
        'times_played': timesPlayedMap,
      }).eq('user_id', userId);
    }
  }
}
