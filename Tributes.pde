
class tribute extends entity 
{
  static int tributesCount = 1;
  String name;
  float speed, health, zPos;
  boolean alive;
  weapon[] inventory;
  timer timerPickup, timerRecoil;

  tribute(float x, float y, String Name, int id) 
  {
    type = "tribute";
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    size = new PVector(3.5, 3.5);
    name = Name;
    ID = id;
    alive = true;
    health = 100;
    mass = 0.3;
    inventory = new weapon[]{new fists()};
    timerPickup = new timer(1000);
    timerRecoil = new timer(1000);
    tributesCount++;//get z height
  }

  float velocityDueToTerrain(float speed) 
  {
    PVector pos = getPosition();
    PVector vel = getVelocity();
    float mass = getMass(); 
    PVector posNext = PVector.add(pos, vel);
    float heightHere = getHeight(pos);
    float heightNext = getHeight(posNext);
    float opposite = heightNext - heightHere;
    float adj = dist(pos.x, pos.y, posNext.x, posNext.y);
    float theta = atan(opposite/adj);
    float ForceParallel = mass * -9.8 * (sin(theta));
    speed = speed + (ForceParallel/(frameRate));
    return(speed);
  }
  void moveTowardsWithSpeed(PVector targetPos, float speed) 
  {
    if (targetPos == position) 
      return;

    targetPos.x = clamp(targetPos.x, 0, width);
    targetPos.y = clamp(targetPos.y, 0, height);
    speed = speed/frameRate;
    speed = velocityDueToTerrain(speed);
    PVector resultantVel = PVector.sub(targetPos, position);
    resultantVel.normalize();
    resultantVel.mult(speed);
    resultantVel.limit(speed);
    setVelocity(targetPos);
  }
  void moveAtVector(PVector targetPos, float speed) 
  {
    if (targetPos == getPosition())
      return;

    speed = speed / frameRate;
    speed = velocityDueToTerrain(speed);
    PVector resultantVel = targetPos.normalize();
    resultantVel.mult(speed);
    resultantVel.limit(speed);
    setVelocity(resultantVel);
  }
  float getHealth() 
  {
    return(health);
  }
  boolean isAlive(float health) 
  {
    if (health <= 0) 
      return(false);
    else 
    return(true);
  }
  void setAlive(boolean bool) 
  {
    alive = bool;
  }
  void update() 
  {
    if (!isAlive(getHealth())) 
      return;

    timerPickup.update();
    timerRecoil.update();

    setPosition(getPosition().add(getVelocity()));
    addPositionToCollisionMesh(getPosition(), collisionMesh.getSize(), getID());
  }
  String getTributesName() 
  {
    return(name);
  }
  void drawTribute() 
  {
    PVector pos = getPosition();
    fill(250);
    ellipse(pos.x, pos.y, getSize().x, getSize().x);
    textSize(8);
    text(getTributesName(), pos.x - 5, pos.y -5);
  }
  void checkCollisions(ArrayList<entity> entities) 
  {
    float distance; 
    PVector pos = getPosition();
    entity currentEntity;
    for (int i = 0; i < entities.size(); i++) 
    {
      currentEntity = entities.get(i);
      distance = dist(currentEntity.position.x, currentEntity.position.y, pos.x, pos.y);
      if (distance < currentEntity.getSize().x) // change to longest side later
      {
         if(currentEntity.getType() == "tribute")
         {
           PVector direction = PVector.sub(getPosition(), currentEntity.position);
           direction.normalize();
           moveAtVector(direction,10);
         }
         else
         {
           weapon currentWeapon = (weapon)entitiesList.get(currentEntity.getID());
           currentWeapon.pickUp(ID);
         }
      }
    }
  }
  void attackTribute(int TargetID) 
  {
    if (TargetID == ID) 
      return;
    entity target = entitiesList.get(TargetID);
    float dist = dist(position.x, position.y, target.position.x, target.position.y) + (1.5*size.x);
    weapon primaryWeapon = inventory[0];
    float range = primaryWeapon.range;
    float effective_range = primaryWeapon.effectiveRange;
    float power = primaryWeapon.power;
    float weight = primaryWeapon.weight;
    float accuracy = primaryWeapon.accuracy;
    float damage = power;
    float delay = primaryWeapon.speed * 1000 + random(-1000, 1000);
    timerRecoil.delay = delay;
    boolean hit;
    if (dist <= range && timerRecoil.passed()) 
    {
      timerRecoil.set();
      int a = round(random(0, 100));
      if (a <= accuracy) 
      {
        println(dist);
        hit = true;
      } else 
      {
        hit = false;
      }
      if (hit) 
      {
        if (dist > effective_range) 
        {
          damage *= 1.2;
        } else 
        {
          damage *= 0.4;
        }
        entitiesList.get(TargetID).health -= damage;
      }
    }
  }
}