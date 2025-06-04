import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';
import '../logic/life_point.dart';

class GuessTheLetterScreen extends StatefulWidget {
  const GuessTheLetterScreen({super.key});

  @override
  State<GuessTheLetterScreen> createState() => _GuessTheLetterScreenState();
}

class _GuessTheLetterScreenState extends State<GuessTheLetterScreen> {
  final AudioPlayer _player = AudioPlayer();
  int _currentIndex = 0;
  late List<_GameItem> _items;
  List<String> _options = [];
  late LifePointManager _lifeManager;

  @override
  void initState() {
    super.initState();
    _items = _generateGameItems();
    _generateOptions();
    _lifeManager = LifePointManager();
  }

  List<_GameItem> _generateGameItems() {
    return [
      _GameItem(emoji: '🍎', word: 'Manzana'),
      _GameItem(emoji: '🎂', word: 'Pastel'),
      _GameItem(emoji: '🚗', word: 'Auto'),      // A
      _GameItem(emoji: '🎲', word: 'Dado'),
      _GameItem(emoji: '🏫', word: 'Escuela'),   // E
      _GameItem(emoji: '🌸', word: 'Flor'),
      _GameItem(emoji: '🍦', word: 'Helado'),
      _GameItem(emoji: '💡', word: 'Lámpara'),
      _GameItem(emoji: '🧊', word: 'Iglú'),      // I
      _GameItem(emoji: '☁️', word: 'Nube'),
      _GameItem(emoji: '🐶', word: 'Perro'),
      _GameItem(emoji: '🎵', word: 'Musica'),
      _GameItem(emoji: '☀️', word: 'Sol'),
      _GameItem(emoji: '🍇', word: 'Uva'),       // U
      _GameItem(emoji: '📚', word: 'Libro'),
      _GameItem(emoji: '🐞', word: 'Bicho'),
      _GameItem(emoji: '🏠', word: 'Casa'),
      _GameItem(emoji: '🚩', word: 'Bandera'),
      _GameItem(emoji: '🐱', word: 'Gato'),
      _GameItem(emoji: '🍃', word: 'Hoja'),
      _GameItem(emoji: '🛶', word: 'Kayak'),
      _GameItem(emoji: '🌺', word: 'Loto'),
      _GameItem(emoji: '🏍️', word: 'Moto'),
      _GameItem(emoji: '🪑', word: 'Silla'),
      _GameItem(emoji: '😊', word: 'Feliz'),
      _GameItem(emoji: '🗺️', word: 'Mapa'),
      _GameItem(emoji: '🛥️', word: 'Yate'),
      _GameItem(emoji: '⏰', word: 'Alarma'),    // A
      _GameItem(emoji: '🚀', word: 'Cohete'),
      _GameItem(emoji: '🔑', word: 'Llave'),
      _GameItem(emoji: '🐻', word: 'Oso'),      // O
    ];
  }

  void _generateOptions() {
    final correctLetter = _items[_currentIndex].word[0].toUpperCase();
    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    letters.remove(correctLetter);
    letters.shuffle();

    _options = [correctLetter, letters[0], letters[1]];
    _options.shuffle();
  }

  Future<void> _playError() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/error.mp3'));
  }

  Future<void> _playCorrect() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/correcto.mp3'));
  }

  Future<void> _playLose() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/perder.mp3'));
  }

  Future<void> _playWin() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/ganador.mp3'));
  }

  Future<void> _playLetter(String letter) async {
    await _player.stop();
    final file = 'sounds/${letter.toLowerCase()}.mp3';
    await _player.play(AssetSource(file));
  }

  void _onLetterTap(String selectedLetter) async {
    await _playLetter(selectedLetter); // Reproduce el sonido de la letra
    await Future.delayed(const Duration(milliseconds: 750)); // Espera a que suene

    final correct = _items[_currentIndex].word[0].toUpperCase();
    if (selectedLetter == correct) {
      await _playCorrect();
      _lifeManager.addPoint();
      if (_lifeManager.points == _items.length) {
        await _playWin();
        CelebrationOverlay.show(context, win: true);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Column(
              children: const [
                Text('¡Felicidades!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber)),
                SizedBox(height: 8),
                Text('🏆', style: TextStyle(fontSize: 48)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    Icon(Icons.star, color: Colors.amber, size: 32),
                  ],
                ),
              ],
            ),
            content: Text(
              '¡Adivinaste todas las palabras!\n\nPuntaje: ${_lifeManager.points} ⭐',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _lifeManager.reset();
                    _currentIndex = 0;
                    _generateOptions();
                  });
                },
                child: const Text('Jugar de nuevo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialog
                  Navigator.of(context).pop(); // Sale al ReadView
                },
                child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }
    } else {
      await _playError();
      _lifeManager.loseLife();
      if (_lifeManager.isGameOver) {
        // Perdiste
        await _playLose();
        CelebrationOverlay.show(context, win: false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Column(
              children: const [
                Text('¡Descalificado!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red)),
                SizedBox(height: 8),
                Text('😢', style: TextStyle(fontSize: 48)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken, color: Colors.red, size: 32),
                    Icon(Icons.heart_broken, color: Colors.red, size: 32),
                    Icon(Icons.heart_broken, color: Colors.red, size: 32),
                  ],
                ),
              ],
            ),
            content: Text(
              '¡Te quedaste sin vidas!\n\nPuntaje: ${_lifeManager.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _lifeManager.reset();
                    _currentIndex = 0;
                    _generateOptions();
                  });
                },
                child: const Text('Intentar de nuevo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialog
                  Navigator.of(context).pop(); // Sale al ReadView
                },
                child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }
    }
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
      _generateOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];
    final missingWord = "_${item.word.substring(1)}";

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
              // Vidas y puntos en la parte superior
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
              const SizedBox(height: 8),
              // Emoji animado bouncy
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BouncingCard(
                    child: Text(
                      item.emoji,
                      style: TextStyle(
                        fontSize: 90,
                        color: Colors.primaries[_currentIndex % Colors.primaries.length],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Palabra incompleta
              Text(
                missingWord,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Opciones de letras
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _options.map((letter) {
                  return ElevatedButton(
                    onPressed: () => _onLetterTap(letter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.primaries[letter.codeUnitAt(0) % Colors.primaries.length],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      letter,
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

class _GameItem {
  final String emoji;
  final String word;
  _GameItem({required this.emoji, required this.word});
}
