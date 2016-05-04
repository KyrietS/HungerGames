class heightmapClass extends object
{
  PImage heightMap, colourGradient;
  heightmapCell[] cells;
  color[] gradients;
  heightmapClass()
  {
    heightMap = createImage(width, height, RGB);
    colourGradient = loadImage("gradient.png");
    cells = new heightmapCell[0];
    gradients = new color[256];
    for (int i = 0; i <= colourGradient.pixels.length; i++)
    {
      float percentOfLength = float(i) / colourGradient.pixels.length;
      int location = int(percentOfLength * 255);
      float r = red(colourGradient.pixels[i - 1]);
      float g = green(colourGradient.pixels[i - 1]);
      float b = blue(colourGradient.pixels[i - 1]);
      gradients[location] = color(r, g, b);
    }
    for (int y = 0; y < height; y++)
    {
      for (int x = 0; x < width; x++)
      {
        int currentLocation = get2Dlocation(new PVector(x, y), width);
        int[] localCells = {currentLocation - width, (currentLocation-width)+1, currentLocation +1, (currentLocation+width)+1, currentLocation + width, (currentLocation + width) - 1, currentLocation - 1, (currentLocation + width) - 1};
        for (int i = 0; i < localCells.length; i++) {
          localCells[i] = int(clamp(localCells[i], 0, (height*width)));
        }
      }
    }
  }
}
class heightmapCell 
{
  int location, meshID;
  int[] localCells;
  PVector position, peakPosition;
  float gradientMultiplier;
  heightmapCell(int id, PVector pos, int[] LocalCells)
  {
    location = id;
    position = pos;
    peakPosition = null;
    localCells = LocalCells;
  }
  void expandTerrain()
  {
    if (peakPosition == null)
      return;
    float gradientToNeighbours;
    
    if (peakPosition == position)
      gradientToNeighbours = 10;
    else 
      gradientToNeighbours = dist(position.x, position.y, peakPosition.x, peakPosition.y); 

    for (int i = 0; i < localCells.length; i++)
    {
      heightmapCell currentCell = heightmap.cells[localCells[i]].position.z;
      float diff = position.z - currentCell.position.z;
      if (diff < gradientToNeighbours) {
        return;
      }
      heightmap.cells[localCells[i]].position.z += diff/4;
      position.z -= diff/4;
      heightmap.cells[localCells[i]].peakPosition = peakPosition;
      heightmap.cells[localCells[i]].grdaientMultiplier = gradientMultiplier;
    }
  }
}