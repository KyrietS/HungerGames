class Entity //<>//
{
  Entity(String _name, int x, int y)
  {
    pos.set(x, y);
    name = _name;
    if ( !loadFromFile() )
    {
      println("Entity: Cannot create an entity object. LoadFromFile failed!");
    }
  }

  Entity() {
  } // Default constructor.

  void display() // Draw an object on the screen.
  {
    fill( col );              // setting: fill color
    stroke( #000000 );        // setting: line color
    strokeWeight( bold );     // setting: line weight
    strokeCap( cap );         // setting: line cap
    strokeJoin( edge );       // setting: line edge
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

  protected PVector pos = new PVector(0, 0);              // Position of the object on the map. (Anchor point)
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected color col = #000000;                         // Setting: fill color.
  protected String name = "None";                        // Name of the object. If "none", the object is not specified.
  protected float bold = 1;                              // Setting: line weight.
  protected int edge = MITER;                            // Setting: line edge style.
  protected int cap = PROJECT;                           // Setting: line cap style.

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
        if ( !currentChild.hasAttribute("name") )  // entity doesn't contain "name" attribute - skip.
          break;
        if ( currentChild.getString( "name" ).equals(name) ) // correct entity found. Then load it. // suggestion: change name to type
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
                col = color( unhex(hexColor.substring(1, 3)), unhex(hexColor.substring(3, 5)), unhex(hexColor.substring(5, 7)) );
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
      println("Cannot find \"" + name + "\" entity in file: \"Data\\Entities.xml\"");
    }
    return false;
  } // loadDataFromFile
} // class Entity


class Wall extends Entity
{
  Wall( XML data )
  {
    bold = 25;
    col = #BD80BD;
    
    if ( !loadData( data ) )
      println( "Wall: Cannot load data." );
  }

  void display()
  {
    stroke( col );          // Setting: line color.
    strokeCap( cap );       // Setting: line cap.
    strokeJoin( edge );     // Setting: line edge.
    strokeWeight( bold );   // Setting: line weight.
    for ( int i = 0; i < vertices.size() - 1; i++ )
    {
      line( vertices.get(i).x, vertices.get(i).y, vertices.get(i+1).x, vertices.get(i+1).y );
    }
  }

  // Loads data from XML object. XML object must contain <entity name="Wall"> tag.
  private boolean loadData( XML data )
  {
    if ( data == null || !data.hasAttribute("name") || !data.getString("name").equals("Wall") || data.getChildren("vertex") == null )
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