import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../animations/animations.dart';

class NumbersScreen extends StatefulWidget {
  final AudioPlayer? backgroundPlayer;

  const NumbersScreen({super.key, this.backgroundPlayer});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  // Colores de los botones
  static const List<Color> _buttonColors = [
    Color(0xFFFFB74D), // Naranja
    Color(0xFFF48FB1), // Rosa
    Color(0xFF9575CD), // Violeta
    Color(0xFF81D4FA), // Celeste
    Color(0xFFE57373), // Rojo
    Color(0xFFAED581), // Verde
    Color(0xFFFFF176), // Amarillo
    Color(0xFFBA68C8), // Morado
    Color(0xFF4FC3F7), // Azul claro
    Color(0xFFFF8A65), // Naranja claro
    Color(0xFF81C784), // Verde claro
    Color(0xFFDCE775), // Lima
    Color(0xFFFFD54F), // Amarillo oscuro
    Color(0xFFA1887F), // Marrón claro
    Color(0xFF90A4AE), // Azul grisáceo
    Color(0xFFB0BEC5), // Gris azulado
    Color(0xFFB39DDB), // Lavanda
    Color(0xFF80CBC4), // Verde agua
    Color(0xFFB2DFDB), // Turquesa
    Color(0xFFFFCCBC), // Durazno
    Color(0xFFC5E1A5), // Verde pasto
    Color(0xFFFFF59D), // Amarillo pastel
    Color(0xFFE1BEE7), // Lila
    Color(0xFFB3E5FC), // Celeste pastel
    Color(0xFFFFAB91), // Salmón
    Color(0xFFDCEDC8), // Verde muy claro
  ];

  // Números a mostrar
  static const List<String> _numbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '40',
    '50',
    '60',
    '70',
    '80',
    '90',
    '100'
  ];

  // Colores para el título "1 2 3 4 5"
  static const List<Color> _titleColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
  ];

  AudioPlayer? _currentPlayer;

  @override
  void initState() {
    super.initState();
    // Detener la música de fondo si se pasó el player
    widget.backgroundPlayer?.stop();
  }

  @override
  void dispose() {
    _currentPlayer?.dispose();
    super.dispose();
  }

  Future<void> _playNumberSound(String number) async {
    // Detener cualquier sonido anterior
    await _currentPlayer?.stop();
    _currentPlayer = AudioPlayer();
    await _currentPlayer!.setVolume(1.0);

    // El archivo de sonido debe estar en assets/sounds/number_1.mp3, number_2.mp3, etc.
    await _currentPlayer!
        .play(AssetSource('sounds_numbers/number_$number.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado
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
                  // Barra superior con botón de regreso y emoji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.lightBlue,
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("🔢", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título "👇 1 2 3 4 5 👇" con colores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("👇", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      ...List.generate(
                        5,
                        (i) => Text(
                          (i + 1).toString(), // 1 2 3 4 5
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _titleColors[i],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("👇", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid de botones de números
                  Expanded(
                    child: GridView.builder(
                      itemCount: _numbers.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Más columnas
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1, // Cards más compactos
                      ),
                      itemBuilder: (context, index) {
                        return BouncingCard(
                          onTap: () => _playNumberSound(_numbers[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _buttonColors[index %
                                  _buttonColors.length], // Repetir colores
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Borde negro
                                  Text(
                                    _numbers[index],
                                    style: TextStyle(
                                      fontSize: _numbers[index].length > 2
                                          ? 22
                                          : 28, // Tamaño más pequeño para números de 3 dígitos
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.black,
                                    ),
                                  ),
                                  // Número blanco encima
                                  Text(
                                    _numbers[index],
                                    style: TextStyle(
                                      fontSize:
                                          _numbers[index].length > 2 ? 22 : 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
