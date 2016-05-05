Map map;
void setup()
{
  size( 800, 600 );
  map = new Map();  
  map.setColor(color(100));
}
void draw()
{
  map.displayAll();
  
  if( mousePressed )
  {
    map.addEntity( new Entity( "Box", mouseX, mouseY ) );
  }
}