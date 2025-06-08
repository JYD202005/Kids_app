import 'package:flutter/material.dart';
import '../animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import '../logic/life_point.dart'; // Agrega este import
//Puntos Locales no de la clase
class MemoramaScreen extends StatefulWidget {
  const MemoramaScreen({super.key});

  @override
  State<MemoramaScreen> createState() => _MemoramaScreenState();
}

class _MemoramaScreenState extends State<MemoramaScreen> {
  // Pares de icono y texto
  final List<_Pair> _pairs = [
    _Pair(icon: '🏠', label: 'Casa'),
    _Pair(icon: '🐶', label: 'Perro'),
    _Pair(icon: '🌟', label: 'Estrella'),
    _Pair(icon: '🍰', label: 'Pastel'),
    _Pair(icon: '❤️', label: 'Amor'),
    _Pair(icon: '☀️', label: 'Sol'),
  ];

  late List<_CardModel> _cards;
  int? _selectedIndex1;
  int? _selectedIndex2;
  bool _wait = false;
  int _points = 0;

  late LifePointManager _lifeManager; // Nueva instancia

  bool _showingPairs = true; // NUEVO: indica si se están mostrando los pares

  static const List<Color> _titleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  // Colores para las tarjetas (puedes agregar más si tienes más pares)
  static const List<Color> _cardColors = [
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
  ];

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
    _generateCards();
  }

  void _generateCards() async {
    final List<_CardModel> cards = [];
    for (final pair in _pairs) {
      cards.add(_CardModel(content: pair.icon, isIcon: true, pairKey: pair.label));
      cards.add(_CardModel(content: pair.label, isIcon: false, pairKey: pair.label));
    }
    cards.shuffle();
    _cards = cards;
    _lifeManager.reset();

    // Mostrar todos los pares boca arriba al inicio
    setState(() {
      for (var card in _cards) {
        card.isFlipped = true;
      }
      _showingPairs = true;
    });

    // Espera 2 segundos y voltea todas las cartas
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      for (var card in _cards) {
        card.isFlipped = false;
      }
      _showingPairs = false;
    });
  }

  void _onCardTap(int index) async {
    if (_wait || _cards[index].isFlipped || _cards[index].isMatched || _showingPairs) return;

    await _playClick();

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_selectedIndex1 == null) {
      _selectedIndex1 = index;
    } else {
      _selectedIndex2 = index;
      _wait = true;

      await Future.delayed(const Duration(milliseconds: 800));

      final card1 = _cards[_selectedIndex1!];
      final card2 = _cards[_selectedIndex2!];

      if (card1.pairKey == card2.pairKey && card1.isIcon != card2.isIcon) {
        card1.isMatched = true;
        card2.isMatched = true;
        _lifeManager.addPoint(); // Suma punto

        await _playCorrect();

        if (_cards.every((c) => c.isMatched)) {
          await Future.delayed(const Duration(milliseconds: 600));
          await _playWin();
          CelebrationOverlay.show(context, win: true);
          _showEndDialog(won: true);
        }
      } else {
        // --- SONIDO DE ERROR ---
        await _playError();
        card1.isFlipped = false;
        card2.isFlipped = false;
        _lifeManager.loseLife(); // Pierde vida

        if (_lifeManager.isGameOver) {
          await _playError();
          CelebrationOverlay.show(context, win: false);
          _showEndDialog(won: false);
        }
      }

      _selectedIndex1 = null;
      _selectedIndex2 = null;
      _wait = false;

      setState(() {});
    }
  }

  void _showEndDialog({required bool won}) {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _pairs.length,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won ? '¡Felicidades!' : '¡Inténtalo de nuevo!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: won ? Colors.amber : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(won ? '🎉' : '💔', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            StarRow(stars),
          ],
        ),
        content: Text(
          won
              ? '¡Completaste el memorama!\n\nPuntaje: ${_lifeManager.points} ⭐'
              : 'Te quedaste sin vidas.\n\nPuntaje: ${_lifeManager.points} ⭐',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar de nuevo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _generateCards();
              });
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Salir',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _playClick() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/click.mp3'));
  }

  Future<void> _playError() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/error.mp3'));
  }

  Future<void> _playCorrect() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/bien.mp3'));
  }

  Future<void> _playWin() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/ganador.mp3'));
  }

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
                  // Barra superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.lightBlue,
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("🧠", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título colorido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Text(
                        'MEMO'[i],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _titleColors[i],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Puntuación
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(_lifeManager.lives, (i) => const Icon(Icons.favorite, color: Colors.red, size: 28)),
                            ...List.generate(3 - _lifeManager.lives, (i) => const Icon(Icons.favorite_border, color: Colors.red, size: 28)),
                            const SizedBox(width: 18),
                            const Icon(Icons.star, color: Colors.amber, size: 28),
                            const SizedBox(width: 6),
                            Text(
                              'Puntos: ${_lifeManager.points}',
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
                    ),
                  ),
                  // Grid del memorama
                  Expanded(
                    child: GridView.builder(
                      itemCount: _cards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        final cardColor =
                            _cardColors[index % _cardColors.length];
                        return FlipCard(
                          flipped: card.isFlipped || card.isMatched,
                          onTap: () => _onCardTap(index),
                          front: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: card.isIcon
                                  ? Text(card.content,
                                      style: const TextStyle(
                                          fontSize: 40, color: Colors.white))
                                  : Text(card.content,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                            ),
                          ),
                          back: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.help_outline,
                                  color: Colors.white, size: 32),
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

// Modelo de par icono/texto
class _Pair {
  final String icon;
  final String label;
  const _Pair({required this.icon, required this.label});
}

// Modelo de tarjeta
class _CardModel {
  final String content; // icono o texto
  final bool isIcon;
  final String pairKey;
  bool isFlipped = false;
  bool isMatched = false;

  _CardModel({
    required this.content,
    required this.isIcon,
    required this.pairKey,
  });
}

class StarRow extends StatelessWidget {
  final int stars;
  const StarRow(this.stars, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 32,
        );
      }),
    );
  }
}
