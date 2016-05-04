class weapon extends entity{
   float range,effectiveRange,power,weight,accuracy,speed;
   int ownerID;
   String name;
   boolean isPickedUp;
   weapon(int id,PVector pos,PVector Size, String Name, float Range, float EffectiveRange, float Power, float Weight, float Accuracy, float Speed ){
     type = "weapon";
     ID = id;
     range = Range + 3.5; // turned scalling off, to be done later;
     effectiveRange = EffectiveRange + 3.5;
     power = Power;
     weight = Weight;
     name = Name;
     accuracy = Accuracy;
     position = pos;
     size = Size;
     speed = Speed;
     ownerID = ID;
     isPickedUp = false;
   }
  void pickUp(int ownerid){
     isPickedUp = true;
     ownerID = ownerid;
  }
  void drop(){
     isPickedUp = false;
     position = entitiesList.get(ownerID).getPosition();
     ownerID = ID;
  }
  void draw(){
     if(isPickedUp){return;}
     fill(255,0,0);
     rect(getPosition().x,getPosition().y,getSize().x,getSize().y);  
  }
  void update(){
     if(isPickedUp){return;}
     addPositionToCollisionMesh(getPosition(),collisionMesh.getSize(),getID());
  }
}

class fists extends weapon {
  fists() {
    super(-1, new PVector(0,0), new PVector(5,5),"fists", 3, 0, 1, 0.1, 97,1);//id, name, range, effective range, power, weight, accuracy
  }
}

class dagger extends weapon {
  dagger(int id) {
    super(id, new PVector(0,0), new PVector(5,5), "dagger", 5, 0, 15, 0.2, 95,1);
  }
}

class sword extends weapon {
  sword(int id) {
    super(id,new PVector(0,0), new PVector(5,5), "sword", 9, 3.5, 33, 1, 70,1.5);
  }
}

class long_sword extends weapon {
  long_sword(int id) {
    super(id,new PVector(0,0), new PVector(5,5), "long sword", 12, 7, 50, 2, 60,3);
  }
}

class spear extends weapon {
  spear(int id) {
    super(id,new PVector(0,0), new PVector(5,5), "spear", 19, 16, 40, 1, 95,1);
  }
}

class bow extends weapon {
  bow(int id) {
    super(id,new PVector(0,0), new PVector(5,5), "bow", 100, 33, 33, 1, 70,5);
  }
}
}