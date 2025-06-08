import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';

class NumberWordGame extends StatefulWidget {
  const NumberWordGame({super.key});

  @override
  State<NumberWordGame> createState() => _NumberWordGameState();
}

class _NumberWordGameState extends State<NumberWordGame> {
  final AudioPlayer _player = AudioPlayer();
  final List<_NumberItem> _numbers = [
    _NumberItem(number: 1, word: 'UNO'),
    _NumberItem(number: 2, word: 'DOS'),
    _NumberItem(number: 3, word: 'TRES'),
    _NumberItem(number: 4, word: 'CUATRO'),
    _NumberItem(number: 5, word: 'CINCO'),
    _NumberItem(number: 6, word: 'SEIS'),
    _NumberItem(number: 7, word: 'SIETE'),
    _NumberItem(number: 8, word: 'OCHO'),
    _NumberItem(number: 9, word: 'NUEVE'),
    _NumberItem(number: 10, word: 'DIEZ'),
  ];

  int _currentIndex = 0;
  List<String> _letterPool = [];
  List<String?> _currentAnswer = [];
  List<bool> _usedLetters = [];
  late LifePointManager _lifeManager;

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
    _setupNewRound();
  }

  void _setupNewRound() {
    final word = _numbers[_currentIndex].word;
    _currentAnswer = List<String?>.filled(word.length, null);
    _letterPool = _generateLetterPool(word);
    _usedLetters = List<bool>.filled(_letterPool.length, false);
  }

  List<String> _generateLetterPool(String word) {
    List<String> pool = [];
    final Map<String, int> letterCount = {};

    for (var letter in word.split('')) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    letterCount.forEach((letter, count) {
      pool.addAll(List.generate(count, (_) => letter));
    });

    List<String> allLetters = List.generate(26, (i) => String.fromCharCode(65 + i));

    while (pool.length < 12) {
      final randomLetter = (allLetters..shuffle()).first;
      pool.add(randomLetter);
    }

    pool.shuffle();
    return pool;
  }

  void _onLetterSelected(int index) {
    for (int i = 0; i < _currentAnswer.length; i++) {
      if (_currentAnswer[i] == null) {
        setState(() {
          _currentAnswer[i] = _letterPool[index];
          _usedLetters[index] = true;
        });
        break;
      }
    }
    _checkIfComplete();
  }

  void _removeLastLetter() {
    for (int i = _currentAnswer.length - 1; i >= 0; i--) {
      if (_currentAnswer[i] != null) {
        String letterToRemove = _currentAnswer[i]!;

        int index = _letterPool.asMap().entries.firstWhere(
          (entry) => entry.value == letterToRemove && _usedLetters[entry.key],
          orElse: () => MapEntry(-1, ''),
        ).key;

        if (index != -1) {
          setState(() {
            _currentAnswer[i] = null;
            _usedLetters[index] = false;
          });
        }
        break;
      }
    }
  }

  void _checkIfComplete() async {
    if (_currentAnswer.contains(null)) return;

    final word = _numbers[_currentIndex].word;
    final userAnswer = _currentAnswer.join();

    if (userAnswer == word) {
      await _player.play(AssetSource('sounds/correcto.mp3'));
      _lifeManager.addPoint();
      _nextRoundOrWin();
    } else {
      await _player.play(AssetSource('sounds/error.mp3'));
      _lifeManager.loseLife();
      if (_lifeManager.isGameOver) {
        await _player.play(AssetSource('sounds/perder.mp3'));
        if (!mounted) return;
        CelebrationOverlay.show(context, win: false);
        _showEndDialog(won: false);
      } else {
        setState(() {
          _currentAnswer = List<String?>.filled(word.length, null);
          _letterPool = _generateLetterPool(word);
          _usedLetters = List<bool>.filled(_letterPool.length, false);
        });
      }
    }
  }

  void _nextRoundOrWin() async {
    if (_currentIndex + 1 >= _numbers.length) {
      await _player.play(AssetSource('sounds/ganador.mp3'));
      if (!mounted) return;
      CelebrationOverlay.show(context, win: true);
      _showEndDialog(won: true);
    } else {
      setState(() {
        _currentIndex++;
        _setupNewRound();
      });
    }
  }

  void _showEndDialog({required bool won}) {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _numbers.length,
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
              ? '¡Completaste todas las palabras!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar de nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _lifeManager.reset();
                _currentIndex = 0;
                _setupNewRound();
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
    final number = _numbers[_currentIndex];

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
                ],
              ),
              const SizedBox(height: 16),
              // Título colorido
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ESCRIBE EL NÚMERO',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[400],
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de vidas y puntos centrada y bonita
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
              const SizedBox(height: 32),
              Text(
                number.number.toString(),
                style: const TextStyle(
                  fontSize: 72,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _currentAnswer.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentAnswer[index] ?? '_',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.backspace, color: Colors.red, size: 36),
                onPressed: _removeLastLetter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_letterPool.length, (index) {
                      final letter = _letterPool[index];
                      final isUsed = _usedLetters[index];
                      return ElevatedButton(
                        onPressed: isUsed ? null : () => _onLetterSelected(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUsed
                              ? Colors.grey.withOpacity(0.4)
                              : Colors.primaries[letter.codeUnitAt(0) % Colors.primaries.length],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberItem {
  final int number;
  final String word;
  _NumberItem({required this.number, required this.word});
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