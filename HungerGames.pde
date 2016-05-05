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
  for(int i = 0; i < map.entities.size(); i++)
  {
    map.entities.get(i).moveTowards(mouseX,mouseY,10);
    map.entities.get(i).update();
  }
  if(mousePressed)
  {
    if(mouseButton == LEFT)
    {
      map.addEntity( new Entity( "Box", mouseX, mouseY ) );
 
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