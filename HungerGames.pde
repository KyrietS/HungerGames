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
  
  if( mousePressed )
  {
    map.addEntity( new Entity( "Box", mouseX, mouseY ) );
  }
}