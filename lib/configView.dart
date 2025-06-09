import 'package:flutter/material.dart';
import 'package:kids_apps2/Logins/guardadolocal.dart';
import 'package:kids_apps2/progress.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final int totalGames = 13;
  final int maxAttemptsPerGame = 5;
  final int totalStarsDisplay = 10;

  int attemptsPlayed = 0;
  int points = 0;
  bool loading = true;

  final progressService = ProgressService();
  final storage = CodigoLocalService();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Ejemplo: suma de puntos reales (estrellas)
  Future<void> _loadProgress() async {
    // OJO: Cambia por tu método real de obtener el userId
    String userId = await storage.obtenerCodigo() ?? '';
    (); // tu método local

    final progress = await progressService.getProgress(userId);
    if (progress != null) {
      setState(() {
        points = progress['points'] ?? 0;
        // Suma todos los intentos de todos los juegos
        Map timesPlayedMap = progress['times_played'] ?? {};
        attemptsPlayed =
            timesPlayedMap.values.fold<int>(0, (a, b) => a + (b as int));
        loading = false;
      });
    } else {
      setState(() {
        points = 0;
        attemptsPlayed = 0;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAttempts = totalGames * maxAttemptsPerGame;
    double progress = attemptsPlayed / totalAttempts;
    if (progress > 1.0) progress = 1.0;
    int starsEarned = (progress * totalStarsDisplay).round();

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gifs/field3.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.lightBlue,
                    iconSize: 32,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 6),
                        Text(
                          'Puntos: $points',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            shadows: [
                              Shadow(
                                  blurRadius: 0,
                                  color: Colors.white,
                                  offset: Offset(-2, -2)),
                              Shadow(
                                  blurRadius: 0,
                                  color: Colors.white,
                                  offset: Offset(2, -2)),
                              Shadow(
                                  blurRadius: 0,
                                  color: Colors.white,
                                  offset: Offset(2, 2)),
                              Shadow(
                                  blurRadius: 0,
                                  color: Colors.white,
                                  offset: Offset(-2, 2)),
                              Shadow(
                                  blurRadius: 4,
                                  color: Colors.black45,
                                  offset: Offset(2, 2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.orangeAccent,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '¡Progreso del pequeño!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                          shadows: const [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.amber,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 32,
                            backgroundColor: Colors.deepPurple.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.amber,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events,
                                  color: Colors.amber.shade700, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // --- Estrellas responsivas ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final int totalStars = totalStarsDisplay;
                          const double starSpacing = 4;
                          double starSize =
                              ((totalWidth - (starSpacing * (totalStars - 1))) /
                                      totalStars)
                                  .clamp(12.0, 36.0);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              totalStars,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1.8),
                                child: Icon(
                                  index < starsEarned
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: starSize,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // --- Fin estrellas responsivas ---
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.orangeAccent,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'En caso de Error Contactar:',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'leerysumar@gmail.com',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'o al: +1 (704) 298-3910',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, color: Colors.blue, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      'Centro de control',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        shadows: const [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.amber,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required double progress,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 32),
          radius: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
        onTap: () {
          // Aquí puedes navegar a la sección correspondiente
        },
      ),
    );
  }
}
