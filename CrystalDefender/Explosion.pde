class Explosion 
{
  float x,y;
  int life = 15;
  
  Explosion(float ex, float ey)
  {
    x = ex;
    y = ey;
  }
  
  void update()
  {
    life--;
  }
  
  void display()
 {
   float progress = map(life, 0,15,1,0);
   float r = 10 + 30 * (1 - progress);
   noFill();
   stroke(255,200* progress, 0 );
   ellipse(x,y, r,r);
   noStroke();
 }
 
 
 boolean isFinished()
  {
   return life <= 0;
  }
}
