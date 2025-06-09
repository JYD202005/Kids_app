import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';

class PronounceVowelsScreen extends StatefulWidget {
  final AudioPlayer? backgroundPlayer;

  const PronounceVowelsScreen({super.key, this.backgroundPlayer});

  @override
  State<PronounceVowelsScreen> createState() => _PronounceVowelsScreenState();
}

class _PronounceVowelsScreenState extends State<PronounceVowelsScreen> {
  static const List<String> _vowels = ['A', 'E', 'I', 'O', 'U'];
  static const List<Color> _buttonColors = [
    Color(0xFFFFB74D), // Naranja
    Color(0xFFF48FB1), // Rosa
    Color(0xFF9575CD), // Violeta
    Color(0xFF81D4FA), // Celeste
    Color(0xFFE57373), // Rojo
  ];
  static const List<String> _vowelWords = [
    'Avión',
    'Elefante',
    'Iglú',
    'Oso',
    'Uva',
  ];
  static const List<String> _vowelEmojis = [
    '✈️',
    '🐘',
    '🏠',
    '🐻',
    '🍇',
  ];

  AudioPlayer? _currentPlayer;
  int? _lastPlayedIndex;

  @override
  void initState() {
    super.initState();
    widget.backgroundPlayer?.stop();
  }

  @override
  void dispose() {
    _currentPlayer?.dispose();
    super.dispose();
  }

  Future<void> _playVowelSound(int index) async {
    await _currentPlayer?.stop();
    _currentPlayer = AudioPlayer();
    final lower = _vowels[index].toLowerCase();
    await _currentPlayer!.setVolume(1.0);
    await _currentPlayer!.play(AssetSource('sounds/$lower.mp3'));
    setState(() {
      _lastPlayedIndex = index;
    });
    // Opcional: resalta el botón por 1 segundo
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _lastPlayedIndex = null;
    });
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
                      const Text("🗣️", style: TextStyle(fontSize: 26)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título colorido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¡", style: TextStyle(fontSize: 28)),
                      ...List.generate(
                        5,
                        (i) => Text(
                          _vowels[i],
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _buttonColors[i],
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: _buttonColors[i].withOpacity(0.5),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text("!", style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Grid de botones de vocales
                  Expanded(
                    child: GridView.builder(
                      itemCount: _vowels.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200, // Máximo ancho de cada botón
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = _lastPlayedIndex == index;
                        return BouncingCard(
                          onTap: () => _playVowelSound(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _buttonColors[index].withOpacity(0.7)
                                  : _buttonColors[index],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected ? Colors.amber : Colors.black26,
                                width: isSelected ? 4 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _buttonColors[index].withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // <-- para centrar horizontalmente
                              mainAxisSize: MainAxisSize.min, // <-- importante!
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Borde negro
                                    Text(
                                      _vowels[index],
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 4
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    // Letra blanca encima
                                    Text(
                                      _vowels[index],
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _vowelEmojis[index],
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  // <-- le da adaptabilidad
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _vowelWords[index],
                                      style: const TextStyle(
                                        fontSize: 18, // no hace falta cambiarlo
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Pie de página divertido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_up,
                          color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "¡Toca una vocal para escuchar su sonido!",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
