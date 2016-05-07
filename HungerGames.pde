Map map;

void settings() { // required to use variables inside the function size()
  map = new Map();  
  size(int(map.dimensions.x), int(map.dimensions.y));
}

void setup()
{
  noStroke();
}

boolean pressed = false;

void keyPressed()
{
  if ( pressed )
    return;

  if (key == 't')
  {
    map.addEntity( new Tribute( mouseX, mouseY ) );
  } else if ( key == 'b')
  {
    map.addEntity( new Entity("Box", mouseX, mouseY ) );
  }
  pressed = true;
}

void keyReleased()
{
  pressed = false;
}

void draw()
{
  map.displayAll();
  map.updateAll();
  map.moveToMouseALl();

  if ( keyPressed )
  {
    if (key == 'r')
    {
      int location = map.getEntityIndexByPos(mouseX, mouseY);
      if (location != -1 )
        map.removeEntityByLocation(location);
    }
  }
}

void mouseClicked()
{
}