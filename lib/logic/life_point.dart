class LifePointManager {
  /// Calcula las vidas y puntos del jugador.
  int lives;
  int points;

  LifePointManager({this.lives = 3, this.points = 0});

  void reset({int lives = 3}) {
    this.lives = lives;
    points = 0;
  }

  void addPoint() {
    points++;
  }

  void loseLife() {
    lives--;
  }

  bool get isGameOver => lives <= 0;
}

class StarSystem {
  static int calculateStars({required int points, required int total}) {
    final ratio = points / total;
    if (ratio >= 1.0) return 3;       // 100% → 3 estrellas
    if (ratio >= 0.66) return 2;      // >66%  → 2 estrellas
    if (ratio >= 0.33) return 1;      // >33%  → 1 estrella
    return 0;                         // menos → 0 estrellas
  }
}

