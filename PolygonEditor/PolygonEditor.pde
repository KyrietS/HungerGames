boolean snapToGrid = true;
PVector last= new PVector(0,0);
Mesh mesh;
XmlWriter writer;
PVector centre;
void setup()
{
  size(600,600);
  centre = new PVector(width/2, height/2);
  mesh = new Mesh();
  writer = new XmlWriter(mesh.vertices);
}

void draw()
{
  background(255);
  mesh.update();
  mesh.display();
  writer.vertices = mesh.vertices;
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
  mesh.displayGhost();
  
  if(mousePressed && keyPressed && keyCode == SHIFT){
    rectMode(CORNERS);
    rect(last.x,last.y,mouseX,mouseY);
    rectMode(CORNER);
  }
  
  if(mousePressed && keyPressed && keyCode == CONTROL)
  {
    mesh.moveVertex(mouseX,mouseY);
  }
  
  if(keyPressed && key == 's')
  {
    writer.saveObject("object","#000000",0,0);
  }
  
  if(keyPressed && key == '+')
  {
    mesh.scaleVertices(1.01);  
  }
  
  if(keyPressed && key == '_')
  {
    mesh.scaleVertices(0.09);  
  }
  
  if(keyPressed && keyCode == ALT)
  {
    snapToGrid = true;
  } else {snapToGrid = false;}
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

  if(mouseButton == LEFT && keyCode != CONTROL)
  {
    if(snapToGrid)
    {
      mesh.addVertex(mesh.getFalsePos(mesh.snapToGrid(mesh.getTruePos(mesh.getLocalPos(mouseX,mouseY))))); 
    }
    else
    {
      mesh.addVertex(mesh.getLocalPos(mouseX,mouseY)); 
      println(mesh.getLocalPos(mouseX,mouseY));
    }
  }
  
  if(mouseButton == LEFT)
  {
    last.set(mouseX,mouseY);
  }
  
  if(mouseButton == RIGHT)
  {
     mesh.removeVertex(mesh.getLocalPos(mouseX,mouseY));

  }
}