import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';


class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  // Colores de los botones, uno para cada letra
  static const List<Color> _buttonColors = [
    Color(0xFFFFB74D), // Naranja
    Color(0xFFF48FB1), // Rosa
    Color(0xFF9575CD), // Violeta
    Color(0xFF81D4FA), // Celeste
    Color(0xFFE57373), // Rojo
    Color(0xFFAED581), // Verde
    Color(0xFFFFF176), // Amarillo
    Color(0xFFBA68C8), // Morado
    Color(0xFF4FC3F7), // Azul claro
    Color(0xFFFF8A65), // Naranja claro
    Color(0xFF81C784), // Verde claro
    Color(0xFFDCE775), // Lima
    Color(0xFFFFD54F), // Amarillo oscuro
    Color(0xFFA1887F), // Marrón claro
    Color(0xFF90A4AE), // Azul grisáceo
    Color(0xFFB0BEC5), // Gris azulado
    Color(0xFFB39DDB), // Lavanda
    Color(0xFF80CBC4), // Verde agua
    Color(0xFFB2DFDB), // Turquesa
    Color(0xFFFFCCBC), // Durazno
    Color(0xFFC5E1A5), // Verde pasto
    Color(0xFFFFF59D), // Amarillo pastel
    Color(0xFFE1BEE7), // Lila
    Color(0xFFB3E5FC), // Celeste pastel
    Color(0xFFFFAB91), // Salmón
    Color(0xFFDCEDC8), // Verde muy claro
  ];

  // Letras en los botones
  static const List<String> _letters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
  ];

  // Colores para el título "ABCDE"
  static const List<Color> _titleColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
  ];

  Future<void> _playLetterSound(String letter) async {
    final player = AudioPlayer();
    final lower = letter.toLowerCase();
    await player.setVolume(1.0);
    await player.play(AssetSource('sounds/$lower.mp3'));
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gifs/field3.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Barra superior con botón de regreso y emoji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.lightBlue,
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("🤓", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título "👇 A B C D E 👇" con colores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("👇", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      ...List.generate(
                        5,
                        (i) => Text(
                          String.fromCharCode(65 + i), // A B C D E
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _titleColors[i],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("👇", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid de botones de letras
                  Expanded(
                    child: GridView.builder(
                      itemCount: _letters.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Más columnas
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1, // Cards más compactos
                      ),
                      itemBuilder: (context, index) {
                        return BouncingCard(
                          key: UniqueKey(),
                          onTap: () => _playLetterSound(_letters[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _buttonColors[index % _buttonColors.length], // Repetir colores
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _letters[index],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
