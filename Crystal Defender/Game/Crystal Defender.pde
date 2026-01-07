// Main Game 
Goal goal;
Player player;
HighScoreManager highScores;


// The state of the Game 

final int state_Menu = 0;
final int state_Playing = 1;
final int state_GameOver = 2;

int gameState = state_Menu;


// Global objects
ArrayList<Enemy> enemies;
ArrayList<Explosion> explosions;
PImage[] ChaserFrames;
PImage[] walkFrames;
PImage[] goalEnemyFrames;
PImage[] chaserEnemyFrames;

// The scores and lives
int score = 0;

// Enemy Spawn
int spawnTimer = 0;
int spawnInterval = 90;
int wave = 1;

void setup()
{
  size (800,600);
  noSmooth();
  hint(DISABLE_TEXTURE_MIPMAPS);
  
  ensureEnemySpritesLoaded();
  
  ChaserFrames = new SpriteSheet("BatSheet.png", 10, 2).getRowFrames(0,0,10);
  walkFrames = new SpriteSheet("Troll.png",5,6).getRowFrames(1,0,5);
  enemies = new ArrayList<Enemy>();
  explosions = new ArrayList<Explosion>();
 
  goal = new Goal (width/2, height/2, 40, 5); // Goal has 5 health
  player = new Player(width/2, height/2 + 120, 30,3); //Player has 3 lives 
  
  highScores = new HighScoreManager("highscore.text");
  highScores.loadHighScore();
  
  gameState = state_Menu;
}

void draw()
{
  background(20);
  
  switch(gameState)
  {
    case state_Menu:
    drawMenu();
    break;
    case state_Playing:
    updateGame();
    drawGame();
    break;
    case state_GameOver:
    drawGameOver();
    break;
  }
}
                                                                                               
void drawMenu()
{
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Crystal defender", width/2, height/4 - 60);
  
  textSize(16);
text("Move the guardian with your mouse. \n Click to attack enemies. \n\n Trolls move towards the crystal. Bats chase you \n\nPress ENTER to start.",
  width/2, height/2 + 20);
  
  text("\nHigh score: " + highScores.bestScore, width/2, height - 60);
}

void drawGame()
{
  stroke(100);
  noFill();
  rect(40,40,width-80,height-80);
  noStroke();
  
  //Draws the goal and the player
  goal.display();
  player.display();
  
  //Draws the enemies
  for (Enemy e: enemies)
  {
    e.display();
  }
  
  //Draws the explosions
  for (Explosion ex: explosions)
  {
    ex.display();
  }
  
  // A section of the gaem interface
  fill (255);
  textAlign(LEFT, TOP);
  text("Score: " + score, 10,10);
  text("Goal HP: " + goal.health, 10, 30);
  text("Lives: " + player.lives, 10,50);
  text("Wave: " + wave, 10,70);
  text("Enemies: " + enemies.size(), 10,90);
}

void ensureEnemySpritesLoaded() {
  if (goalEnemyFrames != null && chaserEnemyFrames != null) return;

  if (chaserEnemyFrames == null) {
    SpriteSheet batSS = new SpriteSheet("BatSheet.png", 4, 4);
    chaserEnemyFrames = batSS.getAllFrames();
  }

  if (goalEnemyFrames == null) {
    SpriteSheet trollSS = new SpriteSheet("Troll.png", 5, 6);

    goalEnemyFrames = trollSS.getRowFrames(2,0,5);
  }

  //Debug 
  println("goalEnemyFrames:", (goalEnemyFrames == null ? "null" : goalEnemyFrames.length));
  println("chaserEnemyFrames:", (chaserEnemyFrames == null ? "null" : chaserEnemyFrames.length));
}



void drawGameOver()
{
  drawGame(); // draws the final frame background
  
  fill(0,200);
  rectMode(CORNER);
  rect(0,0, width,height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("GAME OVER", width/2, height/2 - 40);
  
  textSize(18);
  text("Final score: " + score + 
  "\nHigh score: " + highScores.bestScore + 
  "\n\nPress ENTER to return to menu.",
  width/2, height/2 + 20);
}

void startGame()
{
  enemies.clear();
  explosions.clear();
  
  goal.reset();
  player.reset();
  
  score = 0;
  wave = 1;
  spawnTimer = 0;
  spawnInterval = 90;
  
  gameState = state_Playing;
}

void updateGame()
{
  player.update();
  goal.update();
  
  spawnTimer++;
  if (spawnTimer >= spawnInterval)
  {
    spawnWaveEnemy();
    spawnTimer = 0;
  }
  
  if (frameCount % (60*15) == 0) // every 15 seconds
    {
    wave++;
    if (spawnInterval > 30)
    {
      spawnInterval -= 10; //faster spawn times 
  }
}

for (int i = enemies.size() - 1; i>=0; i--)
{
  // Initializes the enemies
  Enemy e = enemies.get(i);
  e.update(goal, player);
  
  //Has the enemy reached the goal
  if (e.collidesWithGoal(goal))
  {
    goal.takeDamage(1);
    e.alive = false;
  }
  
  // If the enemy hits the player 
  if (e.collidesWithPlayer(player))
  {
    player.takeDamage(1);
    e.alive = false;
  }
  
  if (!e.alive) 
  {
  if (e.killedByPlayer) score += 10;
  explosions.add(new Explosion(e.x, e.y));
  enemies.remove(i);
  }
}
  
  //Update explosions
  for (int i = explosions.size() - 1; i>=0; i--)
  {
    Explosion ex = explosions.get(i);
    ex.update();
    if (ex.isFinished())
    {
      explosions.remove(i);
    }
  }
  
  
  //Check if the game is over
  if (goal.health <= 0 || player.lives <= 0)
  {
    //Update high score if needed 
    if (score > highScores.bestScore)
    {
      highScores.bestScore = score;
      highScores.saveHighScore();
    }
    gameState = state_GameOver;
  }
}
  
  
void spawnWaveEnemy()
{
  //Choose between 0 = GoalEnemy, 1 = ChaserEnemy
  int type = (int)random(2);
  
  //Spawn around the screens edges
  float ex, ey;
  int side =  (int)random(4);
  if (side == 0)
  {
    ex = random(40, width-40); //top
    ey = 40;
  }
  else if (side == 1) 
  {
    ex = random(40, width - 40); //bottom
    ey = height - 40;
  }
  else if (side == 2)
  {
    ex = 40;
    ey = random(40, height - 40); //left 
  }
  else 
  {
    ex = width - 40;
    ey = random(40, height-40);
  }
  
  if (type == 0)
  {
    enemies.add(new GoalEnemy(ex,ey, 22,1.4));
  }
  else
  {
    enemies.add(new ChaserEnemy(ex,ey, 20,1.8));
  }
}
  
 
//Player input section 

void mousePressed()
{
  if (gameState == state_Playing)
  {
    player.attack(enemies);
  }
}

void keyPressed()
{
  if (keyCode == ENTER)
  {
    if (gameState == state_Menu)
    {
      startGame();
    }
    else if (gameState == state_GameOver)
    {
      gameState = state_Menu;
    }
  }
}
