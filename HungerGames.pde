Map map;

void settings(){ // required to use variables inside the function size()
  map = new Map();  
  size(int(map.dimensions.x), int(map.dimensions.y));
}

void setup()
{
  noStroke();
}

void draw()
{
  map.displayAll();
  map.updateAll();
  map.moveToMouseALl();
  if(mousePressed)
  {
    if(mouseButton == LEFT)
    {
      map.addEntity( new Tribute( mouseX, mouseY ) );
 
    } else if(mouseButton == RIGHT)
    {
    int location = map.findEntityLocationByPos(mouseX,mouseY);
    if(location != -1 )
      map.removeEntity(location);
    }
  }
}

void mouseClicked()
{

}