//<>// //<>// //<>// //<>//
class Entity
{
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
  } // Default constructor.

  void display() // Draw an object on the screen.
  {
    settings.applySettings();
    //pushMatrix();
    //translate( pos.x, pos.y );
    //scale(settings.scale);
    beginShape();

    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex( getTransformedVertices().get( i ).x, getTransformedVertices().get(i).y );
    }

    endShape(CLOSE);
    //popMatrix();
  }

  boolean tmpDebug = true;

  void update()
  {
    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices()); // get data about which cells in the collision grid the entity is located in
    //for (int i = 0; i < inCells.length; i++)
    //{
    //  inCells[i].removeEntity(ID); // remove entities location from the cell, and add it back at the end of update() at new position
    //}

    int[] objectIds = new int[0];
    boolean isCollision = false;
    direction.set(vel);
    for (int i = 0; i < inCells.length; i++)
    {
      for (int j = 0; j < inCells[i].getObjectsIds().length; j++)
      {
        objectIds = (int[])append(objectIds, inCells[i].getObjectsIds()[j]);  // accumulate all the nearby objects by collecting data from all cells which the entity is in
      }
    }

    for ( int i = 0; i < objectIds.length; i++ )
    {
      int index = map.getEntityIndexById(objectIds[i]);
      if (index != -1) // if entity is found
      {
        Entity currentEntity = map.getEntity(index);

        if ( ID != currentEntity.getID() && collision.isCollision( currentEntity.getTransformedVertices(), this.getTransformedVertices() ) )
        { 
          PVector toTarget = PVector.sub(pos, currentEntity.pos);  // calculate vector away from the colliding entity
          moveInDirection(toTarget, 5);
          if ( tmpDebug )
          {
            color rand = color(random(0, 255), random(0, 255), random(0, 255));
            currentEntity.settings.col = rand;
            settings.col = rand;
            tmpDebug = false;
          }

          isCollision = true;
          break;
        }
      }
    }

    pos.add(vel);
    inCells = collisionMesh.getCells(getTransformedVertices()); // update in which cells the entity is in
    for (int i = 0; i < inCells.length; i++) 
    {
      inCells[i].addEntity(ID); // add entities location to the cell at new position
    }

    //println(inCells.length);
  }

  void printDebug()
  {
    for ( int i = 0; i < vertices.size(); i++ )
    {
      println( "(" + ID + ") vert " + i + "(" + getTransformedVertices().get(i).x + "," + getTransformedVertices().get(i).y + ")");
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

  void setVel(PVector dir)
  {
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
      if (direction.x > 0)                                             // if the direction is to the right, rotate right. otherwise if it is to the left rotate to the left
        vertex.rotate(angle);
      else if (direction.x < 0)
        vertex.rotate(-angle);
      else {
      }                                                           // if the direction is the same as the vector up, do nothing
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }

  PVector getPos()
  {
    return pos;
  }
  void setPos( float x, float y )
  {
    pos.set(x, y);
  }
  void setPos( PVector v )
  {
    pos.set(v);
  }
  int getID()
  {
    return ID;
  }
  String getEntityType() {
    return type;
  }

  private int ID;
  protected float speed = 10;
  protected float scale = 3.0;
  protected float mass = 5;
  protected PVector anchorPoint = new PVector(0, 0);
  protected PVector direction = new PVector(0, 0);
  protected PVector pos = new PVector(0, 0);              // Position of the object on the map. (Anchor point)
  protected PVector vel = new PVector(0, 0);              // velocity of the object
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected String type = "None";                         // type of the object. If "none", the object is not specified.

  // Load data from file: "data\Entity.xml". More info about specification of the file can be found in Docs.
  private boolean loadFromFile()
  {
    boolean entityFound = false;
    try
    {

      XML file = loadFile("data/Entities.xml");
      if (file == null) {
        return false;
      }

      XML[] entities = file.getChildren("entity");

      for ( int i = 0; i < entities.length; i++ )
      {
        XML currentChild = entities[ i ];
        // Find a proper entity.
        if ( !currentChild.hasAttribute("type") ) {
          break;
        }  // entity doesn't contain "type" attribute - skip.
        if ( currentChild.getString( "type" ).equals(type) ) // correct entity found. Then load it. 
        {
          entityFound = true;
          PVector vertex = new PVector();        // Temporary variable for readability.

          String[] args = {"x", "y"};
          if (validateAttributes(currentChild.getChild("anchor-point"), args))      // Loading anchor point.
          {
            anchorPoint.x = currentChild.getChild("anchor-point").getFloat("x");          
            anchorPoint.y = currentChild.getChild("anchor-point").getFloat("y");
          }

          if (validateAttributes(currentChild.getChild("color"), "value"))         // loading color
          {
            String hexColor = currentChild.getChild("color").getString("value");  // Loads color to string. For example: "#FF44BB".
            settings.col = toRGB(hexColor);           // Loading color.
          }

          if ( (entities = currentChild.getChildren("vertex")) == null ) {
            return false;
          } // loading vertices
          for ( int j = 0; j < entities.length; j++ )
          {
            XML currentEntity = entities[ j ];
            if ( !validateAttributes(currentEntity, args)) {
              return false;
            }
            vertex.set(currentEntity.getFloat("x") - anchorPoint.x, currentEntity.getFloat("y") - anchorPoint.y);
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
      println("Cannot find \"" + type + "\" entity in file: \"Data\\Entities.xml\"");
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

  private int health;
  private float stamina;
}

class Weapon extends Entity
{
  Weapon(int x, int y)
  {
    super("Weapon", x, y);
    scale = 2;

    // calculate the length of the weapon

    float highestY = 0;
    float lowestY = 0;
    for (int i = 0; i < vertices.size(); i++)
    {
      if (vertices.get(i).y < highestY) // find the vertex with highest y coordinate
      {
        highestY = vertices.get(i).y;
      } else if (vertices.get(i).y < lowestY) // find the vertex with lowest y coordinate at the same time
      {
        lowestY = vertices.get(i).x;
      }
    }
    range = (lowestY + (-highestY)) * scale; // get positive length (remember y is flipped in processing)

    // calculate the time needed for each swing

    float arcLength =  ( ( abs(swingInitialAngle) + abs(swingFinalAngle) ) /360 ) * PI * range * 2; // calculate the distance the tip of the weapon will travel (x/360 * circumference of circle)
    swingTimer = new Timer(arcLength/(swingSpeed/frameRate)); // create a timer object, used later to controll swings, with a delay equal to d/(v/frameRate)
    pressed = false;
    
    // set direction to random
    direction.set(PVector.fromAngle(random(0,TWO_PI)));
  }

  void update()
  {
    if (mousePressed && !pressed && ownerID != -1) // temporary, for now all weapons attack with mouse
    {
      startSwing();
      pressed = true;
    }

    if (!isAttacking && ownerID != -1) return;
    // check collisions \\

    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices()); // get data about which cells in the collision grid the entity is located in

    int[] objectIds = new int[0];
    boolean isCollision = false;
    for (int i = 0; i < inCells.length; i++)
    {
      for (int j = 0; j < inCells[i].getObjectsIds().length; j++)
      {
        objectIds = (int[])append(objectIds, inCells[i].getObjectsIds()[j]);  // accumulate all the nearby objects by collecting data from all cells which the entity is in
      }
    }

    for ( int i = 0; i < objectIds.length; i++ )
    {
      int index = map.getEntityIndexById(objectIds[i]);
      if (index != -1) // if entity is found
      {
        Entity currentEntity = map.getEntity(index);

        if ( getID() != currentEntity.getID() && collision.isCollision( currentEntity.getTransformedVertices(), this.getTransformedVertices() ) )
        { 
          if (ownerID == -1) ownerID = currentEntity.getID();

          if ( tmpDebug )
          {
            color rand = color(random(0, 255), random(0, 255), random(0, 255));
            currentEntity.settings.col = rand;
            settings.col = rand;
            tmpDebug = false;
          }

          isCollision = true;
          break;
        }
      }
    }
    // check timers

    if (!isAttacking) return;

    swingTimer.update(); // set the current time in the timer to millis()

    if (swingTimer.passed()) // if the swing ends
    {
      isAttacking = false; 
      pressed = false;
    }
  }

  void display()
  {
    if (!isAttacking && ownerID != -1) return;
    if (ownerID != -1)
    {
      pos.set(map.getEntity(map.getEntityIndexById(ownerID)).pos);
    }
    super.display();
  }

  void startSwing()
  {
    swingTimer.set(); // zero the timer
    isAttacking = true;
  }

  float getAngleAtTime(int time)
  {
    float angle = (time/swingTimer.delay) * (abs(swingInitialAngle) + abs(swingFinalAngle));  // calculate the angle at particular time of swing. TimeNow/TimeTotal = AngleNow/AngleTotal therefore AngleNow = TimeNow/TimeTotal * AngleTotal
    return angle;
  }

  ArrayList< PVector > getTransformedVertices()
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    if(ownerID != -1)
      direction.set(map.getEntity(map.getEntityIndexById(ownerID)).direction); // set direction to parents direction, every rotation will be relative to parent
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex = new PVector( vertices.get(i).x, vertices.get(i).y );
      vertex.sub( anchorPoint );
      vertex.mult(scale);
      vertex.add( anchorPoint );
      float angle = PVector.angleBetween(new PVector(0, -1), direction);               // calculate the angle from vector pointing upwards to the screen
      if (isAttacking) angle += getAngleAtTime(swingTimer.getTime()) + swingFinalAngle; // if swinging add the angle of rotation at current point of time relative to final angle due
      if (direction.x > 0)                                                             // if the direction is to the right, rotate right. otherwise if it is to the left rotate to the left
        vertex.rotate(angle);
      else if (direction.x < 0)
        vertex.rotate(-angle);
      else {
      }                                   // if the direction is the same as the vector up, do nothing
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }

  protected Timer swingTimer;
  boolean pressed; // temporary variable for testing
  protected float range;                    // the range of the weapon from point 0,0 on the parent object - the anchor point on weapons should be kept at the handle
  protected float effectiveRange = 0;       // from the 0,0 point on the parent object the distance to the 'blade' of the weapon, at this point and further the weapon is the most effective
  protected float power = 0;                // the main attribute deciding about actuall damage
  protected float swingSpeed = 0.2;           // the velocity of the swing
  protected float swingInitialAngle = PI/4;        // the starting angle of the swing in radians
  protected float swingFinalAngle = -PI/4;          // the final angle of swing in radians
  protected int ownerID = -1;               // the ID of the parent object
  protected boolean isAttacking = false;    // is the weapon in use
  protected float[] animationAngles;        // stores the angle of rotation in relation to the direction of the parent, each index is one frame
}