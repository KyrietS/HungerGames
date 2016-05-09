Mesh mesh;
PVector centre;
void setup()
{
  size(600,600);
  centre = new PVector(width/2, height/2);
  mesh = new Mesh();
}

void draw()
{
  background(255);
  mesh.update();
  mesh.display();

  if(keyPressed && keyCode == LEFT)
  { 
   mesh.offset.x -= -2;
  }
  if(keyPressed && keyCode == RIGHT)
  { 
   mesh.offset.x += -2;
  }
  if(keyPressed && keyCode == UP)
  { 
   mesh.offset.y -= -2;
  }  
  if(keyPressed && keyCode == DOWN)
  { 
   mesh.offset.y += -2;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  mesh.scale += e*2;
  if (mesh.scale % 2 != 0)
    mesh.scale++;
  mesh.scale = clamp(mesh.scale, 1, 30);
}

void mousePressed()
{
  if(mouseButton == LEFT)
  {
  mesh.addVertex(mesh.getFalsePos(mesh.snapToGrid(mesh.getTruePos(mesh.getLocalPos(mouseX,mouseY))))); 
  }
  
  if(mouseButton == RIGHT)
  {
     mesh.removeVertex(mesh.getLocalPos(mouseX,mouseY));

  }
}