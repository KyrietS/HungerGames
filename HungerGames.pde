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
  collisionMesh = new CollisionMesh(20,20);
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
  } else if (key == 'w')
  {
    map.addEntity( new Weapon(mouseX,mouseY)); 
  }
  pressed = true;
}

void keyReleased()
{
  pressed = false;
  
}

void draw()
{
  map.updateAll();
  map.displayAll();
  map.moveToMouseALl();
  collisionMesh.displayMesh();
  collisionMesh.clearAllCells(); // there is an error in the update code of entities, so i clear all cells for now. it occured when rotation was added
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

//void mouseClicked()
//{
//  println(frameRate);
//}