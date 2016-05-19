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
    map.addEntity( new MeleeWeapon(mouseX,mouseY)); 
  } else if(key == 'p')
  {
    map.addEntity(new physicsEntity("Box",mouseX,mouseY,1.005,25)); 
  }
  pressed = true;
}

void keyReleased()
{
  pressed = false;
  
}

void draw()
{
  collisionMesh.resolveCollisions();
  map.updateAll();
  map.clearBuffer();
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
  
  // debuging for testing apply force, only works on physicsEntities
  if(mousePressed)
  {
    physicsEntity a;
    try{
    a =(physicsEntity)map.getEntity(map.getEntityIndexByPos(mouseX,mouseY));
    }catch(ClassCastException e){a = null;}
    if(a!= null)
    {
    PVector dir = new PVector(mouseX-pmouseX,mouseY-pmouseY);
    a.applyForce(dir.normalize());
    }
  }
  // to be deleted /\ later
  
}