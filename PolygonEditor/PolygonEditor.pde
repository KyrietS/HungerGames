boolean snapToGrid = true;
PVector last= new PVector(0, 0);
Mesh mesh;
XmlWriter writer;
PVector centre;
boolean pressed, mPressed;
String name,colH;
color col;
PVector anchor;
Gui menu;
void setup()
{
  size(600, 600);
  centre = new PVector(width/2, height/2);
  mesh = new Mesh();
  writer = new XmlWriter(mesh.vertices);
  pressed = false;
  mPressed = false;
  
  name = "untitled"; // set name, anchor and colH to alter file
  colH = "#C22C0E";
  col = toRGB(colH,50);
  anchor = new PVector(0, 0);
  
  menu = new Gui(new PVector(100, 60), new PVector(0, 0), menu);
  menu.settings.fill = true;
  menu.settings.col = color(0, 0, 255, 99);
  menu.children = (Gui[])append(menu.children, new GuiText(new PVector(100, 15), new PVector(5, 0), menu, "name" + " : " + "'" + name + "'"));
  menu.children = (Gui[])append(menu.children, new GuiText(new PVector(100, 15), new PVector(5, 15), menu, "color" + " : " + "'" + colH + "'"));
  menu.children = (Gui[])append(menu.children, new GuiText(new PVector(100, 15), new PVector(5, 30), menu, "anchor" + " : " + "'" + int(anchor.x)+","+int(anchor.y)+ "'"));
  menu.children = (Gui[])append(menu.children, new GuiText(new PVector(100, 15), new PVector(5, 45), menu, "saved" + " : " + "'" +writer.saved+"'"));
}

void draw()
{
  background(255);
  if(snapToGrid)
  {
     mesh.displayGhost(); 
  }
  mesh.update();
  mesh.display();
  menu.display();
  menu.children[3].text = "saved" + " : " + "'" +writer.saved+"'";
  writer.vertices = mesh.vertices;
  if (keyPressed)
  {
    if (keyCode == ALT)
    {
      snapToGrid = false;
    }
    //if(keyCode == LEFT)
    //  mesh.offset.x += 2;
    //if(keyCode == RIGHT)
    //  mesh.offset.x -= 2;
    //if(keyCode == UP)
    //  mesh.offset.y += 2;
    //if(keyCode == DOWN)
    //  mesh.offset.y -= 2;

    else if (!pressed)
    {
      if (key == 's')
      {
        writer.saveObject(name, colH, anchor.x, anchor.y);
        pressed = true;
      }

      if (key == '+')
      {
        mesh.scaleVertices(2); 
        pressed = true;
      }

      if (key == '_')
      {
        mesh.scaleVertices(0.5);  
        pressed = true;
      }
    }   

    if (keyCode == CONTROL && !pressed && !mPressed && mousePressed)
    {
      mesh.moveVertex(mouseX, mouseY);
      mPressed = true;
      pressed = true;
    }
  }

  if (mousePressed)
  {
    if (mouseButton == LEFT)
    {
      last.set(mouseX, mouseY);
    }
    if (mouseButton == RIGHT)
    {
      mesh.removeVertex(mesh.getLocalPos(mouseX, mouseY));
    }
    if (keyCode == SHIFT)
    {
      rectMode(CORNERS);
      rect(last.x, last.y, mouseX, mouseY);
      rectMode(CORNER);
    }
    if (mouseButton == LEFT && !mPressed)
    {
      if (!keyPressed || keyCode == ALT)
      {
        if (snapToGrid)
        {
          mesh.addVertex(mesh.getFalsePos(mesh.snapToGrid(mesh.getTruePos(mesh.getLocalPos(mouseX, mouseY)))));
        } else
        {
          mesh.addVertex(mesh.getLocalPos(mouseX, mouseY)); 
          println(mesh.getLocalPos(mouseX, mouseY));
        }
        mPressed = true;
        writer.saved = false;
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  mesh.scale += e*2;
  if (mesh.scale % 2 != 0)
    mesh.scale++;
  mesh.scale = clamp(mesh.scale, 1, 30);
}

void keyReleased()
{
  pressed = false; 
  snapToGrid = true;
}

void mouseReleased()
{
  mPressed = false;
}