import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../logic/life_point.dart';
import '../animations/animations.dart';

class CountObjectsScreen extends StatefulWidget {
  const CountObjectsScreen({super.key});

  @override
  State<CountObjectsScreen> createState() => _CountObjectsScreenState();
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


class _CountObjectsScreenState extends State<CountObjectsScreen> {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  late LifePointManager _lifeManager;
  
  late List<int> _numbers; // lista de números del 1 al 10 en orden aleatorio
  int _currentIndex = 0;
  List<int> _options = [];

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
    _numbers = List.generate(10, (i) => i + 1)..shuffle(); // 1 al 10
    int stars = StarSystem.calculateStars(points: _lifeManager.points, total: _numbers.length);
    _generateOptions();
  }

  Future<void> _playSound(String name) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/$name.mp3'));
  }

  void _generateOptions() {
    final correct = _numbers[_currentIndex];
    final other1 = max(1, correct + _random.nextInt(3) - 1);
    final other2 = max(1, correct + _random.nextInt(5) - 2);

    _options = {correct, other1, other2}.toList();
    while (_options.length < 3) {
      _options.add(_random.nextInt(10) + 1);
      _options = _options.toSet().toList(); // evitar duplicados
    }
    _options.shuffle();
  }

  void _onOptionTap(int selected) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final correct = _numbers[_currentIndex];
    if (selected == correct) {
      await _playSound('correcto');
      _lifeManager.addPoint();
      if (_lifeManager.points == _numbers.length) {
        await _playSound('ganador');
        CelebrationOverlay.show(context, win: true);
        _showEndDialog(won: true);
        return;
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

    setState(() {
      _currentIndex = (_currentIndex + 1) % _numbers.length;
      _generateOptions();
    });

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
              ? '¡Completaste todas las sumas!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
                _numbers.shuffle();
                _currentIndex = 0;
                _generateOptions();
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
    final currentNumber = _numbers[_currentIndex];
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 32,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(_lifeManager.lives, (i) => const Icon(Icons.favorite, color: Colors.red)),
                    ...List.generate(3 - _lifeManager.lives, (i) => const Icon(Icons.favorite_border, color: Colors.red)),
                    const SizedBox(width: 20),
                    Text('Puntos: ${_lifeManager.points}',
                        style: const TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Imagen de los objetos
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  'assets/images/math/$currentNumber.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _options.map((value) {
                  return ElevatedButton(
                    onPressed: () => _onOptionTap(value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      '$value',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}