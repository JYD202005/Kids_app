import 'package:flutter/material.dart';
import '../animations/animations.dart';

class MemoramaScreen extends StatefulWidget {
  const MemoramaScreen({super.key});

  @override
  State<MemoramaScreen> createState() => _MemoramaScreenState();
}

class _MemoramaScreenState extends State<MemoramaScreen> {
  // Pares de icono y texto
  final List<_Pair> _pairs = [
    _Pair(icon: '🏠', label: 'casa'),
    _Pair(icon: '🐶', label: 'perro'),
    _Pair(icon: '🌟', label: 'estrella'),
    _Pair(icon: '🍰', label: 'pastel'),
    _Pair(icon: '❤️', label: 'amor'),
    _Pair(icon: '☀️', label: 'sol'),
  ];

  late List<_CardModel> _cards;
  int? _selectedIndex1;
  int? _selectedIndex2;
  bool _wait = false;

  static const List<Color> _titleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  // Colores para las tarjetas (puedes agregar más si tienes más pares)
  static const List<Color> _cardColors = [
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
  ];

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() {
    // Por cada par, crea una tarjeta de icono y una de texto
    final List<_CardModel> cards = [];
    for (final pair in _pairs) {
      cards.add(_CardModel(content: pair.icon, isIcon: true, pairKey: pair.label));
      cards.add(_CardModel(content: pair.label, isIcon: false, pairKey: pair.label));
    }
    cards.shuffle();
    _cards = cards;
  }

  void _onCardTap(int index) async {
    if (_wait || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_selectedIndex1 == null) {
      _selectedIndex1 = index;
    } else {
      _selectedIndex2 = index;
      _wait = true;

      await Future.delayed(const Duration(milliseconds: 800));

      final card1 = _cards[_selectedIndex1!];
      final card2 = _cards[_selectedIndex2!];

      // Son pareja si tienen el mismo pairKey y uno es icono y el otro texto
      if (card1.pairKey == card2.pairKey && card1.isIcon != card2.isIcon) {
        card1.isMatched = true;
        card2.isMatched = true;
      } else {
        card1.isFlipped = false;
        card2.isFlipped = false;
      }

      _selectedIndex1 = null;
      _selectedIndex2 = null;
      _wait = false;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
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
                  // Barra superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.lightBlue,
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("🧠", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título colorido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Text(
                        'MEMO'[i],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _titleColors[i],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Grid del memorama
                  Expanded(
                    child: GridView.builder(
                      itemCount: _cards.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        // Asigna un color diferente a cada tarjeta usando el índice
                        final cardColor = _cardColors[index % _cardColors.length];
                        return BouncingCard(
                          key: UniqueKey(),
                          onTap: () => _onCardTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              color: card.isFlipped || card.isMatched
                                  ? cardColor
                                  : Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: card.isFlipped || card.isMatched
                                ? Center(
                                    child: card.isIcon
                                        ? Text(
                                            card.content,
                                            style: const TextStyle(fontSize: 40),
                                          )
                                        : Text(
                                            card.content,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // Cambia aquí el color del texto
                                            ),
                                          ),
                                  )
                                : const Center(
                                    child: Icon(Icons.help_outline, color: Colors.white, size: 32),
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

// Modelo de par icono/texto
class _Pair {
  final String icon;
  final String label;
  const _Pair({required this.icon, required this.label});
}

// Modelo de tarjeta
class _CardModel {
  final String content; // icono o texto
  final bool isIcon;
  final String pairKey;
  bool isFlipped;
  bool isMatched;

  _CardModel({
    required this.content,
    required this.isIcon,
    required this.pairKey,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
