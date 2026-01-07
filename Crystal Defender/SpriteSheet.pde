class SpriteSheet 
{
  PImage sheet;
  int cols, rows;
  int frameW, frameH;

  SpriteSheet(String filename, int cols, int rows) 
  {
    sheet = loadImage(filename);
    
    if(sheet == null)
    {
      println("ERROR! Could not load image: " + filename);
      cols = 1;
      rows = 1;
      frameW = 1;
      frameH = 1;
      return;
    }
    
    this.cols = cols;
    this.rows = rows;
    
    frameW = sheet.width /cols;
    frameH = sheet.height /rows;
  }

  PImage getFrame(int col, int row) 
  {
  int x = col * frameW;
  int y = row * frameH;


  int inset = 1;

  int sx = x + inset;
  int sy = y + inset;
  int sw = frameW - inset * 2;
  int sh = frameH - inset * 2;

  
  if (sw <= 0 || sh <= 0) 
  {
    return sheet.get(x, y, frameW, frameH);
  }

  return sheet.get(sx, sy, sw, sh);
}



   PImage[] getAllFrames() 
    {
    PImage[] out = new PImage[cols * rows];
    int k = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        out[k++] = getFrame(c, r);
      }
    }
    return out;
  }
  
  PImage[] getRowFrames(int row, int startCol, int count)
  {
    PImage[] out = new PImage [count];
    for (int i = 0; i < count; i++)
    {
      out[i] = getFrame(startCol + i,row);
    }
    return out;
  }
}
