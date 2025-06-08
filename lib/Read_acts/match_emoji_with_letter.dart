import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math';

class EmojiByLetterGame extends StatefulWidget {
  const EmojiByLetterGame({super.key});

  @override
  State<EmojiByLetterGame> createState() => _EmojiByLetterGameState();
}

class _EmojiItem {
  final String emoji;
  final String name;

  const _EmojiItem(this.emoji, this.name);
}

class _EmojiByLetterGameState extends State<EmojiByLetterGame> {
  final AudioPlayer _player = AudioPlayer();
  final List<_EmojiItem> _emojis = [
    _EmojiItem('🐶', 'PERRO'),
    _EmojiItem('🍎', 'MANZANA'),
    _EmojiItem('🐱', 'GATO'),
    _EmojiItem('🍌', 'BANANA'),
    _EmojiItem('🐰', 'CONEJO'),
    _EmojiItem('🚗', 'CARRO'),
    _EmojiItem('🐟', 'PEZ'),
    _EmojiItem('🍇', 'UVA'),
    _EmojiItem('🦁', 'LEON'),
    _EmojiItem('🌵', 'CACTUS'),
    _EmojiItem('🧀', 'QUESO'),
  ];

  final List<String> _letters = ['P', 'M', 'G', 'B', 'C', 'U', 'L','Q'];
  final List<_EmojiItem> _options = [];
  List<_EmojiItem> _correctAnswers = [];
  final Set<_EmojiItem> _selectedAnswers = {};
  late LifePointManager _lifeManager;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
    _setupRound();
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

  void _setupRound() {
    _selectedAnswers.clear();
    String currentLetter = _letters[_currentIndex];
    _correctAnswers =
        _emojis.where((e) => e.name.startsWith(currentLetter)).toList();

    _options
      ..clear()
      ..addAll(_correctAnswers);

    final extraOptions = (_emojis.toList()..shuffle())
        .where((e) => !_correctAnswers.contains(e))
        .take(4 - _correctAnswers.length)
        .toList();

    _options.addAll(extraOptions);
    _options.shuffle();

     _playLetter(currentLetter);

    setState(() {});
  }

  void _onEmojiTap(_EmojiItem tapped) async {
    if (_selectedAnswers.contains(tapped)) return;
    _selectedAnswers.add(tapped);

    final isCorrect = _correctAnswers.contains(tapped);
    if (isCorrect) {
      await _playSound('correcto');

      if (_selectedAnswers.containsAll(_correctAnswers)) {
        _lifeManager.addPoint();

          // Espera para permitir que se escuche el audio de "correcto"
          await Future.delayed(const Duration(milliseconds: 700));

        if (_lifeManager.points == _letters.length) {
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
      total: _letters.length,
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
              ? '¡Completaste todas las letras!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
    final currentLetter = _letters[_currentIndex];
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(_lifeManager.lives, (i) => const Icon(Icons.favorite, color: Colors.red)),
                    ...List.generate(3 - _lifeManager.lives, (i) => const Icon(Icons.favorite_border, color: Colors.red)),
                    const SizedBox(width: 24),
                    Text(
                      'Puntos: ${_lifeManager.points}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BouncingCard(
                    child: Text(
                      currentLetter,
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _options.map((emojiItem) {
                  final isSelected = _selectedAnswers.contains(emojiItem);
                  return GestureDetector(
                    onTap: () => _onEmojiTap(emojiItem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[300] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        emojiItem.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  );
                }).toList(),
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