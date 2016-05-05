Map map;

void settings(){ // required to use variables inside the function size()
  map = new Map();  
  size(int(map.dimensions.x), int(map.dimensions.y));
}

void setup()
{
}

void draw()
{
  map.displayAll();
  

}

void mouseClicked()
{
  if(mouseButton == LEFT)
  {
    map.addEntity( new Entity( "Box", mouseX, mouseY ) );
 
  } else if(mouseButton == RIGHT)
  {
    int location = map.findEntityLocationByPos(new PVector(mouseX,mouseY));
    if(location != -1 )
      map.removeEntity(location);
  }
}