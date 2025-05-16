import 'package:flutter/material.dart';
import 'package:kids_apps2/Views/columns/math_columns.dart';
import 'package:kids_apps2/Views/columns/read_columns.dart';
import 'animations/animations.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  Color _colorForLetter(String letter) {
    const colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    final code = letter.codeUnitAt(0);
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
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
                  // Barra superior con íconos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.red,
                        iconSize: 32,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note),
                        color: Colors.yellow,
                        iconSize: 32,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título principal
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(-2, -2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(2, -2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(2, 2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(-2, 2)),
                          Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(2, 2)),
                        ],
                      ),
                      children: [
                        TextSpan(text: 'LEER ', style: TextStyle(color: Colors.blue)),
                        TextSpan(text: 'y\n', style: TextStyle(color: Colors.green, fontSize: 34)),
                        TextSpan(text: 'SUMAR', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: '👇 ELIGE UNA ACTIVIDAD 👇',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9C27B0), // Morado
                        shadows: [
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(-2, -2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(2, -2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(2, 2)),
                          Shadow(blurRadius: 0, color: Colors.white, offset: Offset(-2, 2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Grid de actividades
                  Expanded(
                    child: Row(
                      children: [
                        // Columna izquierda: Lectura
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: ReadDataMain.tiles.map((tile) {
                              return BouncingCard(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf2e9dc),
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      const BoxShadow(
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
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        tile['icon'] ?? 'assets/images/readcol.png',
                                        width: 70,
                                        height: 70,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'ComicNeue',
                                            ),
                                            children: (tile['text'] ?? 'ABC').split('').map((char) {
                                              return TextSpan(
                                                text: char,
                                                style: TextStyle(
                                                  color: _colorForLetter(char),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Columna derecha: Matemáticas
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: MathDataMain.tiles.map((tile) {
                              return BouncingCard(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf2e9dc),
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      const BoxShadow(
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          textAlign: TextAlign.right,
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'ComicNeue',
                                            ),
                                            children: (tile['text'] ?? '123').split('').map((char) {
                                              return TextSpan(
                                                text: char,
                                                style: TextStyle(
                                                  color: _colorForLetter(char),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Image.asset(
                                        tile['icon'] ?? 'assets/images/mathcol.png',
                                        width: 70,
                                        height: 70,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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