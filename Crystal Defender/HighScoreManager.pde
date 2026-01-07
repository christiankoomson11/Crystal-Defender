class HighScoreManager 
{
  String filename;
  int bestScore = 0;
  
  
  HighScoreManager (String fname)
  {
    filename = fname;
  }
  
  void loadHighScore()
  {
    try 
    {
      String [] lines = loadStrings(filename);
      if (lines != null && lines.length > 0)
      {
        bestScore = int (lines[0]);
      }
    } 
    catch (Exception e) 
    { 
      bestScore = 0;
    }
  }

void saveHighScore()
  {
  String[] lines = { str(bestScore) };
  saveStrings(filename, lines);
  }
}
