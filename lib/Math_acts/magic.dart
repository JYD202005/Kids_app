import 'dart:math';
import 'package:flutter/material.dart';

class MagicSquareGame extends StatefulWidget {
  const MagicSquareGame({super.key});

  @override
  State<MagicSquareGame> createState() => _MagicSquareGameState();
}

class _MagicSquareGameState extends State<MagicSquareGame> {
  late MagicSquare magicSquare;
  List<int> availableNumbers = [];
  int moves = 0;
  bool isCompleted = false;
  String validationResult = '';
  bool _isReplacingNumber = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame({List<int>? numbers}) {
    final numList = List<int>.from(numbers ?? List.generate(9, (i) => i + 1));
    final gridSize = sqrt(numList.length).toInt();

    assert(
      gridSize * gridSize == numList.length,
      'La lista debe tener un número cuadrado de elementos.',
    );

    numList.shuffle();

    setState(() {
      magicSquare = MagicSquare(gridSize, List.from(numList));
      availableNumbers = List.from(numList);
      moves = 0;
      isCompleted = false;
      validationResult = '';
    });
  }

  void _verifySquare() {
    setState(() {
      validationResult = magicSquare.getVerificationStatus();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultado de verificación'),
          content: Text(
            validationResult,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el dialog
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  double _calculateGridSize(BuildContext context, BoxConstraints constraints) {
    double maxSize = 320.0; // <--- Cambiado de 450 a 320
    double minSize = 100.0; // <--- Tamaño mínimo
    double availableSize = min(
      constraints.maxWidth * 0.8,
      constraints.maxHeight * 0.8,
    );

    return availableSize.clamp(minSize, maxSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gifs/field3.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.lightBlue,
                      iconSize: 32,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.orange,
                        ),
                        onPressed: _startNewGame),
                    PopupMenuButton<List<int>>(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.tealAccent,
                      ),
                      onSelected: (numbers) {
                        _startNewGame(numbers: numbers);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: [1, 2, 3, 4, 5, 6, 7, 8, 9],
                          child: Text('1 al 9 (suma mágica 15)'),
                        ),
                        const PopupMenuItem(
                          value: [2, 4, 6, 8, 10, 12, 14, 16, 18],
                          child: Text('Pares del 2 al 18'),
                        ),
                        const PopupMenuItem(
                          value: [10, 11, 12, 13, 14, 15, 16, 17, 18],
                          child: Text('10 al 18'),
                        ),
                        const PopupMenuItem(
                          value: [5, 10, 15, 20, 25, 30, 35, 40, 45],
                          child: Text('Múltiplos de 5'),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
              Container(
                color: Colors.white.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Movimientos: $moves',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildMagicSquareColumnLabels(),
                  ],
                ),
              ),
              Expanded(
                // hace que el GridView se ajuste
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double gridSize =
                          _calculateGridSize(context, constraints);
                      return Container(
                        width: gridSize,
                        height: gridSize,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            final row = index ~/ 3;
                            final col = index % 3;
                            return _buildGridCell(row, col);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _verifySquare,
                label: const Text('Verificar', style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.manage_search, size: 28),
              ),
              const SizedBox(height: 10),
              Container(
                color: Colors.white.withOpacity(0.5),
                width: double.infinity,
                height: 35,
                child: Center(
                  child: Text(
                    'Números disponibles:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                // Esto permite que la lista de números sea scrollable si es necesario
                flex: 0,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: availableNumbers.map((number) {
                      return DragTarget<int>(
                        onWillAccept: (data) => true,
                        onAccept: (numberFromGrid) {
                          setState(() {
                            if (!availableNumbers.contains(numberFromGrid)) {
                              for (int r = 0; r < magicSquare.size; r++) {
                                for (int c = 0; c < magicSquare.size; c++) {
                                  if (magicSquare.grid[r][c] ==
                                      numberFromGrid) {
                                    magicSquare.grid[r][c] = null;
                                  }
                                }
                              }
                              moves++;
                            }
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Draggable<int>(
                            data: number,
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildDraggableCard(number),
                            ),
                            childWhenDragging: _buildDraggedPlaceholder(),
                            child: _buildDraggableCard(number),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildMagicSquareColumnLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(1, (col) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Constante mágica: ${magicSquare.magicConstant}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  Widget _buildGridCell(int row, int col) {
    final cellValue = magicSquare.grid[row][col];

    return DragTarget<int>(
      onWillAccept: (data) => true,
      onAccept: (number) {
        _isReplacingNumber = true;

        setState(() {
          if (availableNumbers.contains(number)) {
            if (cellValue != null) {
              availableNumbers.add(cellValue);
            }
            magicSquare.grid[row][col] = number;
            availableNumbers.remove(number);
            moves++;
          } else {
            // Quitar el número de la celda origen
            for (int r = 0; r < magicSquare.size; r++) {
              for (int c = 0; c < magicSquare.size; c++) {
                if (magicSquare.grid[r][c] == number) {
                  magicSquare.grid[r][c] = null;
                }
              }
            }

            // Si la celda tenía un número:
            if (cellValue != null) {
              int valor = magicSquare.grid[row][col] = number;
              print(valor);
              if (cellValue == valor) {
                print('resuelto');
                magicSquare.grid[row][col] = null;
                availableNumbers.add(cellValue);
                moves++;
              } else {
                print("→ Sustituyendo un número");

                magicSquare.grid[row][col] = null;
                magicSquare.grid[row][col] = number;
                moves++;
                availableNumbers.add(cellValue);
                print(cellValue);
              }
            } else {
              // CASO: celda vacía
              print("→ Movimiento normal a celda vacía");
              magicSquare.grid[row][col] = number;
              moves++;
            }
          }

          if (magicSquare.isMagicSquare()) {
            isCompleted = true;
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        Widget content = Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: candidateData.isNotEmpty
                ? Colors.greenAccent
                : cellValue == null
                    ? Colors.grey[200]
                    : Colors.primaries[cellValue! %
                        Colors.primaries.length], // <--- aquí está tu cambio
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                cellValue?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ← para que contraste con los colores
                ),
              ),
            ),
          ),
        );

        if (cellValue != null) {
          return Draggable<int>(
            data: cellValue,
            feedback: Material(
              color: Colors.transparent,
              child: _buildDraggableCard(cellValue),
            ),
            childWhenDragging: _buildDraggedPlaceholder(),
            child: content,
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                magicSquare.grid[row][col] = null;
                availableNumbers.add(cellValue);
                moves++;
                print('yo elimine');
              });
            },
            onDragCompleted: () {
              // Si el DragTarget acepta, no necesitas hacer nada aquí
            },
          );
        } else {
          return content;
        }
      },
    );
  }

  Widget _buildDraggableCard(int number) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors
            .primaries[number % Colors.primaries.length], // Aquí el cambio
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggedPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

extension SumIterable on Iterable<int> {
  int sum() => fold(0, (a, b) => a + b);
}

class MagicSquare {
  final int size;
  late final List<List<int?>> grid;
  final List<int> numbers;
  final int magicConstant;

  MagicSquare(this.size, this.numbers)
      : magicConstant = (numbers.reduce((a, b) => a + b)) ~/ size,
        assert(numbers.length == size * size) {
    grid = List.generate(size, (_) => List.filled(size, null));
  }

  bool isMagicSquare() {
    return getVerificationStatus() ==
        '¡Correcto! Todas las sumas son $magicConstant';
  }

  String getVerificationStatus() {
    List<String> errors = [];

    // Filas
    for (int row = 0; row < size; row++) {
      int sum = grid[row].whereType<int>().sum();
      bool isIncomplete = grid[row].contains(null);

      if (isIncomplete) {
        errors.add('Fila $row incompleta');
      } else if (sum != magicConstant) {
        errors.add('Fila $row suma: $sum');
      }
    }

    // Columnas
    for (int col = 0; col < size; col++) {
      int sum = grid.map((row) => row[col]).whereType<int>().sum();
      bool isIncomplete = grid.any((row) => row[col] == null);

      if (isIncomplete) {
        errors.add('Columna $col incompleta');
      } else if (sum != magicConstant) {
        errors.add('Columna $col suma: $sum');
      }
    }

    // Diagonal principal
    int mainDiagonalSum =
        List.generate(size, (i) => grid[i][i]).whereType<int>().sum();
    bool mainDiagonalIncomplete = List.generate(
      size,
      (i) => grid[i][i],
    ).contains(null);

    if (mainDiagonalIncomplete) {
      errors.add('Diagonal principal incompleta');
    } else if (mainDiagonalSum != magicConstant) {
      errors.add('Diagonal principal suma $mainDiagonalSum');
    }

    // Diagonal secundaria
    int secondaryDiagonalSum = List.generate(
      size,
      (i) => grid[i][size - 1 - i],
    ).whereType<int>().sum();
    bool secondaryDiagonalIncomplete = List.generate(
      size,
      (i) => grid[i][size - 1 - i],
    ).contains(null);

    if (secondaryDiagonalIncomplete) {
      errors.add('Diagonal secundaria incompleta');
    } else if (secondaryDiagonalSum != magicConstant) {
      errors.add('Diagonal secundaria suma $secondaryDiagonalSum');
    }

    return errors.isEmpty
        ? '¡Correcto! Todas las sumas son $magicConstant'
        : errors.join('\n');
  }
}
