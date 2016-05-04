Map map;
void setup()
{
 size(500,500);
 map = new Map(500,500);  
 map.setColor(color(100));
}
void draw()
{
 map.displayAll();
}