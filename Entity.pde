class entity extends object{
 PVector position,velocity,size;
 float mass;
 int ID;
 String type;
 entity(){
   position = new PVector(0,0);
   velocity = new PVector(0,0);
   size = new PVector(0,0);
   mass = 0;
   ID = 0;
   type = "entity";
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
 String getType(){
  return(type); 
 }
}