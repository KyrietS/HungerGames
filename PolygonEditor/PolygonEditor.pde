boolean snapToGrid = true;
PVector last= new PVector(0,0);
Mesh mesh;
XmlWriter writer;
PVector centre;
boolean pressed,mPressed;
String name,col;
PVector anchor;
Gui menu;
void setup()
{
  size(600,600);
  centre = new PVector(width/2, height/2);
  mesh = new Mesh();
  writer = new XmlWriter(mesh.vertices);
  pressed = false;
  mPressed = false;
  name = "object.3";
  col = "#000000";
  anchor = new PVector(0,0);
  menu = new Gui(new PVector(100,100),new PVector(0,0),menu);
  menu.children = (Gui[])append(menu.children,new GuiText(new PVector(100,15),new PVector(5,0),menu,"name" + " : " + "'" + name + "'"));
  menu.children = (Gui[])append(menu.children,new GuiText(new PVector(100,15),new PVector(5,15),menu,"color" + " : " + "'" + col + "'"));
  menu.children = (Gui[])append(menu.children,new GuiText(new PVector(100,15),new PVector(5,30),menu,"anchor" + " : " + "'" + int(anchor.x)+","+int(anchor.y)+ "'"));
  menu.children = (Gui[])append(menu.children,new GuiText(new PVector(100,15),new PVector(5,45),menu,"saved" + " : " + "'" +writer.saved+"'"));
}

void draw()
{
  background(255);
  menu.display();
  mesh.update();
  mesh.display();
  writer.vertices = mesh.vertices;
  if(keyPressed)
  {
    if(keyCode == LEFT)
      mesh.offset.x += 2;
    if(keyCode == RIGHT)
      mesh.offset.x -= 2;
    if(keyCode == UP)
      mesh.offset.y += 2;
    if(keyCode == DOWN)
      mesh.offset.y -= 2;
      
    if(!pressed)
    {
      if(key == 's')
      {
        writer.saveObject(name,col,anchor.x,anchor.y);
        pressed = true;
      }
      
      if(key == '+')
      {
        mesh.scaleVertices(2); 
        pressed = true;
      }
      
      if(key == '_')
      {
        mesh.scaleVertices(0.5);  
        pressed = true;
      }
    }   
    
    if(keyCode == CONTROL && !pressed && !mPressed && mousePressed)
    {
      mesh.moveVertex(mouseX,mouseY);
      mPressed = true;
      pressed = true;
    }
    
    if(keyCode == ALT)
      snapToGrid = true;
    else
      snapToGrid = false;
      
    if(mousePressed)
    {
      if(keyCode == SHIFT)
      {
        rectMode(CORNERS);
        rect(last.x,last.y,mouseX,mouseY);
        rectMode(CORNER);
      }
    }
  }
  mesh.displayGhost();
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
void keyReleased()
{
  pressed = false; 
}

void mouseReleased()
{
 mPressed = false; 
}