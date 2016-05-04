class Map 
{
  PImage image;
  PVector dimensions;
  ArrayList<Entity> entities;

  Map(int x, int y)
  {
    dimensions = new PVector(x, y);
    image = createImage(x, y, RGB);
    entities = new ArrayList<Entity>(0);
  }

  void addEntity( Entity e )
  {
    entities.add( e );
  }

  void displayAll()
  {
    image(image, 0, 0); 
    for (int i = 0; i < entities.size(); i++)
    {
      entities.get(i).display();
    }
  }

  void setColor(color Color)
  {
    image.loadPixels();
    for (int i = 0; i < image.pixels.length; i++)
    {
      image.pixels[i] = Color;
    }
    image.updatePixels();
  }
}