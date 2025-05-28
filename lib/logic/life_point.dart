class LifePointManager {
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