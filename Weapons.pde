// WEAPON \\
class Weapon extends Entity
{
  boolean pressed;
  
  Weapon(int x, int y)
  {
    super("Weapon", x, y);
    scale = 2;
    animationTimer = new Timer(animationLength);
  }

  void update()
  {
    if (mousePressed && !pressed && ownerID != -1) // temporary, for now all weapons attack with mouse
    {
      pressed = true;
    }

    if (isAttacking || ownerID == -1)
    {
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

          if ( getID() != currentEntity.getID() && currentEntity.getID() != ownerID && collision.isCollision( currentEntity.getTransformedVertices(), this.getTransformedVertices() ) )
          { 
            if (!getClassName(currentEntity).equals("Weapon"))
            {
              if (ownerID == -1) ownerID = currentEntity.getID();
            }
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
      inCells = collisionMesh.getCells(getTransformedVertices()); // update in which cells the entity is in
      for (int i = 0; i < inCells.length; i++) 
      {
        inCells[i].addEntity(getID()); // add entities location to the cell at new position
      }
    }
    // check timers

    if (!isAttacking) return;

    animationTimer.update(); // set the current time in the timer to millis()

    if (animationTimer.passed()) // if the swing ends
    {
      isAttacking = false; 
      pressed = false;
    }
  }

  void display()
  {
  }

  protected Timer animationTimer;
  protected float animationLength;          // calculated in constructor, time in milliseconds for the animation to complete
  protected float animationSpeed = 1;       // speed in pixels per second 
  protected float range;                    // the range of the weapon from point 0,0 on the parent object - the anchor point on weapons should be kept at the handle
  protected float effectiveRange = 0;       // from the 0,0 point on the parent object the distance to the 'blade' of the weapon, at this point and further the weapon is the most effective
  protected float power = 0;                // the main attribute deciding about actuall damage
  protected int ownerID = -1;               // the ID of the parent object
  protected boolean isAttacking = false;    // is the weapon in use
}

class MeleeWeapon extends Weapon
{
  MeleeWeapon(int x, int y)
  {
    super(x, y);
    scale = 2;

    // calculate the length of the weapon

    float highestY = 0;
    float lowestY = 0;
    for (int i = 0; i < vertices.size(); i++)
    {
      if (vertices.get(i).y < highestY) // find the vertex with highest y coordinate
      {
        highestY = vertices.get(i).y;
        tipVertex = i;
      } else if (vertices.get(i).y < lowestY) // find the vertex with lowest y coordinate at the same time
      {
        lowestY = vertices.get(i).x;
      }
    }
    range = (lowestY + (-highestY)) * scale; // get positive length (remember y is flipped in processing)

    // calculate the time needed for each swing

    float arcLength =  ( ( abs(swingInitialAngle) + abs(swingFinalAngle) ) /360 ) * PI * range * 2; // calculate the distance the tip of the weapon will travel (x/360 * circumference of circle)
    animationTimer = new Timer(arcLength/(animationSpeed/frameRate)); // create a timer object, used later to controll swings, with a delay equal to d/(v/frameRate)
    pressed = false;

    // set direction to random

    direction.set(PVector.fromAngle(random(0, TWO_PI)));
  }

  void update()
  {
    if (mousePressed && !pressed && ownerID != -1) // temporary, for now all weapons attack with mouse
    {
      startSwing();
      pressed = true;
    }

    if (isAttacking || ownerID == -1)
    {
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

          if ( getID() != currentEntity.getID() && currentEntity.getID() != ownerID && collision.isCollision( currentEntity.getTransformedVertices(), this.getTransformedVertices() ) )
          { 
            if (!getClassName(currentEntity).equals("Weapon"))
            {
              if (ownerID == -1) ownerID = currentEntity.getID();
            }
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
      inCells = collisionMesh.getCells(getTransformedVertices()); // update in which cells the entity is in
      for (int i = 0; i < inCells.length; i++) 
      {
        inCells[i].addEntity(getID()); // add entities location to the cell at new position
      }
    }
    // check timers

    if (!isAttacking) return;

    animationTimer.update(); // set the current time in the timer to millis()

    if (animationTimer.passed()) // if the swing ends
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
    animationTimer.set(); // zero the timer
    isAttacking = true;
  }

  float getAngleAtTime(int time)
  {
    float angle = (time/animationTimer.delay) * (abs(swingInitialAngle) + abs(swingFinalAngle));  // calculate the angle at particular time of swing. TimeNow/TimeTotal = AngleNow/AngleTotal therefore AngleNow = TimeNow/TimeTotal * AngleTotal
    return angle;
  }

  ArrayList< PVector > getTransformedVertices()
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    if (ownerID != -1)
      direction.set(map.getEntity(map.getEntityIndexById(ownerID)).direction); // set direction to parents direction, every rotation will be relative to parent
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex = new PVector( vertices.get(i).x, vertices.get(i).y );
      vertex.sub( anchorPoint );
      vertex.mult(scale);
      vertex.add( anchorPoint );
      float angle = PVector.angleBetween(new PVector(0, -1), direction);               // calculate the angle from vector pointing upwards to the screen
      if (direction.x < 0) angle = -angle;
      else if (direction.x == 0) angle = 0; // if the direction is to the right, rotate right. otherwise if it is to the left rotate to the left
      if (isAttacking) angle += getAngleAtTime(animationTimer.getTime()) + swingFinalAngle; // if swinging add the angle of rotation at current point of time relative to final angle due                                                     
      vertex.rotate(angle);                            
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }

  boolean pressed; // temporary variable for testing
  protected float swingInitialAngle = PI/4;        // the starting angle of the swing in radians
  protected float swingFinalAngle = -PI/4;          // the final angle of swing in radians
  protected int tipVertex;             // the position of the tip vertex in the array vertices, for later calculations of realistic bouncing
}