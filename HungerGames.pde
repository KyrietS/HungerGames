Map map;
CollisionSystem collision;
CollisionMesh collisionMesh;
void settings() { // required to use variables inside the function size()
  map = new Map();  
  size(int(map.dimensions.x), int(map.dimensions.y));
}

void setup()
{
  collision = new CollisionSystem();
  collisionMesh = new CollisionMesh(10,10);
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
  println(frameRate);
  map.displayAll();
  map.updateAll();
  map.moveToMouseALl();
  //collisionMesh.displayMesh();
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