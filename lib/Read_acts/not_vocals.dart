import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math';

class NotVowelsGame extends StatefulWidget {
  const NotVowelsGame({super.key});

  @override
  State<NotVowelsGame> createState() => _NotVowelsGameState();
}

class _NotVowelsGameState extends State<NotVowelsGame> {
  final AudioPlayer _player = AudioPlayer();
  final List<String> _allLetters = [
    'A', 'B', 'C', 'E', 'I', 'L', 'O', 'P', 'U', 'M', 'G', 'D', 'F', 'H', 'J', 'K', 'N', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'
  ];
  final List<String> _vowels = ['A', 'E', 'I', 'O', 'U'];
  final Random _random = Random();

  late List<String> _currentLetters;
  late List<String> _notVowels;
  final Set<String> _selected = {};
  late LifePointManager _lifeManager;
  int _currentIndex = 0;
  int _rounds = 5;

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
    _setupRound();
    // Reproducir audio al entrar
    Future.delayed(const Duration(milliseconds: 400), () {
      _player.play(AssetSource('sounds/Cual de estas letras es una vocal.mp3'));
    });
  }

  void _setupRound() {
    _selected.clear();
    // Selecciona 5 letras aleatorias, siempre al menos 2 no vocales y 2 vocales
    List<String> consonants = _allLetters.where((l) => !_vowels.contains(l)).toList();
    List<String> vowels = _vowels.toList();

    consonants.shuffle(_random);
    vowels.shuffle(_random);

    List<String> roundLetters = [
      ...consonants.take(2),
      ...vowels.take(3),
    ];
    roundLetters.shuffle(_random);

    _currentLetters = roundLetters;
    _notVowels = roundLetters.where((l) => !_vowels.contains(l)).toList();

    setState(() {});
  }

  Future<void> _playSound(String name) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/$name.mp3'));
  }

  Future<void> _playLetter(String letter) async {
    await _player.stop();
    final file = 'sounds/${letter.toLowerCase()}.mp3';
    await _player.play(AssetSource(file));
  }

  void _onLetterTap(String letter) async {
    if (_selected.contains(letter)) return;
    _selected.add(letter);

    final isCorrect = !_vowels.contains(letter);
    if (isCorrect) {
      await _playSound('correcto');
      if (_selected.where((l) => !_vowels.contains(l)).length == _notVowels.length) {
        _lifeManager.addPoint();
        await Future.delayed(const Duration(milliseconds: 700));
        if (_lifeManager.points == _rounds) {
          await _playSound('ganador');
          CelebrationOverlay.show(context, win: true);
          _showEndDialog(won: true);
          return;
        } else {
          setState(() => _currentIndex++);
          _setupRound();
        }
      }
    } else {
      await _playSound('error');
      _lifeManager.loseLife();
      if (_lifeManager.isGameOver) {
        await _playSound('perder');
        CelebrationOverlay.show(context, win: false);
        _showEndDialog(won: false);
        return;
      }
    }
    setState(() {});
  }

  void _showEndDialog({required bool won}) {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _rounds,
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
              ? '¡Encontraste todas las letras que no son vocales!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar de nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _lifeManager.reset();
                _currentIndex = 0;
                _setupRound();
              });
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Salir', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _rounds,
    );
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
                ],
              ),
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
                        const SizedBox(width: 18),
                        StarRow(stars),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: const [
                      Text(
                        "¿Cuáles de estas letras NO son vocales?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Icon(Icons.hearing, color: Colors.orange, size: 32),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: _currentLetters.map((letter) {
                  final isSelected = _selected.contains(letter);
                  final isCorrect = !_vowels.contains(letter);
                  return GestureDetector(
                    onTap: () {
                      _playLetter(letter);
                      _onLetterTap(letter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorrect ? Colors.greenAccent.shade100 : Colors.redAccent.shade100)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.deepPurple,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? (isCorrect
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    : Colors.redAccent.withOpacity(0.2))
                                : Colors.deepPurple.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.volume_up, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "¡Toca una letra para escuchar su sonido!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
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