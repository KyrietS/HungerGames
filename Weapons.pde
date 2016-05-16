// WEAPON \\ 
class Weapon extends Entity
{
  boolean pressed;
  boolean attacked;
  
  Weapon(int x, int y)
  {
    super("Weapon", x, y);
    scale = 3;
    animationTimer = new Timer(animationLength);
  }

  void update()
  {
    //if(map.getEntityIndexById(ownerID) == -1) ownerID = -1;
    animationTimer.update();
    if (isAttacking)
    {
      if (animationTimer.passed())
      {
        isAttacking = false; 
        pressed = false;
      }
    }

    if (mousePressed && !pressed && ownerID != -1) 
    {
      startAnimation();
      pressed = true;
    }

    if (!isAttacking && ownerID != -1)
      collisionsEnabled = false;
    else
      collisionsEnabled = true; 

    if (collisionsEnabled)
    {
      handleCollisionsBeforeMove();
      if (ownerID != -1)
      {
        pos.set(map.getEntity(map.getEntityIndexById(ownerID)).pos);
      }
      handleCollisionsAfterMove();
    }
  }

  void display()
  {
    if (!isAttacking && ownerID != -1) return;
    super.display();
  }

  void resolveCollision(Entity e) // overides default action
  {
    if ( !(e instanceof Weapon) )
    {
      Tribute eT = (Tribute)e;
      if (ownerID == -1 && e instanceof Tribute && eT.weaponIds.size() < 1) 
      {
        ownerID = e.getID();
        collisionsGroup = e.collisionsGroup;
        
        eT.addWeapon(getID());
      }
      if ( e instanceof Tribute && ownerID != -1 && e.getID() != ownerID && isAttacking && !attacked)
      {
        eT.health -= power;
        attacked = true;
      }
    }
  }

  void startAnimation()
  {
    animationTimer.set(); // zero the timer
    isAttacking = true;
    attacked = false;
  }

  Boolean isColidingWith(Entity e)
  {
    boolean isCollision = false;
    if (e.getID() != ownerID && getID() != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
    { 
      if ( tmpDebug )
      {
        color rand = color(random(0, 255), random(0, 255), random(0, 255));
        e.settings.col = rand;
        settings.col = rand;
        tmpDebug = false;
      }
      isCollision = true;
    }
    return isCollision;
  }

  ArrayList< PVector > getTransformedVertices()
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    if (ownerID != -1)
    {
       direction.set(map.getEntity(map.getEntityIndexById(ownerID)).direction); // set direction to parents direction, every rotation will be relative to parent
    }
    for ( int i = 0; i < vertices.size(); i++ )
    {
      vertex = new PVector( vertices.get(i).x, vertices.get(i).y );
      vertex.sub( anchorPoint );
      vertex.mult(scale);
      vertex.add( anchorPoint );
      float angle = PVector.angleBetween(new PVector(0, -1), direction);
      if (direction.x < 0) angle = -angle;
      else if (direction.x == 0) angle = 0;
      if (isAttacking) angle += angleOffset;
      vertex.rotate(angle);     
      vertex.add( pos );
      transformedVertices.add( new PVector( vertex.x, vertex.y ) );
    }
    return transformedVertices;
  }

  protected Timer animationTimer;
  protected float animationLength;          // calculated in constructor, time in milliseconds for the animation to complete
  protected float animationSpeed = 0.1;       // speed in pixels per second 
  protected float range;                    // the range of the weapon from point 0,0 on the parent object - the anchor point on weapons should be kept at the handle
  protected float effectiveRange = 0;       // from the 0,0 point on the parent object the distance to the 'blade' of the weapon, at this point and further the weapon is the most effective
  protected float power = 10;                // the main attribute deciding about actuall damage
  protected int ownerID = -1;               // the ID of the parent object
  protected boolean isAttacking = false;    // is the weapon in use
  protected float angleOffset =0;
  protected PVector posOffset = new PVector(0, 0);
}

class MeleeWeapon extends Weapon
{
  MeleeWeapon(int x, int y)
  {
    super(x, y);
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
    animationTimer.setDelay( arcLength/(animationSpeed/frameRate) ); // create a timer object, used later to controll swings, with a delay equal to d/(v/frameRate)
    pressed = false;

    direction.set(PVector.fromAngle(random(0, TWO_PI)));
  }

  void update()
  {
    super.update();
    angleOffset = getAngleAtTime(animationTimer.getTime());
  }

  float getAngleAtTime(int time)
  {
    float angle = (time/animationTimer.delay) * (abs(swingInitialAngle) + abs(swingFinalAngle));  // calculate the angle at particular time of swing. TimeNow/TimeTotal = AngleNow/AngleTotal therefore AngleNow = TimeNow/TimeTotal * AngleTotal
    return angle + swingFinalAngle;
  }

  protected float swingInitialAngle = PI/4;        // the starting angle of the swing in radians
  protected float swingFinalAngle = -PI/4;          // the final angle of swing in radians
  protected int tipVertex;             // the position of the tip vertex in the array vertices, for later calculations of realistic bouncing
}