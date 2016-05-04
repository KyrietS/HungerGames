class object
{
  object()
  {
    
  }
  
 float clamp(float value,float min, float max)
 {
   if(value < min){value = min;}
   else if(value > max){value = max;}
   return(value);
 }
 int get2Dlocation(PVector position3D, int width2D)
 {
   return(int(position3D.x) + width2D * int(position3D.y));
 }
 void addPositionToCollisionMesh(PVector pos, PVector meshSize, int id)
 {
   PVector positionAtMesh = new PVector(floor(width / pos.x),floor(height/pos.y));
   collisionMesh.collisionBoxes[get2Dlocation(positionAtMesh,int(meshSize.x))].entities.add(entitiesList.get(id));
 }
 int[] randomize (int[] array)
 {
    for (int i=0; i < array.length; i++) 
    {
      int temp = array[i]; 
      int x = (int)random(0, array.length);     
      array[i]=array[x]; 
      array[x]=temp; 
    }
    return(array);
  }
}