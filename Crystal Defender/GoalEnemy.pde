class GoalEnemy extends Enemy {

  GoalEnemy(float x, float y, float size, float speed) {
    super(x, y, size, speed, 2); // 2 hp troll-like

    ensureEnemySpritesLoaded();
    frames = goalEnemyFrames;     // troll walk frames
    frameDelay = 6;
  }

  void move(Goal goal, Player player) {
    // move toward the crystal goal
    float dx = goal.x - x;
    float dy = goal.y - y;
    float d = sqrt(dx*dx + dy*dy);
    if (d != 0) {
      x += (dx / d) * speed;
      y += (dy / d) * speed;
    }
  }
}
