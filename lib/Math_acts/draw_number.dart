import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math' as math;
import 'dart:ui'; // para usar Offset

final Map<String, List<Offset>> numberKeyPoints = {
  // Ajustes para el número 1:
  '1': [
    Offset(0.3, 0.37), // Arriba centro
    Offset(0.6, 0.50), // Centro
    Offset(0.6, 0.78), // Abajo centro
  ],
  // Ajustes para el número 2:
  '2': [
    Offset(0.25, 0.32), // Arriba izquierda
    Offset(0.75, 0.32), // Arriba derecha
    Offset(0.75, 0.55), // Centro derecha
    Offset(0.25, 0.78), // Abajo izquierda
    Offset(0.75, 0.78), // Abajo derecha
  ],
  // Ajustes para el número 3:
  '3': [
    Offset(0.25, 0.32), // Arriba izquierda
    Offset(0.75, 0.32), // Arriba derecha
    Offset(0.75, 0.55), // Centro derecha
    Offset(0.25, 0.78), // Abajo izquierda
    Offset(0.75, 0.78), // Abajo derecha
  ],
  // Ajustes para el número 4:
  '4': [
    Offset(0.25, 0.55), // Centro izquierda
    Offset(0.75, 0.55), // Centro derecha
    Offset(0.7, 0.32),  // Arriba centro
    Offset(0.7, 0.78),  // Abajo centro
  ],
  // Ajustes para el número 5:
  '5': [
    Offset(0.75, 0.32), // Arriba derecha
    Offset(0.25, 0.32), // Arriba izquierda
    Offset(0.25, 0.55), // Centro izquierda
    Offset(0.75, 0.75), // Abajo derecha
    Offset(0.25, 0.78), // Abajo izquierda
  ],
};

class NumberTracingGame extends StatefulWidget {
  const NumberTracingGame({super.key});
  @override
  State<NumberTracingGame> createState() => _NumberTracingGameState();
}

class _NumberTracingGameState extends State<NumberTracingGame> {
  final List<String> _numbers = ['1', '2', '3', '4', '5'];
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
      if (_lifeManager.points == _numbers.length) {
        await _playSound('ganador');
        CelebrationOverlay.show(context, win: true);
        _showEndDialog(won: true);
        return;
      }
      setState(() {
        _controller.clear();
        if (_currentIndex < _numbers.length - 1) {
          _currentIndex++;
        }
      });
    } else {
      await _playSound('error');
      _lifeManager.loseLife();
      if (_lifeManager.isGameOver) {
        await _playSound('perder');
        CelebrationOverlay.show(context, win: false);
        _showEndDialog(won: false);
        return;
      }
      setState(() {
        _controller.clear();
        // No incrementa _currentIndex, repite el mismo número
      });
    }
  }

  bool _evaluateTracing() {
    final points = _controller.points
        .where((p) => p != null)
        .map((p) => p!.offset)
        .toList();

    if (points.length < 30) return false;

    final currentNumber = _numbers[_currentIndex];
    final keyPoints = numberKeyPoints[currentNumber];
    if (keyPoints == null) return false;

    // Tamaño del canvas y fuente (debe coincidir con los usados en build)
    final double canvasSize = 320;
    final double fontSize = 200;

    // Calcula el tamaño real del número
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentNumber,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final numberWidth = textPainter.width;
    final numberHeight = textPainter.height;

    // Offset del número en el canvas
    final numberOffset = Offset(
      (canvasSize - numberWidth) / 2,
      (canvasSize - numberHeight) / 2,
    );

    // Convierte los puntos del trazo a coordenadas relativas (0..1) respecto al número
    List<Offset> relativePoints = points.map((p) {
      final local = p - numberOffset;
      return Offset(
        (local.dx / numberWidth).clamp(0.0, 1.0),
        (local.dy / numberHeight).clamp(0.0, 1.0),
      );
    }).toList();

    // Ajusta el radio de detección (proporcional al tamaño del número)
    const double minDistance = 0.10; // 10% del ancho/alto del número
    int touchedPoints = 0;

    for (var keyPoint in keyPoints) {
      for (var point in relativePoints) {
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
              ? '¡Trazaste todos los números!\n\nPuntaje: ${_lifeManager.points} ⭐'
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
    if (_currentIndex >= _numbers.length) return const SizedBox();
    final currentNumber = _numbers[_currentIndex];
    final keyPoints = numberKeyPoints[currentNumber] ?? [];

    // Tamaño del canvas y fuente
    final double canvasSize = 320;
    final double fontSize = 200;

    // Usa TextPainter para calcular el tamaño real del número
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentNumber,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final numberWidth = textPainter.width;
    final numberHeight = textPainter.height;

    // Centra el número en el canvas
    final numberOffset = Offset(
      (canvasSize - numberWidth) / 2,
      (canvasSize - numberHeight) / 2,
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trazar el número:',
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                currentNumber,
                style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: canvasSize,
                    height: canvasSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        currentNumber,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: canvasSize,
                    height: canvasSize,
                    child: Signature(
                      controller: _controller,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Los puntos clave ya no se muestran visualmente
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