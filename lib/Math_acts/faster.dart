import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  int _lives = 3;
  final AudioPlayer _player = AudioPlayer();

  // AGREGADO: controlador para el campo de texto
  final TextEditingController _controller = TextEditingController();

  void _startGame() {
    _score = 0;
    _lives = 3;
    _timeLeft = 30;
    _generateNewSum();
    _gameStarted = true;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft == 0 || _lives == 0) {
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
      await _player.play(AssetSource('sounds/correcto.mp3'));
      _generateNewSum();
    } else {
      setState(() {
        _lives = (_lives > 0) ? _lives - 1 : 0;
      });
      await _player.play(AssetSource('sounds/error.mp3'));
    }

    // LIMPIAR campo de texto
    setState(() {
      _input = '';
      _controller.clear(); // ← aquí lo vacía visualmente
    });
  }

  void _showEndDialog() async {
    if (_lives == 0) {
      await _player.play(AssetSource('sounds/perder.mp3'));
    } else {
      await _player.play(AssetSource('sounds/ganador.mp3'));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          _lives == 0 ? '¡Has perdido!' : '¡Tiempo terminado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _lives == 0 ? Colors.redAccent : Colors.amber,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Puntuación: $_score ⭐',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < _score ~/ 3 ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                );
              }),
            ),
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

  @override
  void initState() {
    super.initState();
    _generateNewSum();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _controller.dispose(); // ← liberar el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              _lives,
                              (i) => const Icon(Icons.favorite,
                                  color: Colors.red, size: 28)),
                          ...List.generate(
                              3 - _lives,
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
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Tiempo: $_timeLeft s',
                      style: const TextStyle(fontSize: 28, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¿Cuánto es $_num1 + $_num2?',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller, // ← aquí agregas el controller
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _input = value,
                      onSubmitted: _checkAnswer,
                      decoration: const InputDecoration(
                        hintText: 'Tu respuesta',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!_gameStarted && _timeLeft == 30)
                      ElevatedButton(
                        onPressed: _startGame,
                        child: Text(
                          _gameStarted ? 'Reiniciar' : 'Comenzar',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
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
