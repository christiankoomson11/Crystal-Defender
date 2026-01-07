abstract class Enemy 
{
  float x, y;
  float size;
  float speed;

  int health = 1;
  boolean alive = true;
  boolean killedByPlayer = false;

  // animation
  PImage[] frames;
  int frameIndex = 0;
  int frameTick = 0;
  int frameDelay = 5;

  Enemy(float x, float y, float size, float speed, int hp) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.speed = speed;
    this.health = hp;
  }

  // NOTE: matches YOUR main loop call: e.update(goal, player);
  void update(Goal goal, Player player) 
  {
    if (!alive) return;

    // ensure global sprites are available
    ensureEnemySpritesLoaded();

    move(goal, player);
    animate();
  }

  abstract void move(Goal goal, Player player);

  void animate() 
  {
    if (frames == null || frames.length == 0 || frames[0] == null) return;

    frameTick++;
    if (frameTick >= frameDelay) 
    {
      frameTick = 0;
      frameIndex = (frameIndex + 1) % frames.length;
    }
  }

  void display() 
  {
    if (!alive) return;

    // fallback always visible for debugging
    noStroke();

    // draw sprite if available
    if (frames != null && frames.length > 0 && frames[0] != null) 
    {
      imageMode(CENTER);
      PImage f = frames[frameIndex % frames.length];
      image(f, x, y, size * 2.8, size * 2.8);
    }
  }

  void takeDamage(int dmg) 
  {
    health -= dmg;
    if (health <= 0) alive = false;
  }

  boolean collidesWithGoal(Goal goal) 
  {
    return dist(x, y, goal.x, goal.y) < (size * 0.5 + goal.radius);
  }

  boolean collidesWithPlayer(Player player)
  {
    return dist(x, y, player.x, player.y) < (size * 0.5 + player.radius);
  }
}
