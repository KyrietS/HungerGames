class collisionMeshClass{
  PVector size;
  collisionBox[] collisionBoxes;
  collisionMeshClass(PVector Size){
    PVector size = Size;
    collisionBoxes = new collisionBox[0];
  }
  void setup(){
    int counter = 0;
    float xDivision = width / size.x;
    float yDivision = height/ size.y;
    for(int i = 0; i <= height - yDivision; i += yDivision){
     for(int j = 0; j <= width - xDivision; j += xDivision){
       PVector leftUp = new PVector(j,i);
       PVector rightDown = new PVector(j + xDivision,i + yDivision);
       collisionBoxes[counter] = new collisionBox(counter,leftUp,rightDown);
     }
    }
  }
  void draw(){
    for (int i = 0; i < collisionBoxes.length; i++) {
      collisionBoxes[i].draw();
    }
  }
  void clear() {
    for (int i = 0; i < collisionBoxes.length; i++) {
      collisionBoxes[i].clearEntities();
    }
  }
  void update() {
    for (int i = 0; i < collisionBoxes.length; i++) {
      collisionBoxes[i].update();
    }
  }
  PVector getSize(){
   return(size); 
  }
}

class collisionBox{
  PVector leftUpVertex,rightDownVertex;
  float activity, ID;
  ArrayList<entity> entities; // to allow easier management of collisions, sacrificing efficiency
  collisionBox(int id, PVector LeftUpVertex, PVector RightDownVertex){
    ID = id;
    activity = 0;
    leftUpVertex = LeftUpVertex;
    RightDownVertex = rightDownVertex;
    entities = new ArrayList<entity>(0);
  }
  int countEntities(){
    return(entities.size()); 
  }
  void clearEntities(){
    for(int i = entities.size() - 1; i >= 0; i--){
      entities.remove(i); 
    }
  }
  void setActivity(float Activity){
    activity = Activity; 
  }
  float getActivity(){
    return(activity);
  }
  void update(){
   setActivity(clamp(getActivity() * (0.9/frameRate),0,100));
   if(countEntities() > 0)
   {
     for(int i = 0; i < countEntities(); i++)
     {
       if(entities.get(i).isTribute() == true)
       {
          entitiesList[entities.get(i).getID()].checkCollisions(entities);
       }
     }
   }
  }
  void draw(){
    fill(2 * activity,0,0,100); // to allow debuging of heightmap, the more active the more red it is 
    rect(leftUpVertex.x,leftUpVertex.y,rightDownVertex.x,rightDownVertex.y);
  }
}