// WEAPON \\ 
class Weapon extends physicsEntity
{
  Weapon(int x, int y)
  {
    super("Weapon1", x, y, 5);
    scale = 2;
  }
  
  void update()
  {
    super.update();
    if (owner != null)
      pos.set(owner.getPos());
    else
    {
      angVel = 0;
      angAccel = 0;
    }
    if(mousePressed && canAttack && owner != null)
    {
      startAnimation();
      canAttack = false;
    }
    else
    {
      if(angVel < 0.5)
      {
       canAttack = true; 
      }
    }
  }

  void resolveCollision(Entity e)
  {

    if (e instanceof Tribute)
    {

      if (owner == null)
      {
        Tribute eT = (Tribute)e;
        if (eT.weapons.size() < 1)
        {
          owner = eT;
          collisionsGroup = eT.collisionsGroup;
          eT.addWeapon(this);
        }
      } else
      {
        Tribute eT = (Tribute)e;
        attackTribute(eT);
      }
    }
  }

  void attackTribute(Tribute eT)
  {
    eT.health -= power;
  }
  
  void startAnimation()
  {

  }
  protected boolean canAttack = true;
  protected Tribute owner = null;
  protected float power = 5;
  protected float speed = 0.3;
}

class MeleeWeapon extends Weapon
{
  MeleeWeapon(int x, int y)
  {
    super(x, y);
    weaponLength = getWeaponLength();
  }

  void update()
  {
    if (owner != null)
    {
      turnToAngle(getClosestAngle(),speed/frameRate,weaponLength);
      applyAngForce(getAngFriction(0.01)/frameRate, weaponLength);
      direction.set(owner.direction);
    }
    super.update();
  }

  float getWeaponLength()
  {
    float maxY = 0;
    for (int i = 0; i < vertices.size(); i++)
    {
      if (vertices.get(i).y < maxY)
      {
        maxY = vertices.get(i).y;
      }
    }
    return -maxY * scale;
  }
  
  void resolveCollision(Entity e)
  {
    super.resolveCollision(e);
    angVel = -angVel * 1.02;
    if(e != null && owner != null)
      owner.resolveCollision(e);
    
  }
  
  float getClosestAngle()
  {
    float target = 0;
    if(abs(ang - minAng) < abs(ang - maxAng)) target = minAng;
    else target = maxAng;
    return(target);
  }
  
  void startAnimation()
  {
    super.startAnimation();
    if( ang <= PI) applyAngForce(-speed /10,weaponLength);
    else applyAngForce(speed/10, weaponLength);
  }

  protected float weaponLength = 0;
  protected float maxAng = radians(90);
  protected float minAng = radians(270);
}