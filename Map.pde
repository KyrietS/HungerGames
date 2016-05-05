class Map 
{
  Map()
  {
    if( !loadFromFile() )
      println("Map: Problem with loading data.");
    image = createImage(int(dimensions.x), int(dimensions.y), RGB);
    setColor(backgroundColor);
  }

  void addEntity( Entity e )
  {
    e.ID = entities.size();
    entities.add( e );
  }
  
  void removeEntity( int ID )
  {
    int location = findEntityLocationByID(ID);
    if(location != -1 && entities.get(location).getEntityName().equals("Box")) // for now just delete class "Box" so as not to delete walls
      entities.remove(location); // deletes entity with the unique id
  }
  
  void removeEntity( Entity e)
  {
    int location = findEntityLocationByID(e.ID);
    if(location != -1 && entities.get(location).getEntityName().equals("Box")) // for now just delete class "Box" so as not to delete walls
      entities.remove(location); 
  }
  
  int findEntityLocationByID(int ID)
  {
    int location = -1; //the default value, acts like null as int cannot be null
    for (int i = 0; i < entities.size(); i++)
    {
      Entity currentEntity = entities.get(i);
      if( currentEntity.ID == ID )
       location = i; // return location
    }
    return location; // if no entity with such ID return -1
  }
  
  int findEntityLocationByPos(float x, float y)
  {
    PVector pos = new PVector(x,y);
    int location = -1;
    for (int i = 0; i < entities.size(); i++)
    {
      Entity currentEntity = entities.get(i);
      if(dist(currentEntity.pos.x,currentEntity.pos.y,pos.x,pos.y) < 14) // checks if the entity is "close". to be added: proper collision detection 
        location = i; // return location
    }
    return location; // if no entity at pos return -1
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
  private color backgroundColor;
  private PImage image;
  private PVector dimensions;
  private ArrayList<Entity> entities = new ArrayList<Entity>();
  private boolean debugMode;
  
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
      
    // reading configuation file
    if(file.getChild("configuration") == null || !file.getChild("configuration").hasChildren())
      return false;
     
    XML settings = file.getChild("configuration"); // if there is a <congifuration> tag
    
    if( settings.getChild("size") != null)
    {
        dimensions = new PVector( settings.getChild("size").getInt("x") , settings.getChild("size").getInt("y") );
    }
    
    if( settings.getChild("background-color") != null) // if find tag <background-color>
    {
       String hexColor = settings.getChild("background-color").getString("value");  // Loads color to string. For example: "#FF44BB".
       if ( hexColor.charAt(0) == '#')        // Checks if first character is '#'. It means that we have hex-style color.
       {
         try                                  // Try to convert R, G and B partf from hex-style color. For example: FF, 44, 88 (R, G, B).
         {
           backgroundColor = color( unhex(hexColor.substring(1, 3)), unhex(hexColor.substring(3, 5)), unhex(hexColor.substring(5, 7)) );
         }
         catch( Exception e) {               // Problem with converting. Do nothing.
         }
       }
    }
    
    if( settings.getChild("debug-mode") != null) // if find tag <debug-mode>
    {
       debugMode = true; // set debug mode to true
    }
    // Loading entities.
    XML[] data;
    if( (data = file.getChild("elements").getChildren("entity")) == null )   // Didn't find any <entity> tags.
      return true;
    for ( int i = 0; i < data.length; i++ )
    {
      // Loading walls.
      if( data[ i ].hasAttribute("name") && data[ i ].getString("name").equals("Wall") )
      {
        entities.add(new Wall( data[ i ] ));
      }
    }
    return true;
  }
  
} // class Map