class heightmap{
  PImage heightMap,colourGradient;
  cell[] cells;
  color[] gradients;
  heightmap(){
   heightMap = createImage(width,height,RGB);
   colourGradient = loadImage("gradient.png");
   cells = new cell[0];
   gradients = new color[256];
  }
}
class heightmapCell{
  int location, meshID;
  int[] localCells;
  float zHeight;
  PVector position, peakPosition;
  float modifyGradient;
  heightmapCell(int id, PVector pos,float Height, int[] LocalCells){
    position = pos;
    peakPosition = null;
    zHeight = Height;
    localCells = LocalCells;
  }
}