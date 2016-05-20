// WEAPON \\ 
class Weapon extends physicsEntity
{
  boolean attacked;
  Weapon(int x, int y)
  {
    super("Weapon", x, y, 1, 5);
    scale = 3;
    displayPriority = 1;
  }

  void update()
  {
    super.update();
    if (owner != null)
    {
      pos.set(owner.pos);
      if (mousePressed && !isAttacking)
      {
        startAttack();
      }
    }
    applyAngForce(getAngFriction(0.3), range);
    // attacked = false, isAttacking = false to add
  }

  void display()
  {
    super.display();
  }

  void startAttack()
  {
    isAttacking = true;
  }

  void resolveCollision(Entity e)
  {
    if ( !(e instanceof Weapon) )
    {
      if ( e instanceof Tribute )
      {      
        Tribute eT = (Tribute)e;
        if (owner != null && isAttacking && !attacked && e.getID() != owner.getID())
        {
          attackTribute(eT);
          attacked = true;
        } else if (owner == null)
        {
          owner = e;
          collisionsGroup = owner.collisionsGroup;
          eT.addWeapon(this);
        }
      }
    } else
    {
    }
  }

  void attackTribute(Tribute e)
  {
    e.health -= power;
  }


  Boolean isColidingWith(Entity e)
  {
    boolean isCollision = false;

    if (owner != null)
    {
      if (owner.getID() == e.getID()) return false;
    }
    if (e.collisionsEnabled && e.collisionsGroup != collisionsGroup && getID() != e.getID() && collision.isCollision( e.getTransformedVertices(), this.getTransformedVertices() ) )
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

  protected float range;                    // the range of the weapon from point 0,0 on the parent object - the anchor point on weapons should be kept at the handle
  protected float effectiveRange = 0;       // from the 0,0 point on the parent object the distance to the 'blade' of the weapon, at this point and further the weapon is the most effective
  protected float power = 10;                // the main attribute deciding about actuall damage
  protected Entity owner = null;              // the owner
  protected boolean isAttacking = false;    // is the weapon in use
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

    direction.set(PVector.fromAngle(random(0, TWO_PI)));
  }

  void update()
  {
    super.update();
    if(owner!= null)direction.set(owner.direction);
    applyAngForce(round(clamp(targetAng-ang,1,-1))/frameRate, range);

  }
  void startAttack()
  {
    isAttacking = true;
    if (targetAng == swingMaxAngle) 
    {
      targetAng = swingMinAngle;
      return;
    }
    if (targetAng == swingMinAngle) 
    {
      targetAng = swingMaxAngle;
      return;
    }
  }
  void attackTribute(Tribute e)
  {
    super.attackTribute(e);
  }

  void whenNotColiding()
  {
  }
  

  protected float swingMaxAngle = -PI/2;        // the starting angle of the swing in radians
  protected float swingMinAngle = PI/2;          // the final angle of swing in radians
  protected float targetAng = swingMinAngle;
  protected float speed = 5;
  protected int tipVertex;             // the position of the tip vertex in the array vertices, for later calculations of realistic bouncing
}