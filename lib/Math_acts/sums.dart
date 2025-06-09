import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kids_apps2/Logins/guardadolocal.dart';
import 'package:kids_apps2/progress.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math';

class GuessTheSumScreen extends StatefulWidget {
  const GuessTheSumScreen({super.key});

  @override
  State<GuessTheSumScreen> createState() => _GuessTheSumScreenState();
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

class _GuessTheSumScreenState extends State<GuessTheSumScreen> {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  late LifePointManager _lifeManager;
  int _currentIndex = 0;
  late List<_SumItem> _items;
  List<int> _options = [];
  String userId = 'asereje'; // ⚠️ aquí debes poner el UID del usuario
  String gameLevelId = 'sums'; // por ejemplo este nombre de nivel
  final storage = CodigoLocalService();
  late ProgressService _progressService;
  void codigo() async {
    String codigo = await storage.obtenerCodigo() ?? '';
    setState(() {
      userId = codigo;
    });
  }

  @override
  void initState() {
    super.initState();
    codigo();
    _progressService = ProgressService();
    _lifeManager = LifePointManager();
    _items = _generateSumItems();
    int stars = StarSystem.calculateStars(
        points: _lifeManager.points, total: _items.length);
    _generateOptions();
  }

  List<_SumItem> _generateSumItems() {
    return List.generate(15, (_) {
      int a = _random.nextInt(10) + 1; // 1 - 10
      int b = _random.nextInt(10) + 1;
      return _SumItem(a: a, b: b);
    });
  }

  void _generateOptions() {
    final correct = _items[_currentIndex].result;
    final other1 = correct + _random.nextInt(5) + 1;
    final other2 = correct - (_random.nextInt(4) + 1);
    _options = [correct, other1, max(0, other2)];
    _options.shuffle();
  }

  Future<void> _playSound(String name) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/$name.mp3'));
  }

  void _onOptionTap(int selected) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final correct = _items[_currentIndex].result;
    if (selected == correct) {
      await _playSound('correcto');
      _lifeManager.addPoint();
      if (_lifeManager.points == _items.length) {
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
      _currentIndex = (_currentIndex + 1) % _items.length;
      _generateOptions();
    });
  }

  void _showEndDialog({required bool won}) async {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _items.length,
    );
    if (won) {
      // Guardamos el progreso SOLO si se ganó
      await _progressService.updateProgress(userId, gameLevelId);
    }

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar de nuevo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _lifeManager.reset();
                _items.shuffle();
                _currentIndex = 0;
                _generateOptions();
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

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                        ...List.generate(
                            _lifeManager.lives,
                            (i) => const Icon(Icons.favorite,
                                color: Colors.red, size: 28)),
                        ...List.generate(
                            3 - _lifeManager.lives,
                            (i) => const Icon(Icons.favorite_border,
                                color: Colors.red, size: 28)),
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
              const SizedBox(height: 24),
              // Emoji decorativo + suma
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BouncingCard(
                    child: Text(
                      '${item.a} + ${item.b}',
                      style: const TextStyle(
                          fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Opciones de respuestas
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _options.map((value) {
                  return ElevatedButton(
                    onPressed: () => _onOptionTap(value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.primaries[value % Colors.primaries.length],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      '$value',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
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

class _SumItem {
  final int a;
  final int b;
  int get result => a + b;

  _SumItem({required this.a, required this.b});
}
