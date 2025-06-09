import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kids_apps2/Logins/guardadolocal.dart';
import 'package:kids_apps2/progress.dart';
import '../logic/life_point.dart';
import '../animations/animations.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  late int _num1;
  late int _num2;
  int _score = 0;
  int _timeLeft = 30;
  String _input = '';
  Timer? _timer;
  bool _gameStarted = false;
  late LifePointManager _lifeManager;
  final AudioPlayer _player = AudioPlayer();

  final TextEditingController _controller = TextEditingController();

  static const int maxScore = 15;

  void _startGame() {
    _score = 0;
    _lifeManager.reset();
    _timeLeft = 30;
    _generateNewSum();
    _gameStarted = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0 || _lifeManager.isGameOver) {
        timer.cancel();
        setState(() {
          _gameStarted = false;
        });
        _showEndDialog();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
    setState(() {});
  }

  void _generateNewSum() {
    setState(() {
      _num1 = _random.nextInt(10) + 1;
      _num2 = _random.nextInt(10) + 1;
    });
  }

  void _checkAnswer(String value) async {
    if (!_gameStarted) return;

    final answer = int.tryParse(value);
    if (answer == (_num1 + _num2)) {
      _score++;
      _timeLeft += 3;
      if (_timeLeft > 60) _timeLeft = 60;
      await _player.play(AssetSource('sounds/correcto.mp3'));
      _generateNewSum();
    } else {
      await _player.play(AssetSource('sounds/error.mp3'));
      _lifeManager.loseLife();
      _timeLeft -= 3;
      if (_timeLeft < 0) _timeLeft = 0;
    }

    setState(() {
      _input = '';
      _controller.clear();
    });
  }

  void _showEndDialog() async {
    if (_lifeManager.isGameOver) {
      await _player.play(AssetSource('sounds/perder.mp3'));
    } else {
      await _player.play(AssetSource('sounds/ganador.mp3'));
      await _progressService.updateProgress(userId, gameLevelId);
    }

    final stars = StarSystem.calculateStars(points: _score, total: maxScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          _lifeManager.isGameOver ? '¡Has perdido!' : '¡Tiempo terminado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _lifeManager.isGameOver ? Colors.redAccent : Colors.amber,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Puntuación: $_score ⭐',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            StarRow(stars),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar de nuevo'),
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
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
            label: const Text('Salir'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String userId = 'asereje'; // ⚠️ aquí debes poner el UID del usuario
  String gameLevelId = 'sums_in_time'; // por ejemplo este nombre de nivel
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
    _generateNewSum();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = StarSystem.calculateStars(points: _score, total: maxScore);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/gifs/field3.gif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.lightBlue,
                      iconSize: 32,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _startGame(),
                      color: Colors.lightBlue,
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
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
                            '$_score',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 18),
                          StarRow(stars),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.deepPurple, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.amberAccent,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.red, size: 32),
                          const SizedBox(width: 10),
                          Text(
                            'Tiempo: $_timeLeft s',
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        child: Text(
                          '¿Cuánto es $_num1 + $_num2?',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _input = value,
                      onSubmitted: _checkAnswer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Tu respuesta',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple, width: 2),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!_gameStarted && _timeLeft == 30)
                      ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: Text(
                          _gameStarted ? 'Reiniciar' : 'Comenzar',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sistema de estrellas reutilizable
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
