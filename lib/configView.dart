import 'package:flutter/material.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  // Simulación de progreso y puntos (puedes conectar esto con tu sistema real)
  int totalActivities = 10;
  int points = 6; // Cambia este valor para probar la barra de progreso

  @override
  Widget build(BuildContext context) {
    double progress = points / totalActivities;

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
                        '¡Tu progreso!',
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
                              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalActivities,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              index < points ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView(
                    children: [
                      _buildActivityTile(
                        icon: Icons.menu_book,
                        color: Colors.purpleAccent,
                        title: 'Lectura',
                        subtitle: 'Progreso en actividades de lectura',
                        progress: 0.7,
                      ),
                      _buildActivityTile(
                        icon: Icons.calculate,
                        color: Colors.blueAccent,
                        title: 'Matemáticas',
                        subtitle: 'Progreso en actividades de matemáticas',
                        progress: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, color: Colors.deepPurple.shade300, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      'Centro de control',
                      style: TextStyle(
                        fontSize: 22,
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