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
    displayPriority = 1;
  }

  void update()
  {
    animationTimer.update();
    if (isAttacking && animationTimer.passed())
    {
      isAttacking = false; 
      pressed = false;
    }

    if (mousePressed && !pressed) 
    {
      if (owner != null)
        startAnimation();
      pressed = true;
    }

    if (!isAttacking)
      collisionsEnabled = false;
    else
      collisionsEnabled = true; 

    if (owner == null || isAttacking)
    {
      handleCollisionsBeforeMove();
      handleCollisionsAfterMove();
    }
    if(owner != null)
    {
      pos.set(owner.getPos());
    }
  }

  void display()
  {
    super.display();
  }

  void resolveCollision(Entity e) // overides default action
  {
    if ( !(e instanceof Weapon) )
    {
      Tribute eT = (Tribute)e;
      if (owner == null && e instanceof Tribute && eT.weapons.size() < 1) 
      {
        owner = e;
        collisionsGroup = owner.collisionsGroup;

        eT.addWeapon(this);
      }
      if ( e instanceof Tribute && owner != null && e.getID() != owner.getID() && isAttacking && !attacked)
      {
        attackTribute(eT);
        attacked = true;
      }
    }
  }

  void attackTribute(Tribute e)
  {
    e.health -= power;
  }

  void startAnimation()
  {
    animationTimer.set(); // zero the timer
    isAttacking = true;
    attacked = false;
  }
  
  void setAnimationVelocity(float velocity, float distance)
  {
    animationTimer.setDelay(distance/(velocity/frameRate));
  }
  
  Boolean isColidingWith(Entity e)
  {
    boolean isCollision = false;
    if (owner != null && e.getID() != owner.getID())
    {
      if (getID() != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
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
    } else if (owner == null)
    {
      if (getID() != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
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
    }
    whenNotColiding();
    return isCollision;
  }
  void whenNotColiding()
  {
    
  }
  ArrayList< PVector > getTransformedVertices()
  {
    PVector vertex;
    ArrayList< PVector > transformedVertices = new ArrayList< PVector >();
    if (owner != null)
      direction.set(owner.direction); // set direction to parents direction, every rotation will be relative to parent
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
  protected float animationSpeed = 0.1;       // speed in pixels per second (current)
  protected float defaultAnimationSpeed = 0.1; // default
  protected float range;                    // the range of the weapon from point 0,0 on the parent object - the anchor point on weapons should be kept at the handle
  protected float effectiveRange = 0;       // from the 0,0 point on the parent object the distance to the 'blade' of the weapon, at this point and further the weapon is the most effective
  protected float power = 10;                // the main attribute deciding about actuall damage
  protected Entity owner = null;              // the owner
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
    if(!isAttacking)
     angleOffset = 0;
    else
     angleOffset = getAngleAtTime(animationTimer.getTime());
  }

  void attackTribute(Tribute e)
  {
    super.attackTribute(e); 
  }
  
  void whenNotColiding()
  {
  }
  
  float calculateArcLength(float initialAngle, float finalAngle)
  {
    return( ( abs(initialAngle) + abs(finalAngle) ) /360 ) * PI * range * 2;
  }
  
  float getAngleAtTime(int time)
  {
    float angle = (((pow((time/animationTimer.delay) ,0.8))) * ((abs(swingInitialAngle) + abs(swingFinalAngle))));  // calculate the angle at particular time of swing. TimeNow/TimeTotal = AngleNow/AngleTotal therefore AngleNow = TimeNow/TimeTotal * AngleTotal
    return angle - swingInitialAngle;
  }

  protected float swingInitialAngle = PI/1.5;        // the starting angle of the swing in radians
  protected float swingFinalAngle = -PI/2;          // the final angle of swing in radians
  protected int tipVertex;             // the position of the tip vertex in the array vertices, for later calculations of realistic bouncing
}