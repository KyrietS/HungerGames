//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class Entity
{
  boolean tmpDebug = false;
  Settings settings = new Settings();

  Entity(String _type, int x, int y)
  {
    pos.set(x, y);
    type = _type;
    if ( !loadFromFile() )
      println("Entity: Cannot create an entity object. LoadFromFile failed!");
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
    handleCollisionsBeforeMove();
    pos.add(vel);
    handleCollisionsAfterMove();
  }

  void resolveCollision(Entity e)                                                                  // when a collision happend do this \\
  {
    PVector toTarget = PVector.sub(pos, e.pos);                                                    // find the vector from the centre of target to this centre and divide it by 2, then move at it
    toTarget.div(2);
    moveInDirection(toTarget, 1, false);
  }

  // supporting Methods ---------- Supporting Methods \\

  void handleCollisionsBeforeMove()                                                                // sends the required collision events \\
  {
    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices());                    // gets all the cells in which the vertices are contained
    int[] objectIds = getIdsOfAllEntitiesInCells(inCells);                                         // gets a list of the entity id's from all cells
    Entity[] colidingEntities = getColidingEntities(objectIds);                                    // gets only the coliding entities from the id's from all of the id's
    for (int i = 0; i < colidingEntities.length; i++)
    {
      collisionMesh.addCollisionEvent(this, colidingEntities[i]);                                  // send collision event to the map, to handle it at next draw
    }
  }

  void handleCollisionsAfterMove()                                                                 // adds entities' id to cells in the collision mesh at new position \\
  {
    CollisionCell[] inCells = collisionMesh.getCells(getTransformedVertices());                    // gets all the cells in which the vertices are contained
    addIdToCells(inCells);                                                                         // sends its' to appropriate cells
  }

  int[] getIdsOfAllEntitiesInCells(CollisionCell[] inCells)                                        // gets a list of the entity id's from all cells \\
  {
    int[] objectIds = new int[0];

    for (int i = 0; i < inCells.length; i++)
    {

      for (int j = 0; j < inCells[i].getObjectsIds().length; j++)
      {
        objectIds = (int[])append(objectIds, inCells[i].getObjectsIds()[j]);                       // accumulates all the ids to a single table
      }
    }

    return objectIds;
  }

  Entity[] getColidingEntities(int[] objectIds)                                                    // from a list of ids get a list of entities \\
  {
    Entity[] colidingEntities = new Entity[0];

    for ( int i = 0; i < objectIds.length; i++ )
    {
      if (objectIds[i] == ID) continue;                                                            // if any of the entities is this entity skip to next 
      int index = map.getEntityIndexById(objectIds[i]);                                            
      if (index == -1) continue;                                                                   // if any of the entities dont exist anymore skip to next
      
      Entity currentEntity = map.getEntity(index);
      if (isColidingWith(currentEntity))
      {
        colidingEntities = (Entity[])append(colidingEntities, currentEntity);
      }
      
    }

    return colidingEntities;
  }

  Boolean isColidingWith(Entity e)                                                                 // checks if there is a collision with an entity \\
  {
    boolean isCollision = false;
                                                                                                   // only colide with entities which have collisions enabled and a different collision group etc..
    if (e.collisionsEnabled && e.collisionsGroup != collisionsGroup && ID != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
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

  void addIdToCells(CollisionCell[] inCells)                                                      // adds its id to all the cells provided \\
  {
    for (int i = 0; i < inCells.length; i++) 
    {
      inCells[i].addEntity(ID);
    }
    
  }

  void moveToPos(float x, float y, boolean pointAtVel)                                            // move in direction of the position at max speed, if pointAtVel is true then also point in direction of travel \\
  {

    if ( dist(x, y, pos.x, pos.y) < 0.1)                                                          // if already at the target stop
    {
      vel.set(0, 0);
      return;
    }
    
    PVector targetPos = new PVector(x, y);
    float speedTemp = speed;
    speedTemp/= frameRate;

    targetPos.set(clamp(new PVector(x,y), 0, width, 0, height));                                 // clamp the position to the screen, efficient edge detection :)
    PVector resultantVector = PVector.sub(targetPos, pos);
    resultantVector.normalize();
    resultantVector.mult(speedTemp * random(0.5, 1.5));                                          // multiply the normalized resultant by speed, +- random distortions
    resultantVector.limit(speedTemp);                                                            // limit the magnitude of the vector to the speed
    vel.set(resultantVector);                                                                    // finally set the velocity to the resultant vector
    if (pointAtVel) direction.set(vel);                                                          // point in direction of travel
  }

  void moveInDirection(PVector dir, float speedMult, boolean pointAtVel)                         //  move in general direction vector at speed * multiplier \\
  {
    float speedTemp = speed * speedMult;
    speedTemp /= frameRate;
    
    dir.normalize();
    dir.mult(speedTemp);
    dir.limit(speedTemp);
    vel.set(dir);
    if (pointAtVel) direction.set(vel);
  }

  ArrayList< PVector > getTransformedVertices()                                                  // get global vertices \\
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex = new PVector( vertices.get(i).x, vertices.get(i).y );
      vertex.sub( anchorPoint );
      vertex.mult(scale);
      vertex.add( anchorPoint );
      
      float angle = PVector.angleBetween(new PVector(0, -1), direction);                       // calculate the angle from vector pointing up
      
      if (direction.x < 0) angle = -angle;                                                     // if the direction is to the right, rotate right. otherwise if it is to the left rotate to the left
      else if (direction.x == 0) angle = 0;                                                    // if the direction is the same as the vector up, do nothing   
      
      vertex.rotate(angle);                                                      
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    
    return transformedVertices;
  }
  
  void printDebug()          
  {
    for ( int i = 0; i < vertices.size(); i++ )
    {
      println( "(" + ID + ") vert " + i + "(" + getTransformedVertices().get(i).x + "," + getTransformedVertices().get(i).y + ")");
    }
  }
  
  void deconstruct(){}
  
// ------- setters and getters --------

  PVector getPos(){return pos;}
  
  void setPos( float x, float y ) {pos.set(x, y);}
  
  void setPos( PVector v ) {pos.set(v);}
  
  int getID() {return ID;}
  
  void setVel(PVector dir) {vel.set(dir);}
  
  String getEntityType() {return type;}
  
  protected String type = "None";
  protected int ID;
  protected int collisionsGroup;
  protected int displayPriority = 0;
  protected float speed = 10;
  protected PVector direction = new PVector(0, 0);
  protected PVector pos = new PVector(0, 0);
  protected PVector vel = new PVector(0, 0);
  protected PVector anchorPoint = new PVector(0, 0);
  protected float scale = 3.0;
  protected ArrayList< PVector > vertices = new ArrayList< PVector >();
  protected boolean collisionsEnabled = true;

// ---------- PRIVATE ---------

  private boolean loadFromFile()                                                               // Load data from file: "data\Entity.xml". More info about specification of the file can be found in Docs. \\
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
        if ( !currentChild.hasAttribute("type") ) continue;                                   // entity doesn't contain "type" attribute - skip.
        if ( currentChild.getString( "type" ).equals(type) )                                  // correct entity found. Then load it. 
        {
          entityFound = true;
          PVector vertex = new PVector();                                                     // Temporary variable for readability.
          String[] args = {"x", "y"};

          if (validateAttributes(currentChild.getChild("anchor-point"), args))                // Loading anchor point.
          {
            anchorPoint.set(currentChild.getChild("anchor-point").getFloat("x"), currentChild.getChild("anchor-point").getFloat("y"));
          }

          if (validateAttributes(currentChild.getChild("color"), "value"))                    // loading color
          {
            String hexColor = currentChild.getChild("color").getString("value");              // Loads color to string. For example: "#FF44BB".
            settings.col = toRGB(hexColor);
          }

          if ( (entities = currentChild.getChildren("vertex")) == null ) return false;        // loading vertices
          
          for ( int j = 0; j < entities.length; j++ )
          {
            XML currentEntity = entities[ j ];
            if ( !validateAttributes(currentEntity, args)) return false;
            vertex.set(currentEntity.getFloat("x") - anchorPoint.x, currentEntity.getFloat("y") - anchorPoint.y);
            vertices.add( new PVector( vertex.x, vertex.y ) );
          }
          
          return true;
        }
        
      }
      
    }
    
    catch( NullPointerException e ) {                                                         // Unknown problem with reading.
      println("Some element not found."); 
      return false;
    }                                                                                         
    if ( !entityFound ) println("Cannot find \"" + type + "\" entity in file: \"Data\\Entities.xml\"");
     return false;
     
  }
}

// PHYSICSENTITY ---------------------------------------------------------------- PHYSICSENTITY \\

class physicsEntity extends Entity
{
  physicsEntity(String _type, int x, int y, float _dragCoefficient, float _mass)
  {
    super(_type, x, y);
    dragCoefficient = _dragCoefficient;
    pressed = false;
    speed = 100;
    area = 0;
    mass = _mass;
    momentOfInertia = findMomentOfInertia();
    for (int i = 0; i < vertices.size()-1; i++)                                              // finds the area of the polygon
    {
      area += vertices.get(i).x * vertices.get(i+1).y;
    }
    
    for (int i = 0; i < vertices.size()-1; i++)
    {
      area -= vertices.get(i).y * vertices.get(i+1).x;
    }
    
    area /= 2;
    if (area < 0)
     area *= -1;
    area *= pow(scale, 2);                                                                  // scales area up
  }

  void update()
  {
    applyForce(getFriction(0.68).div(frameRate));
    //applyForce(getAirDrag(1.2).div(frameRate));                                           // air drag not needed so far, would complicate everything

    handleCollisionsBeforeMove();
    vel.add(accel);
    pos.add(vel);
    direction.set(vel);
    accel.set(0, 0);

    angVel += angAccel;
    ang += angVel;
    angAccel = 0;
    if (ang > TWO_PI) ang = 0 + (ang - TWO_PI);                                            // if angle is greater than 360 then start again at 0 and vice versa
    if (ang < 0) ang = TWO_PI - (ang - 0);

    if (vel.mag() <= 0.1) {                                                                // if stopped, allow another apply force (for debugging)
      pressed = false;
    }

    handleCollisionsAfterMove();
  }

  void moveInDirection(PVector dir, float speedMult, boolean pointAtVel)  
  {
  }

  void moveToPos(float x, float y, boolean pointAtVel)                                    // go at pos with max speed (as acceleration) \\
  {
    if (pressed) return;
    PVector toTarget = PVector.sub(new PVector(x, y), pos);
    applyForce(toTarget.normalize().mult(speed));
    pressed = true;
  }
  
  void resolveCollision()
  {
  }

  void applyForce(PVector force)                                                         // applies a force to the object \\
  {
    accel.add(PVector.div(force, mass));
  }
  
  void applyAngForce(float force, float distanceFromAxis)
  {
    float torque =force * distanceFromAxis;
    angAccel += torque/momentOfInertia;
  }
  
  float findMomentOfInertia()
  {
    float sum = 0;
    for(int i = 0; i < vertices.size();i++)
    {
      PVector vertex = vertices.get(i);
      float dist = dist(vertex.x,vertex.y,0,0);
      sum += pow(dist*(mass/vertices.size()),3)/3;
    }
    return sum;
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
      float angle = PVector.angleBetween(new PVector(0, -1), direction);
      if (direction.x < 0) angle = -angle;
      else if (direction.x == 0) angle = 0;
      angle += ang;
      vertex.rotate(angle);     
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }
  
// --------- private ----------

  protected PVector getAirDrag(float density)                                              // gets the force of air drag on the object (not used)\\
  {
    PVector unitVelocity = vel.copy().normalize();
    PVector dragForce = PVector.mult(unitVelocity, -0.5 * density * (pow(vel.mag()/frameRate, 2) * dragCoefficient*area));
    return dragForce;
  }

  protected PVector getFriction(float coefficient)                                         // gets the friction acting on the object \\
  {
    float normalForce = mass * gravity;
    PVector unitVelocity = vel.copy().normalize();
    PVector frictionForce = unitVelocity.mult(normalForce * coefficient); 
    return frictionForce;
  }
  
  protected float getAngFriction(float coefficient)
  {
    float frictionalForce = -angVel * coefficient;
    println("angVel:",angVel,"friction:",frictionalForce);
    return frictionalForce;
  }
  
  boolean pressed;
  protected float dragCoefficient;
  protected float area;
  protected float mass = 1;
  protected float gravity = -2;
  protected float ang = 0;
  protected float angVel = 0;
  protected float angAccel = 0;
  protected float momentOfInertia = 0;;
  protected PVector accel = new PVector(0, 0);
}

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

    PVector vertex = new PVector();
    XML[] verts = data.getChildren("vertex");

    for ( int i = 0; i < verts.length; i++ )
    { 
      if ( !verts[ i ].hasAttribute("x") || !verts[ i ].hasAttribute("y") )         // Current vertex doesn't contain x or y attribute.
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
  ArrayList<Weapon> weapons;

  Tribute(int x, int y)
  {
    super("Tribute", x, y);
    health = 100;
    stamina = 100;
    weapons = new ArrayList();
    displayPriority = 2;
  }

  void moveToPos(float x, float y)
  {
    if (stamina < 0)
      speed = 0;
    else
      speed = 10; 
    if (vel.mag() != 0)                                                           // if not moving dont use stamina
      stamina -= speed/frameRate;
    super.moveToPos(x, y, true);
  }

  void update()
  {
    if (health < 0)
    {
      map.addEntityToRemoveBuffer(this);
    }
    super.update();
    stamina += 9/frameRate;                                                      // 10 is the walking speed, only use a small amount of stamina for walking by replenishing 9 instead of 10
    stamina = clamp(stamina, -20, 100);
  }

  void deconstruct()                                                             // called before death
  {
    dropWeapon();
  }
  void display()
  {
    super.display();
    textSize(10);
    text(getID(), pos.x - 10, pos.y - 15);
  }

  void addWeapon(Weapon w)
  {
    weapons.add(w);
  }

  void dropWeapon()
  {
    if (weapons.size() > 0)
    {
      weapons.get(0).owner = null;
      weapons.remove(0);
    }
  }
  private int health;
  private float stamina;
}