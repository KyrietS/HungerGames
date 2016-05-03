class heightmapClass{
  PImage heightMap,colourGradient;
  heightmapCell[] cells;
  color[] gradients;
  heightmap(){
   heightMap = createImage(width,height,RGB);
   colourGradient = loadImage("gradient.png");
   cells = new heightmapCell[0];
   gradients = new color[256];
  }
}
class heightmapCell{
  int location, meshID;
  int[] localCells;
  PVector position, peakPosition;
  float modifyGradient;
  heightmapCell(int id, PVector pos, int[] LocalCells){
    location = id;
    position = pos;
    peakPosition = null;
    localCells = LocalCells;
  }
 void expandTerrain(){
   if(peakPosition == null){return;}
   float gradientToNeighbours;
   if(peakPosition == position){
     gradientToNeighbours = 10;
   } else {
     gradientToNeighbours = dist(position.x,position.y,peakPosition.x,peakPosition.y); 
   }
   for(int i = 0; i < localCells.length; i++){
     heightmapCell currentCell = heightmap.cells[localCells[i]].position.z;
     float diff = position.z - currentCell.position.z;
     if(diff < gradientToNeighbours){return;}
     heightmap.cells[localCells[i]].position.z += diff/4;
     position.z -= diff/4;
     heightmap.cells[localCells[i]].peakPosition = peakPosition;
   }
 }
}