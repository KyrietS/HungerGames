class entity{
 PVector position,velocity,size;
 float mass;
 int ID;
 entity(){
   position = new PVector(0,0);
   velocity = new PVector(0,0);
   size = new PVector(0,0);
   mass = 0;
   ID = 0;
 }
 float clamp(float value,float min, float max){
   if(value < min){value = min;}
   else if(value > max){value = max;}
   return(value);
 }
 float get2Dlocation(PVector position3D, int width2D){
   return(position3D.x + width2D * position3D.y);
 }
 void addPositionToCollisionMesh(PVector pos, PVector meshSize, int id){
   PVector positionAtMesh = new PVector(floor(width / meshSize.x),floor(height/meshSize.y));
   collisionMesh.collisionBoxes[get2Dlocation(positionAtMesh,meshSize)].entities.add(entitiesList.get(id));
 }
 PVector getSize(){
   return(size); 
 }
 void setVelocity(PVector vel){
   velocity.set(vel);
 }
 PVector getVelocity(){
   return(velocity); 
 }
 void setPosition(PVector pos){
   position.set(pos); 
 }
 PVector getPosition(){
   return(position); 
 }
 float getMass(){
   return mass; 
 }
 int getID(){
   return(ID); 
 }
}