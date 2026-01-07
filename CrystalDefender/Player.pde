class Player {

  // =========================
  // Animations (single sheet)
  // =========================
 PImage[] idleFrames;
 PImage[] runFrames;
 PImage[] attackFrames;
 PImage[] hitFrames;
 PImage[] deathFrames;

  // Core fields
  float x, y;
  float radius;
  int maxLives;
  int lives;
  
  float spriteScale = 2.0;

  // Movement
  float moveSpeed = 6;
  boolean isMoving = false;

  // Facing (flip sprite)
  boolean facingRight = true;

  // Sword hitbox direction + reach
  float swordReach = 80;
  float swordThickness = 28;
  float attackDirX = 1;
  float attackDirY = 0;

  // Idle timing (optional “idle after still” behaviour)
  int idleTimer = 0;
  int idleStartDelay = 20;  // how long before idle anim plays continuously

  // State machine
  final int ST_IDLE   = 0;
  final int ST_RUN    = 1;
  final int ST_ATTACK = 2;
  final int ST_HIT    = 3;
  final int ST_DEAD   = 4;
  int state = ST_IDLE;

  // Animation playback
  int frameIndex = 0;
  int frameTick = 0;

  // Attack pacing
  int attackCooldown = 10;     // frames between attacks (prevents spam)
  int attackCooldownTimer = 0;

  // Invulnerability after hit
  int iFrames = 0;
  final int iFramesOnHit = 25;

  // =========================
  // Constructor
  // =========================
  Player(float px, float py, float r, int lv) {
    x = px;
    y = py;
    radius = r;
    maxLives = lv;
    lives = lv;

    loadKnightSheetOnce();

    state = ST_IDLE;
    frameIndex = 0;
    frameTick = 0;
    
  }
    
  // PUBLIC API
  void update() 
   {
    if (attackCooldownTimer > 0) attackCooldownTimer--;
    if (iFrames > 0) iFrames--;

    if (state != ST_DEAD) {
      facingRight = (mouseX >= x);
    }

    // Dead: just play death animation then stop
    if (state == ST_DEAD) {
      advanceFrames(deathFrames, 6, false);
      return;
    }

    // Hit: brief stun/flash window (we simply hold movement)
    if (state == ST_HIT) {
      // If you want a dedicated hit row later, add it.
      // For now, we "stagger" by holding a short time using iFramesOnHit.
      // When iFrames drops below a threshold, return to idle/run.
      if (iFrames <= iFramesOnHit - 10) {
        state = ST_IDLE;
        frameIndex = 0;
        frameTick = 0;
      }
      // Keep showing idle to avoid missing art
      advanceFrames(idleFrames, 7, true);
      return;
    }

    // Attack: play attack frames, then return to idle/run
    if (state == ST_ATTACK) {
      advanceFrames(attackFrames, 3, false);
      if (isAnimFinished(attackFrames)) {
        state = isMoving ? ST_RUN : ST_IDLE;
        frameIndex = 0;
        frameTick = 0;
        attackCooldownTimer = attackCooldown;
     }
      return;
    }

    // Normal movement and idle/run animation
    moveTowardsMouse();

    if (isMoving) {
      idleTimer = 0;
      state = ST_RUN;
      advanceFrames(runFrames, 4, true);
    } else {
      idleTimer++;
      state = ST_IDLE;

      // Idle anim loop after a short pause
      if (idleTimer >= idleStartDelay) {
        advanceFrames(idleFrames, 7, true);
      } else {
        frameIndex = 0;
        frameTick = 0;
      }
    }
  }

  void display() {
    imageMode(CENTER);

    // Optional: simple iFrame visual (blink)
    if (iFrames > 0 && (frameCount % 4 == 0)) return;

    PImage frame = getCurrentFrame();
    
    float drawW = frame.width * spriteScale;
    float drawH = frame.height * spriteScale;
 
    pushMatrix();
    translate(x, y);
    if (!facingRight) scale(-1, 1);
    image(frame, 0, 0, drawW, drawH);
    popMatrix();
  }

  // Called from mousePressed in main sketch
  void attack(ArrayList<Enemy> enemies) {
    if (state == ST_DEAD || state == ST_HIT) return;
    if (attackCooldownTimer > 0) return;

    // Set direction towards click for sword tip
    float dx = mouseX - x;
    float dy = mouseY - y;
    float mag = sqrt(dx*dx + dy*dy);
    if (mag != 0) {
      attackDirX = dx / mag;
      attackDirY = dy / mag;
    }

    // Enter attack state
    state = ST_ATTACK;
    frameIndex = 0;
    frameTick = 0;

    // Cooldown
    attackCooldownTimer = attackCooldown;

    // Damage enemies immediately (arcade feel)
    for (Enemy e : enemies) {
      if (e.alive && swordHitsEnemy(e)) {
        int hpBefore = e.health;
        e.takeDamage(1);
        if (hpBefore > 0 && !e.alive) e.killedByPlayer = true;
      }
    }
  }

  void takeDamage(int dmg) {
    if (state == ST_DEAD) return;
    if (iFrames > 0) return;

    lives -= dmg;
    if (lives <= 0) {
      lives = 0;
      state = ST_DEAD;
      frameIndex = 0;
      frameTick = 0;
      return;
    }

    // Hit reaction state
    state = ST_HIT;
    frameIndex = 0;
    frameTick = 0;
    iFrames = iFramesOnHit;
  }

  void reset() {
    lives = maxLives;
    state = ST_IDLE;
    frameIndex = 0;
    frameTick = 0;
    idleTimer = 0;
    iFrames = 0;
    attackCooldownTimer = 0;
  }

  // =========================
  // Movement + collision helpers
  // =========================
  void moveTowardsMouse() {
    float tx = constrain(mouseX, 40 + radius, width - 40 - radius);
    float ty = constrain(mouseY, 40 + radius, height - 40 - radius);

    float dx = tx - x;
    float dy = ty - y;
    float d = sqrt(dx*dx + dy*dy);

    if (d > 1.5) {
      isMoving = true;
      float step = min(moveSpeed, d);
      x += (dx / d) * step;
      y += (dy / d) * step;
    } else {
      isMoving = false;
    }
  }

  boolean swordHitsEnemy(Enemy e) {
    float tipX = x + attackDirX * swordReach;
    float tipY = y + attackDirY * swordReach;
    return dist(tipX, tipY, e.x, e.y) < (swordThickness + e.size / 2);
  }

  // =========================
  // Animation helpers
  // =========================
  void advanceFrames(PImage[] frames, int delay, boolean loop) {
    frameTick++;
    if (frameTick >= max(1, delay)) {
      frameTick = 0;
      frameIndex++;

      if (frameIndex >= frames.length) {
        frameIndex = loop ? 0 : frames.length - 1;
      }
    }
  }

  boolean isAnimFinished(PImage[] frames) {
    return frameIndex >= frames.length - 1;
  }

PImage getCurrentFrame()
{
  if (state == ST_DEAD)   return deathFrames[constrain(frameIndex, 0, deathFrames.length - 1)];
  if (state == ST_HIT)    return hitFrames[constrain(frameIndex, 0, hitFrames.length - 1)];
  if (state == ST_ATTACK) return attackFrames[constrain(frameIndex, 0, attackFrames.length - 1)];
  if (state == ST_RUN)    return runFrames[frameIndex % runFrames.length];
  return idleFrames[frameIndex % idleFrames.length];
}




void loadKnightSheetOnce() 
{
  if (idleFrames != null) return;

  SpriteSheet ss = new SpriteSheet("BlackKnight.png", 10, 5);

  // 10 frames per row, 5 rows total
  idleFrames   = ss.getRowFrames(0, 0, 10);
  runFrames    = ss.getRowFrames(1, 0, 10);
  attackFrames = ss.getRowFrames(3, 0, 10);
  hitFrames    = ss.getRowFrames(2, 0, 10);
  deathFrames  = ss.getRowFrames(4, 0, 10);
 }

}
