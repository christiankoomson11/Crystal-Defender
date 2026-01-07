class ChaserEnemy extends Enemy {

  float zigFreq = 0.18;
  float zigAmp  = 18;

  ChaserEnemy(float x, float y, float size, float speed) {
    super(x, y, size, speed, 1); // 1 hp bat-like

    ensureEnemySpritesLoaded();
    frames = chaserEnemyFrames;   // bat frames
    frameDelay = 3;
  }

  void move(Goal goal, Player player) {
    // chase the player
    float dx = player.x - x;
    float dy = player.y - y;
    float d = sqrt(dx*dx + dy*dy);
    if (d != 0) {
      x += (dx / d) * speed;
      y += (dy / d) * speed;
    }

    // zig-zag wobble
    y += sin(frameCount * zigFreq) * (zigAmp / 60.0);
  }
}
