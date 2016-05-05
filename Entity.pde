class Entity //<>//
{
  Entity(String _name, int x, int y)
  {
    pos.set(x, y);
    name = _name;
    if ( !loadFromFile() )
    {
      println("Entity: Cannot create an entity object. LoadFromFile failed!");
      vertices.clear();
    }
  }

  Entity() {
  } // Default constructor.

  void debug()
  {
    vertices.add( new PVector( 0, 50 ) );
    vertices.add( new PVector( 100, 0 ) );
    vertices.add( new PVector( 200, 50 ) );
    vertices.add( new PVector( 200, 150 ) );
    vertices.add( new PVector( 0, 150 ) );
    col = #FF6905;
  }

  void display()
  {
    fill( col );
    stroke( #000000 );
    strokeWeight( bold );
    strokeCap( cap );
    strokeJoin( edge );
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

  protected PVector pos = new PVector(0, 0);
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected color col = #000000;
  protected String name = "None";
  protected float bold = 1;
  protected int edge = MITER;
  protected int cap = PROJECT;

  private boolean loadFromFile()
  {
    boolean entityFound = false;
    try
    {
      XML file = loadXML("data/Entities.xml");
      if ( file == null )
      {
        println("Problem with reading from file.");
        return false;
      }
      XML[] entities = file.getChildren("entity");
      for ( int i = 0; i < entities.length; i++ )
      {
        // Find a proper utility.
        if ( !entities[ i ].hasAttribute("name") )  // utility doesn't contain "name" attribute - skip
          break;
        if ( entities[ i ].getString( "name" ).equals(name) )
        {
          entityFound = true;
          PVector vertex = new PVector();        // Temporary variable for readability.
          PVector anchorPoint = new PVector();   // Temporary variable for readability.

          // Loading anchor point.
          if ( entities[ i ].getChild("anchor-point") != null && entities[ i ].getChild("anchor-point").hasAttribute("x") &&
            entities[ i ].getChild("anchor-point").hasAttribute("y"))
          {
            anchorPoint.x = entities[ i ].getChild("anchor-point").getFloat("x");
            anchorPoint.y = entities[ i ].getChild("anchor-point").getFloat("y");
          }

          // Loading color.
          if (  entities[ i ].getChild("color") != null && entities[ i ].getChild("color").hasAttribute("value") )
          {
            String hexColor = entities[ i ].getChild("color").getString("value");
            if ( hexColor.charAt(0) == '#')
            {
              try
              {
                col = color( unhex(hexColor.substring(1, 3)), unhex(hexColor.substring(3, 5)), unhex(hexColor.substring(5, 7)) );
              }
              catch( Exception e) {
              }
            }
          }
          // Loading vertices.
          if ( (entities = entities[ i ].getChildren("vertex")) == null )
            return false;
          for ( int j = 0; j < entities.length; j++ )
          {
            // One of the vertices doesn't contain x or y attribute.
            if ( !entities[ j ].hasAttribute("x") || !entities[ j ].hasAttribute("x") )
              return false;
            vertex.x = entities[ j ].getFloat("x") - anchorPoint.x;
            vertex.y = entities[ j ].getFloat("y") - anchorPoint.y;
            vertices.add( new PVector( vertex.x, vertex.y ) );
          }
          return true;
        }
      } // for
    } // try
    catch( NullPointerException e )
    {
      println("Some element not found.");
      return false;
    }
    if ( !entityFound )
    {
      println("Cannot find \"" + name + "\" entity in file: \"Data\\Entities.xml\"");
    }
    return false;
  } // loadFromFile
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
    stroke( col );
    strokeCap( cap );
    strokeJoin( edge );
    strokeWeight( bold );
    for ( int i = 0; i < vertices.size() - 1; i++ )
    {
      line( vertices.get(i).x, vertices.get(i).y, vertices.get(i+1).x, vertices.get(i+1).y );
    }
  }

  private boolean loadData( XML data )
  {
    if ( data == null || !data.hasAttribute("name") || !data.getString("name").equals("Wall") || data.getChildren("vertex") == null )
      return false;
    PVector vertex = new PVector();     // Temporary variablo for readability.
    XML[] verts = data.getChildren("vertex");
    for ( int i = 0; i < verts.length; i++ )
    {
      if ( !verts[ i ].hasAttribute("x") || !verts[ i ].hasAttribute("x") )
        return false;
      vertex.x = verts[ i ].getFloat("x");
      vertex.y = verts[ i ].getFloat("y");
      vertices.add(new PVector( vertex.x, vertex.y ) );
    }
    return true;
  }
}