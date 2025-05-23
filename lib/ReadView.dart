import 'package:flutter/material.dart';
import 'animations/animations.dart';
import 'acts/leters.dart'; // <-- Importa NumbersScreen
import 'acts/memory.dart';     // <-- Importa MemoryScreen

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  // Lista de imágenes para las tarjetas
  static const List<String> _images = [
    'assets/images/read/A-a-r.png',
    'assets/images/read/A_de_avion-r.png',
    'assets/images/read/escribir_A-r.png',
    'assets/images/read/globo-abc-r.png', // Este es el que quieres detectar
    'assets/images/read/B_de_bebe-r.png',
    'assets/images/read/Cuadros_letras-r.png',
  ];

  // Colores para las letras del título
  static const List<Color> _titleColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
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
                  // Barra superior con solo botón de regreso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.lightBlue,
                          iconSize: 32,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text("🐵", style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Título central "ABCDE" colorido con flechas y emoji
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
                      const SizedBox(width: 8),
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
                          key: UniqueKey(),
                          onTap: () {
                            if (img == 'assets/images/read/globo-abc-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NumbersScreen()),
                              );
                            } else if (img == 'assets/images/read/Cuadros_letras-r.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MemoramaScreen()),
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
                                  scale: 4.5, // Ajusta este valor para hacer la imagen más grande
                                  child: Image.asset(img, width: 70, height: 70),
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
