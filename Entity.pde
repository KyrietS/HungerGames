class Entity //<>//
{
  Settings settings = new Settings(#000000,#000000,1,MITER,PROJECT);
  Entity(String _type, int x, int y)
  {
    pos.set(x, y);
    type = _type;
    if ( !loadFromFile() )
    {
      println("Entity: Cannot create an entity object. LoadFromFile failed!");
    }
  }

  Entity() {
  } // Default constructor.
  
  void display() // Draw an object on the screen.
  {
    settings.applySettings();
    pushMatrix();
    translate( pos.x, pos.y );
    beginShape();
    
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex( vertices.get( i ).x, vertices.get(i).y );
    }
    
    endShape(CLOSE);
    popMatrix();
  }
  
  void update()
  {
    pos.add(vel);
  }
  
  void moveTowards(float x, float y, float speed)
  {
    speed/= frameRate;
    PVector targetPos = new PVector(x,y);
    PVector resultantVector = PVector.sub(targetPos,pos);
    resultantVector.normalize();
    resultantVector.mult(speed * random(0.5,1.5));
    resultantVector.limit(speed);
    vel.set(resultantVector);
  }
  
  PVector getPos()
  {
    return pos;
  }

  void setPos( float x, float y )
  {
    pos.x = x;
    pos.y = y;
  }

  void setPos( PVector v )
  {
    pos = v;
  }
  
  String getEntityType(){
   return type; 
  }
  
  private int ID;
  protected PVector pos = new PVector(0, 0);              // Position of the object on the map. (Anchor point)
  protected PVector vel = new PVector(0, 0);              // velocity of the object
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected String type = "None";                        // type of the object. If "none", the object is not specified.


  // Load data from file: "data\Entity.xml". More info about specification of the file can be found in Docs.
  private boolean loadFromFile()
  {
    boolean entityFound = false;
    try
    {
      XML file = loadXML("data/Entities.xml");
      if ( file == null )             // Checks if file was loaded correctly.
      {
        println("Problem with reading from file.");
        return false;
      }
      XML[] entities = file.getChildren("entity");
      for ( int i = 0; i < entities.length; i++ )
      {
        XML currentChild = entities[ i ]; //Temporary variables for readability, stores current child and some attributes to remove repetition of code
        XML currentChildAttributeAnchorPoint = currentChild.getChild("anchor-point"); 
        XML currentChildAttributeColor = currentChild.getChild("color");
        
        // Find a proper entity.
        if ( !currentChild.hasAttribute("type") )  // entity doesn't contain "type" attribute - skip.
          break;
        if ( currentChild.getString( "type" ).equals(type) ) // correct entity found. Then load it. // suggestion: change type to type
        {
          entityFound = true;
          PVector vertex = new PVector();        // Temporary variable for readability.
          PVector anchorPoint = new PVector();   // Temporary variable for readability.

          // Loading anchor point.
          if ( currentChildAttributeAnchorPoint != null && currentChildAttributeAnchorPoint.hasAttribute("x") && 
          currentChildAttributeAnchorPoint.hasAttribute("y"))        // Checks whether entity contains achor-point with x and y attributes.
          {
            anchorPoint.x = currentChild.getChild("anchor-point").getFloat("x");
            anchorPoint.y = currentChild.getChild("anchor-point").getFloat("y");
          }

          // Loading color.
          if ( currentChildAttributeColor != null && currentChildAttributeColor.hasAttribute("value") )
          {
            String hexColor = currentChildAttributeColor.getString("value");  // Loads color to string. For example: "#FF44BB".
            if ( hexColor.charAt(0) == '#')        // Checks if first character is '#'. It means that we have hex-style color.
            {
              try                                  // Try to convert R, G and B partf from hex-style color. For example: FF, 44, 88 (R, G, B).
              {
                settings.col = color( unhex(hexColor.substring(1, 3)), unhex(hexColor.substring(3, 5)), unhex(hexColor.substring(5, 7)) );
              }
              catch( Exception e) {               // Problem with converting. Do nothing.
              }
            }
          }
          
          // Loading vertices.
          if ( (entities = currentChild.getChildren("vertex")) == null )    // Entity doesn't contain any "vertex" property.
          {
            return false;
          }
          for ( int j = 0; j < entities.length; j++ )
          {
            XML currentEntityJ = entities[ j ]; //temporary variable to remove repetition and improve readability
            
            // One of the vertices doesn't contain x or y attribute.
            if ( !currentEntityJ.hasAttribute("x") || !currentEntityJ.hasAttribute("y") )
              return false;
            vertex.x = currentEntityJ.getFloat("x") - anchorPoint.x;
            vertex.y = currentEntityJ.getFloat("y") - anchorPoint.y;
            vertices.add( new PVector( vertex.x, vertex.y ) );
          }
          return true;
        }
      } // for
    } // try
    catch( NullPointerException e )    // Unknown problem with reading.
    {
      println("Some element not found.");
      return false;
    }
    if ( !entityFound )
    {
      println("Cannot find \"" + type + "\" entity in file: \"Data\\Entities.xml\"");
    }
    return false;
  } // loadDataFromFile
} // class Entity


class Wall extends Entity
{
  Wall( XML data )
  {
    settings.bold = 25;
    settings.col = #BD80BD;
    if ( !loadData( data ) )
      println( "Wall: Cannot load data." );
  }

  void display()
  {
    settings.applySettings();
    for ( int i = 0; i < vertices.size() - 1; i++ )
    {
      line( vertices.get(i).x, vertices.get(i).y, vertices.get(i+1).x, vertices.get(i+1).y );
    }
  }

  // Loads data from XML object. XML object must contain <entity type="Wall"> tag.
  private boolean loadData( XML data )
  {
    if ( data == null || !data.hasAttribute("type") || !data.getString("type").equals("Wall") || data.getChildren("vertex") == null )
      return false;
    
    PVector vertex = new PVector();             // Temporary variable for readability.
    XML[] verts = data.getChildren("vertex");
    
    for ( int i = 0; i < verts.length; i++ )
    {
      // Current vertex doesn't contain x or y attribute.
      if ( !verts[ i ].hasAttribute("x") || !verts[ i ].hasAttribute("y") )
        return false;
      vertex.x = verts[ i ].getFloat("x");
      vertex.y = verts[ i ].getFloat("y");
      vertices.add(new PVector( vertex.x, vertex.y ) );
    }
    return true;
  }
}

class Tribute extends Entity
{
  private int health;
  private float stamina;
}