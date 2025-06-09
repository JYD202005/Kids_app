import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kids_apps2/MathView%202.dart';
import 'package:kids_apps2/ReadView%202.dart';
import 'package:kids_apps2/Views/columns/math_columns.dart';
import 'package:kids_apps2/Views/columns/read_columns.dart';
import 'package:kids_apps2/ReadView.dart';
import 'package:kids_apps2/MathView.dart';
import 'package:kids_apps2/configView.dart';
import 'package:kids_apps2/logic/music.dart';
import 'animations/animations.dart';
import 'dart:math';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with WidgetsBindingObserver {
  final BackgroundMusicManager _musicManager = BackgroundMusicManager();
  final AudioPlayer _fxPlayer = AudioPlayer(); // Solo para efectos
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initMusic();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initMusic() async {
    try {
      await BackgroundMusicManager.start();
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('No se pudo iniciar la música: $e');
    }
  }

  Future<void> _toggleMusica() async {
    await BackgroundMusicManager.toggle();
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    BackgroundMusicManager.dispose();
    _fxPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _playSeleccionar() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0);
      await _fxPlayer.play(AssetSource('sounds/seleccionar.mp3'));
    } catch (e) {
      print('yo tambien fallo :D__$e');
    }
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  Color _colorForLetter(String letter) {
    const colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    final code = letter.codeUnitAt(0);
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gifs/field3.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Barra superior con íconos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.red,
                        iconSize: 32,
                        onPressed: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              final rnd = Random();
                              final a = rnd.nextInt(8) + 2; // 2 a 9
                              final b = rnd.nextInt(8) + 2; // 2 a 9
                              final TextEditingController controller =
                                  TextEditingController();
                              String? errorText;

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: Colors.amber[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      side: const BorderSide(color: Colors.deepPurple, width: 2),
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(Icons.lock, color: Colors.deepPurple, size: 32),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Filtro parental',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Responde la multiplicación para continuar:',
                                          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 18),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade100,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.deepPurple, width: 2),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.orangeAccent,
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$a',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                '×',
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '$b',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                '= ?',
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            hintText: 'Respuesta',
                                            errorText: errorText,
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Colors.deepPurple),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                                            ),
                                          ),
                                          onChanged: (_) {
                                            if (errorText != null) {
                                              setState(() => errorText = null);
                                            }
                                          },
                                          onSubmitted: (_) {},
                                        ),
                                      ],
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                        label: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check, color: Colors.white),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        ),
                                        label: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          final answer = int.tryParse(controller.text.trim());
                                          if (answer == a * b) {
                                            Navigator.of(context).pop(true);
                                          } else {
                                            setState(() {
                                              errorText = 'Respuesta incorrecta';
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          if (result == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ConfigView()),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.music_note : Icons.music_off,
                          color: Colors.yellow,
                        ),
                        iconSize: 32,
                        onPressed: _toggleMusica,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título principal
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
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
                      children: [
                        TextSpan(
                            text: 'LEER ',
                            style: TextStyle(color: Colors.blue)),
                        TextSpan(
                            text: 'y\n',
                            style:
                                TextStyle(color: Colors.green, fontSize: 34)),
                        TextSpan(
                            text: 'SUMAR', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: '👇 ELIGE UNA ACTIVIDAD 👇',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9C27B0),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Grid de actividades
                  Flexible(
                    child: Column(
                      children: [
                        // Lectura y Matemáticas
                        Row(
                          children: [
                            // Columna izquierda: Lectura
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: ReadDataMain.tiles
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final tile = entry.value;

                                  return BouncingCard(
                                    key: UniqueKey(),
                                    onTap: () async {
                                      await _playSeleccionar();
                                      await Future.delayed(
                                          const Duration(milliseconds: 250));
                                      if (index == 0) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LettersScreen()),
                                        );
                                        setState(() {});
                                      }
                                      if (index == 1) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LettersScreen2()),
                                        );
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFf2e9dc),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          const BoxShadow(
                                              color: Colors.orangeAccent,
                                              spreadRadius: 2),
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 12,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            tile['icon'] ??
                                                'assets/images/readcol.png',
                                            width: 70,
                                            height: 70,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ComicNeue',
                                                ),
                                                children:
                                                    (tile['text'] ?? 'ABC')
                                                        .split('')
                                                        .map((char) {
                                                  return TextSpan(
                                                    text: char,
                                                    style: TextStyle(
                                                        color: _colorForLetter(
                                                            char)),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Columna derecha: Matemáticas
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: MathDataMain.tiles
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final tile = entry.value;

                                  return BouncingCard(
                                    key: UniqueKey(),
                                    onTap: () async {
                                      await _playSeleccionar();
                                      if (index == 0) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MathView()),
                                        );
                                        setState(() {});
                                      }
                                      if (index == 1) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MathViewdos()),
                                        );
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFf2e9dc),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          const BoxShadow(
                                              color: Colors.orangeAccent,
                                              spreadRadius: 2),
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 12,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: RichText(
                                              textAlign: TextAlign.right,
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ComicNeue',
                                                ),
                                                children:
                                                    (tile['text'] ?? '123')
                                                        .split('')
                                                        .map((char) {
                                                  return TextSpan(
                                                    text: char,
                                                    style: TextStyle(
                                                        color: _colorForLetter(
                                                            char)),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Image.asset(
                                            tile['icon'] ??
                                                'assets/images/mathcol.png',
                                            width: 70,
                                            height: 70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Columna central (debajo)
                        Center(
                          child: BouncingCard(
                            key: UniqueKey(),
                            onTap: () async {
                              await _playSeleccionar();
                              // Acción del botón central
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  const BoxShadow(
                                      color: Colors.orangeAccent,
                                      spreadRadius: 2),
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/bonuscol.png',
                                    width: 70,
                                    height: 70,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'BONUS',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'ComicNeue',
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
