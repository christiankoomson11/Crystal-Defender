class Goal
{
  float x,y;
  float radius;
  int maxHealth;
  int health;
  
  PImage[] frames;
  int frameIndex = 0;
  int frameTick = 0;
  int frameDelay = 6;
  
  Goal(float x, float y, float r, int hp)
  {
    this.x = x;
    this.y = y;
    this.radius = r;
    this.health = hp;
    this.maxHealth = hp;
    
    loadCrystal();
  }
  
  void loadCrystal()
  {
    SpriteSheet sheet = new SpriteSheet("Crystal.png",24,1);
    frames = sheet.getAllFrames();
  }
  
  void update()
  {
    frameTick++;
    if (frameTick >= frameDelay)
    {
      frameTick = 0;
      frameIndex = (frameIndex + 1) % frames.length;
    }
  }
  
  void display()
  {
   imageMode(CENTER);
   
   float size =  radius * 2.4;   // scale the crystal visually 
   image(frames[frameIndex],x,y, size, size);
  }
  
  void takeDamage(int dmg)
  {
   health = max(0,health - dmg);
  }
  
  void reset()
  {
    health = maxHealth;
    frameIndex = 0;
    frameTick = 0;
  }
}
