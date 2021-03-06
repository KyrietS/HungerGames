class Map 
{
  Map()
  {
    if ( !loadFromFile() )
      println("Map: Problem with loading data.");
    image = createImage(int(dimensions.x), int(dimensions.y), RGB);
    setColor(backgroundColor);
  }

  void addEntity( Entity e )
  {
    int newID = findMax(entities) + 1;
    e.ID = newID;
    e.collisionsGroup = newID;
    entities.add( e );
    sortEntitiesByDisplayPriority();
  }

  void removeEntity( int ID )
  {
    int location = getEntityIndexById(ID);
    if (location != -1 && !entities.get(location).getEntityType().equals("Wall")) // dont delete walls
    {
      entities.remove(location); // deletes entity with the unique id
    }
  }

  Entity getEntity( int index )
  {
    if (index == -1) {
      return null;
    }
    return entities.get( index );
  }

  int countEntities()
  {
    return entities.size();
  }

  void removeEntityByLocation( int location)
  {
    if (location != -1 && !entities.get(location).getEntityType().equals("Wall"))
      entities.remove(location); // deletes entity with the unique id
  }

  void removeEntity( Entity e)
  {
    int location = getEntityIndexById(e.ID);
    if (location != -1 && !entities.get(location).getEntityType().equals("Wall"))
      entities.remove(location);
  }

  int getEntityIndexById(int ID)
  {
    int location = -1; //the default value, acts like null as int cannot be null
    for (int i = 0; i < entities.size(); i++)
    {
      Entity currentEntity = entities.get(i);
      if ( currentEntity.ID == ID )
        location = i; // return location
    }
    return location; // if no entity with such ID return -1
  }

  int getEntityIndexByPos(float x, float y)
  {
    int location = -1;
    for (int i = 0; i < entities.size(); i++)
    {
      Entity currentEntity = entities.get(i);
      if (collision.checkContaining(currentEntity.getTransformedVertices(), new PVector(x, y)))
        location = i; // return location
    }
    return location; // if no entity at pos return -1
  }

  void sortEntitiesByDisplayPriority()
  {
    for (int j = 0; j < entities.size() - 1; j++)
    {
      for (int i = 0; i < entities.size() - 1; i++)
      {
        if (entities.get(i).displayPriority > entities.get(i+1).displayPriority)
        {
          Entity eTemp = entities.get(i + 1);
          entities.set(i + 1, entities.get(i));
          entities.set(i, eTemp);
        }
      }
    }
  }

  void displayAll()
  {
    image(image, 0, 0); 
    for (int i = 0; i < entities.size(); i++)
    {
      entities.get(i).display();
    }
  } 

  void updateAll()
  {
    for (int i = 0; i < entities.size(); i++)
    {
      entities.get(i).update();
    }
  }

  void moveToMouseALl()
  {
    for (int i = 0; i < entities.size(); i++)
    {
      if (!(entities.get(i) instanceof Weapon))
        entities.get(i).moveToPos(mouseX, mouseY, true);
    }
  }
  void updateCellsAll()
  {
    for (int i = 0; i < entities.size(); i++)
    {
      entities.get(i).updateCells();
    }
  }
  void addEntityToRemoveBuffer(Entity e)
  {
    removeBuffer.add(e);
  }

  void clearBuffer()
  {
    for (int i = 0; i < removeBuffer.size(); i++)
    {
      removeBuffer.get(i).deconstruct();
      removeEntity(removeBuffer.get(i)); 
      removeBuffer.remove(i);
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
  private ArrayList<Entity> entities = new ArrayList<Entity>();
  private ArrayList<Entity> removeBuffer = new ArrayList<Entity>();
  private color backgroundColor;
  private PImage image;
  private PVector dimensions;
  private boolean debugMode;
  private boolean loadFromFile()
  {
    XML file = loadXML("data/Map.xml");
    if ( file == null )
    {
      println("Problem with reading from file.");
      return false;
    }

    if ( file.getChild("elements") == null )      // <elements> tag not found.
      return true;

    // reading configuation file
    if (file.getChild("configuration") == null || !file.getChild("configuration").hasChildren())
      return false;

    XML settings = file.getChild("configuration"); // if there is a <congifuration> tag

    if ( settings.getChild("size") != null)
    {
      dimensions = new PVector( settings.getChild("size").getInt("x"), settings.getChild("size").getInt("y") );
    }

    if ( settings.getChild("background-color") != null) // if find tag <background-color>
    {
      String hexColor = settings.getChild("background-color").getString("value");  // Loads color to string. For example: "#FF44BB".
      backgroundColor = toRGB(hexColor);
    }

    if ( settings.getChild("debug-mode") != null) // if find tag <debug-mode>
    {
      debugMode = true; // set debug mode to true
    }
    // Loading entities.
    XML[] data;
    if ( (data = file.getChild("elements").getChildren("entity")) == null )   // Didn't find any <entity> tags.
      return true;
    //for ( int i = 0; i < data.length; i++ )
    //{
    //  // Loading walls.
    //  if( data[ i ].hasAttribute("type") && data[ i ].getString("type").equals("Wall") )
    //  {
    //    entities.add(new Wall( data[ i ] ));
    //  }
    //}
    return true;
  }
} // class Map