import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math' as math;
import 'dart:ui'; // para usar Offset



final Map<String, List<Offset>> letterKeyPoints = {
  'A': [Offset(160, 60), Offset(100, 260), Offset(220, 260), Offset(160, 160)],
  'B': [Offset(100, 60), Offset(100, 160), Offset(100, 260), Offset(180, 60), Offset(180, 160), Offset(180, 260)],
  'C': [Offset(180, 60), Offset(100, 60), Offset(100, 160), Offset(100, 260), Offset(180, 260)],
  'D': [Offset(100, 60), Offset(100, 160), Offset(100, 260), Offset(180, 60), Offset(180, 260)],
  'E': [Offset(180, 60), Offset(100, 60), Offset(100, 160), Offset(100, 260), Offset(180, 260), Offset(140, 160)],
};



class LetterTracingGame extends StatefulWidget {
  const LetterTracingGame({super.key});
  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}



class _LetterTracingGameState extends State<LetterTracingGame> {
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E'];
  int _currentIndex = 0;
  late LifePointManager _lifeManager;
  final SignatureController _controller = SignatureController(penStrokeWidth: 5);
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _lifeManager = LifePointManager();
  }

  Future<void> _playSound(String name) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/$name.mp3'));
  }

  void _checkTracing() async {
    if (_controller.points.isEmpty) return;
    final bool isCorrect = _evaluateTracing();
    if (isCorrect) {
      await _playSound('correcto');
      _lifeManager.addPoint();
      if (_lifeManager.points == _letters.length) {
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
      _controller.clear();
      _currentIndex++;
    });
  }

  bool _evaluateTracing() {
    final points = _controller.points
        .where((p) => p != null)
        .map((p) => p!.offset)
        .toList();

    if (points.length < 30) return false;

    final currentLetter = _letters[_currentIndex];
    final keyPoints = letterKeyPoints[currentLetter];
    if (keyPoints == null) return false;

    const double minDistance = 30.0;
    int touchedPoints = 0;

    for (var keyPoint in keyPoints) {
      for (var point in points) {
        final dx = point.dx - keyPoint.dx;
        final dy = point.dy - keyPoint.dy;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance <= minDistance) {
          touchedPoints++;
          break;
        }
      }
    }

    double percentTouched = touchedPoints / keyPoints.length;
    return percentTouched > 0.7;
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
              won ? '¡Bien hecho!' : '¡Sigue practicando!',
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
              ? '¡Trazaste todas las letras!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _lifeManager.reset();
                _currentIndex = 0;
                _controller.clear();
              });
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Salir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
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
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _letters.length) return const SizedBox();
    final currentLetter = _letters[_currentIndex];
    final keyPoints = letterKeyPoints[currentLetter] ?? [];

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
              const SizedBox(height: 16),
              Text(
                'Trazar la letra:',
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                currentLetter,
                style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        currentLetter,
                        style: TextStyle(
                          fontSize: 200,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 320,
                    child: Signature(
                      controller: _controller,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Visualización de puntos clave
                  ...keyPoints.map((point) => Positioned(
                        left: point.dx,
                        top: point.dy,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Evaluar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _checkTracing,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Borrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => setState(() => _controller.clear()),
                  ),
                ],
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