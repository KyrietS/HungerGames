Map map;

void settings() { // required to use variables inside the function size()
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
  
  if (!keyPressed)
   return;
    if (key == 'r')
    {
      int location = map.findEntityLocationByPos(mouseX, mouseY);
      if (location != -1 )
        map.removeEntityByLocation(location);
    } 
    else if (key == 't')
    {
      map.addEntity( new Tribute( mouseX, mouseY ) );
    }
    else if ( key == 'b')
    {
      map.addEntity( new Entity("Box", mouseX, mouseY ) );
    }
}

void mouseClicked()
{
}