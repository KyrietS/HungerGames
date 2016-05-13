//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class Entity
{
  boolean tmpDebug = true;
  Settings settings = new Settings(#000000, #000000, 1, MITER, PROJECT);
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
  } 

  // Main Methods ---------- Main Methods \\

  void display()
  {
    settings.applySettings();
    beginShape();
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex( getTransformedVertices().get( i ).x, getTransformedVertices().get(i).y );
    }
    endShape(CLOSE);
  }

  void update()
  {
    resolveCollisionsBeforeMove();
    direction.set(vel);
    pos.add(vel);
    resolveCollisionsAfterMove();
  }

  // supporting Methods ---------- Supporting Methods \\

  void applyCollisionAction(Entity e)  // change this to change behaviour of entity after a collision
  {
    PVector toTarget = PVector.sub(pos, e.pos);
    moveInDirection(toTarget, 5);
  }

  void resolveCollisionsBeforeMove()
  {
    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices());
    int[] objectIds = getIdsOfEntitiesInCells(inCells);
    Entity[] colidingEntities = getColidingEntities(objectIds);

    for (int i = 0; i < colidingEntities.length; i++)
    {
      applyCollisionAction(colidingEntities[i]);
    }
  }

  void resolveCollisionsAfterMove()
  {
    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices()); // update in which cells the entity is in
    addIdToCells(inCells);
  }

  Entity[] getColidingEntities(int[] objectIds)
  {
    Entity[] colidingEntities = new Entity[0];
    for ( int i = 0; i < objectIds.length; i++ )
    {
      int index = map.getEntityIndexById(objectIds[i]);
      if (index != -1)
      {
        Entity currentEntity = map.getEntity(index);
        if (isColidingWith(currentEntity))
        {
          colidingEntities = (Entity[])append(colidingEntities, currentEntity);
        }
      }
    }
    return colidingEntities;
  }

  Boolean isColidingWith(Entity e)
  {
    boolean isCollision = false;
    if ( ID != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
    { 
      if ( tmpDebug )
      {
        color rand = color(random(0, 255), random(0, 255), random(0, 255));
        e.settings.col = rand;
        settings.col = rand;
        printDebug();
        tmpDebug = false;
      }
      isCollision = true;
    }
    return isCollision;
  }

  int[] getIdsOfEntitiesInCells(CollisionCell[] inCells)      
  {
    int[] objectIds = new int[0];
    for (int i = 0; i < inCells.length; i++)
    {
      for (int j = 0; j < inCells[i].getObjectsIds().length; j++)
      {
        objectIds = (int[])append(objectIds, inCells[i].getObjectsIds()[j]);  // accumulate all the nearby objects by collecting data from all cells which the entity is in
      }
    }
    return objectIds;
  }

  void addIdToCells(CollisionCell[] inCells)          
  {
    for (int i = 0; i < inCells.length; i++) 
    {
      inCells[i].addEntity(ID); // add entities location to the cell at new position
    }
  }

  void moveToPos(float x, float y)                  
  {

    if ( dist(x, y, pos.x, pos.y) < 0.1) // check if arrived at target
    {
      vel.set(0, 0);
      return;
    }
    float speedTemp = speed;
    speedTemp/= frameRate;
    PVector targetPos = new PVector(x, y);
    targetPos.set(clamp(targetPos, 0, width, 0, height)); // clamp the position to the screen, efficient edge detection :)
    PVector resultantVector = PVector.sub(targetPos, pos);
    resultantVector.normalize();
    resultantVector.mult(speedTemp * random(0.5, 1.5));
    resultantVector.limit(speedTemp);
    vel.set(resultantVector);
  }

  void moveInDirection(PVector dir, float speedMult)        
  {
    float speedTemp = speed * speedMult;
    speedTemp /= frameRate;
    dir.normalize();
    dir.mult(speedTemp);
    dir.limit(speedTemp);
    vel.set(dir);
  }

  ArrayList< PVector > getTransformedVertices()        
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex = new PVector( vertices.get(i).x, vertices.get(i).y );
      vertex.sub( anchorPoint );
      vertex.mult(scale);
      vertex.add( anchorPoint );
      float angle = PVector.angleBetween(new PVector(0, -1), direction); // calculate the angle from vector pointing upwards to the direction
      if (direction.x < 0) angle = -angle;   // if the direction is to the right, rotate right. otherwise if it is to the left rotate to the left
      else if (direction.x == 0) angle = 0;   // if the direction is the same as the vector up, do nothing           
      vertex.rotate(angle);                                                      
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }

  PVector getPos() {          
    return pos;
  }
  void setPos( float x, float y ) {  
    pos.set(x, y);
  }
  void setPos( PVector v ) {  
    pos.set(v);
  }
  int getID() {              
    return ID;
  }
  void setVel(PVector dir) {  
    vel.set(dir);
  }
  String getEntityType() {    
    return type;
  }

  void printDebug()          
  {
    for ( int i = 0; i < vertices.size(); i++ )
    {
      println( "(" + ID + ") vert " + i + "(" + getTransformedVertices().get(i).x + "," + getTransformedVertices().get(i).y + ")");
    }
  }

  private int ID;
  protected float speed = 10;
  protected float scale = 3.0;
  protected float mass = 5;
  protected PVector anchorPoint = new PVector(0, 0);
  protected PVector direction = new PVector(0, 0);
  protected PVector pos = new PVector(0, 0);
  protected PVector vel = new PVector(0, 0);
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected String type = "None";

  private boolean loadFromFile()  // Load data from file: "data\Entity.xml". More info about specification of the file can be found in Docs.
  {
    boolean entityFound = false;

    try
    {
      XML file = loadFile("data/Entities.xml");
      if (file == null) return false;
      XML[] entities = file.getChildren("entity");

      for ( int i = 0; i < entities.length; i++ )
      {
        XML currentChild = entities[ i ];
        // Find a proper entity.
        if ( !currentChild.hasAttribute("type") ) break; // entity doesn't contain "type" attribute - skip.
        if ( currentChild.getString( "type" ).equals(type) )  // correct entity found. Then load it. 
        {
          entityFound = true;
          PVector vertex = new PVector();        // Temporary variable for readability.
          String[] args = {"x", "y"};

          if (validateAttributes(currentChild.getChild("anchor-point"), args))      // Loading anchor point.
          {
            anchorPoint.set(currentChild.getChild("anchor-point").getFloat("x"), currentChild.getChild("anchor-point").getFloat("y"));
          }

          if (validateAttributes(currentChild.getChild("color"), "value"))         // loading color
          {
            String hexColor = currentChild.getChild("color").getString("value");  // Loads color to string. For example: "#FF44BB".
            settings.col = toRGB(hexColor);
          }

          if ( (entities = currentChild.getChildren("vertex")) == null ) return false; // loading vertices
          for ( int j = 0; j < entities.length; j++ )
          {
            XML currentEntity = entities[ j ];
            if ( !validateAttributes(currentEntity, args)) return false;
            vertex.set(currentEntity.getFloat("x") - anchorPoint.x, currentEntity.getFloat("y") - anchorPoint.y);
            vertices.add( new PVector( vertex.x, vertex.y ) );
          }
          return true;
        } // if
      } // for
    } // try
    catch( NullPointerException e ) { 
      println("Some element not found."); 
      return false;
    } // Unknown problem with reading.
    if ( !entityFound ) println("Cannot find \"" + type + "\" entity in file: \"Data\\Entities.xml\"");
    return false;
  } // loadDataFromFile
} // class Entity

// WALL  --------------------------------------------------------------------------------- WALL \\

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

// TRIBUTE  --------------------------------------------------------------------------------- TRIBUTE \\

class Tribute extends Entity
{
  Tribute(int x, int y)
  {
    super("Tribute", x, y);
    health = 100;
    stamina = 100;
  }

  void moveToPos(float x, float y)
  {
    if (stamina < 0)
      speed = 0;
    else
      speed = 10; 
    if (vel.mag() != 0) // if not moving dont use stamina
      stamina -= speed/frameRate;
    super.moveToPos(x, y);
  }

  void update()
  {
    if (health < 0)
      map.removeEntity(getID());
    super.update();
    stamina += 9/frameRate; // 10 is the walking speed, only use a small amount of stamina for walking by replenishing 9 instead of 10
    stamina = clamp(stamina, -20, 100);
  }

  void display()
  {
    super.display();
    textSize(10);
    text(getID(), pos.x - 10, pos.y - 15);
  }

  Boolean isColidingWith(Entity e)
  {
    boolean isCollision = false;
    if (e instanceof Weapon) 
    {
      Weapon eW = (Weapon)e;
      
      if (eW.isAttacking && eW.ownerID != getID())
      {
        if ( getID() != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
        { 
          if ( tmpDebug )
          {
            color rand = color(random(0, 255), random(0, 255), random(0, 255));
            e.settings.col = rand;
            settings.col = rand;
            printDebug();
            tmpDebug = false;
          }
          isCollision = false;
        }
      } else if (!eW.isAttacking)
      {
        isCollision = false;
      }
      return isCollision;
    }

    return isCollision;
  }

  private int health;
  private float stamina;
}