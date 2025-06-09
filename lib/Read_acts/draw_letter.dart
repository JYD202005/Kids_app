import 'package:flutter/material.dart';
import 'package:kids_apps2/progress.dart';
import 'package:signature/signature.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';
import 'dart:math' as math;
import 'dart:ui'; // para usar Offset
import 'package:kids_apps2/Logins/guardadolocal.dart';

final Map<String, List<Offset>> letterKeyPoints = {
  // Ajustes para la letra A:
  'A': [
    Offset(0.5, 0.30),
    Offset(0.18, 0.78),
    Offset(0.82, 0.78),
    Offset(0.5, 0.63),
  ],
  // Ajustes para la letra B:
  'B': [
    Offset(0.25, 0.31),
    Offset(0.75, 0.31),
    Offset(0.25, 0.55),
    Offset(0.75, 0.55),
    Offset(0.25, 0.75),
    Offset(0.75, 0.75),
  ],
  // Ajustes para la letra C:
  'C': [
    Offset(0.75, 0.42),
    Offset(0.25, 0.36),
    Offset(0.25, 0.55),
    Offset(0.25, 0.73),
    Offset(0.75, 0.76),
  ],
  // Ajustes para la letra D:
  'D': [
    Offset(0.25, 0.35),
    Offset(0.25, 0.55),
    Offset(0.25, 0.80),
    Offset(0.75, 0.35),
    Offset(0.75, 0.75),
  ],
  // Ajustes para la letra E:
  'E': [
    Offset(0.75, 0.32), // Arriba derecha (bajado un buen cacho)
    Offset(0.25, 0.32), // Arriba izquierda (bajado un buen cacho)
    Offset(0.25, 0.55),
    Offset(0.25, 0.78), // Abajo izquierda (subido un poquito)
    Offset(0.75, 0.78), // Abajo derecha (subido un poquito)
    Offset(0.5, 0.55),
  ],
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
  final SignatureController _controller =
      SignatureController(penStrokeWidth: 5);
  final AudioPlayer _player = AudioPlayer();
  late ProgressService _progressService;
  String userId = 'asereje'; // ⚠️ aquí debes poner el UID del usuario
  String gameLevelId =
      'letter_tracing_game'; // por ejemplo este nombre de nivel
  final storage = CodigoLocalService();

  @override
  void initState() {
    super.initState();
    codigo();
    _lifeManager = LifePointManager();
    _progressService = ProgressService();
  }

  void codigo() async {
    String codigo = await storage.obtenerCodigo() ?? '';
    setState(() {
      userId = codigo;
    });
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
      setState(() {
        _controller.clear();
        if (_currentIndex < _letters.length - 1) {
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
        // No incrementa _currentIndex, repite la misma letra
      });
    }
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

    // Tamaño del canvas y fuente (debe coincidir con los usados en build)
    final double canvasSize = 320;
    final double fontSize = 200;

    // Calcula el tamaño real de la letra
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentLetter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final letterWidth = textPainter.width;
    final letterHeight = textPainter.height;

    // Offset de la letra en el canvas
    final letterOffset = Offset(
      (canvasSize - letterWidth) / 2,
      (canvasSize - letterHeight) / 2,
    );

    // Convierte los puntos del trazo a coordenadas relativas (0..1) respecto a la letra
    List<Offset> relativePoints = points.map((p) {
      final local = p - letterOffset;
      return Offset(
        (local.dx / letterWidth).clamp(0.0, 1.0),
        (local.dy / letterHeight).clamp(0.0, 1.0),
      );
    }).toList();

    // Ajusta el radio de detección (proporcional al tamaño de la letra)
    const double minDistance = 0.10; // 10% del ancho/alto de la letra
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

  void _showEndDialog({required bool won}) async {
    final stars = StarSystem.calculateStars(
      points: _lifeManager.points,
      total: _letters.length,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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

    // Tamaño del canvas y fuente
    final double canvasSize = 320;
    final double fontSize = 200;

    // Usa TextPainter para calcular el tamaño real de la letra
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentLetter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final letterWidth = textPainter.width;
    final letterHeight = textPainter.height;

    // Centra la letra en el canvas
    final letterOffset = Offset(
      (canvasSize - letterWidth) / 2,
      (canvasSize - letterHeight) / 2,
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
              const SizedBox(height: 16),
              Text(
                'Trazar la letra:',
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                currentLetter,
                style: const TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
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
                        currentLetter,
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
                  // ...keyPoints.map((point) { ... }) eliminado
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Evaluar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _checkTracing,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Borrar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
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
