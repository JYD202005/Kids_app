import 'package:flutter/material.dart';
import 'package:kids_apps2/Math_acts/guess_the_hands.dart';
import 'package:kids_apps2/Math_acts/guess_the_num.dart';
import 'package:kids_apps2/Math_acts/numbers.dart';
import 'package:kids_apps2/Math_acts/scrible_the_number.dart';
import 'package:kids_apps2/Math_acts/sums.dart';
import 'animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';

class MathView extends StatelessWidget {
  const MathView({super.key});

  // Lista de imágenes para las tarjetas (estructura simple)
  static const List<String> _images = [
    'assets/images/math/globo-uno-r.png',
    'assets/images/math/0-100-r.png',
    'assets/images/math/3_manzanas-r.png',
    'assets/images/math/manos-num-r.png',
    'assets/images/math/escribir_1-r.png',
    'assets/images/math/7_dedos-r.png',
  ];

  // Método para reproducir el sonido de selección
  Future<void> _playSeleccionar() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/seleccionar.mp3'));
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
                      const Text("🧮", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título central "1 = UNO" colorido con flechas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("👇", style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text("1",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                      Text(" = ",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Text("U",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      Text("N",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      Text("O",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text("👇", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid de tarjetas animadas
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: _images.map((img) {
                        return BouncingCard(
                          key: ValueKey(img),
                          onTap: () async {
                            await _playSeleccionar(); // <-- Reproduce el sonido antes de navegar
                            if (img == 'assets/images/math/manos-num-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GuessTheSumScreen()),
                              );
                            }
                            if (img == 'assets/images/math/3_manzanas-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CountObjectsScreen()),
                              );
                            }
                            if (img == 'assets/images/math/7_dedos-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GuessTheHandsScreen()),
                              );
                            }
                            if (img == 'assets/images/math/escribir_1-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NumberWordGame()),
                              );
                            }
                            if (img == 'assets/images/math/globo-uno-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NumbersScreen()),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf2e9dc),
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.orangeAccent,
                                  spreadRadius: 2,
                                  blurRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 12,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Transform.scale(
                                  scale:
                                      4.5, // Ajusta este valor para hacer la imagen más grande
                                  child:
                                      Image.asset(img, width: 70, height: 70),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
