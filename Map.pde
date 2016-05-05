class Map 
{
  Map()
  {
    image = createImage(width, height, RGB);
    if( !loadFromFile() )
      println("Map: Problem with loading data.");
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
  
  private PImage image;
  private ArrayList<Entity> entities = new ArrayList<Entity>();
  
  private boolean loadFromFile()
  {
    XML file = loadXML("data/Map.xml");
    if ( file == null )
    {
      println("Problem with reading from file.");
      return false;
    }
    
    if( file.getChild("elements") == null )      // <elements> tag not found.
      return true;
    
    // Loading entities.
    XML[] data;
    if( (data = file.getChild("elements").getChildren("entity")) == null )   // Didn't find any <entity> tags.
      return true;
    for ( int i = 0; i < data.length; i++ )
    {
      // Loading walls.
      if( data[ i ].hasAttribute("name") && data[ i ].getString("name").equals("Wall") )
      {
        println( data[i] );
        entities.add(new Wall( data[ i ] ));
      }
    }
    return true;
  }
  
} // class Map