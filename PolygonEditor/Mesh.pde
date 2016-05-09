class Mesh
{
  Mesh() {
    settings.fill = false;
    settings.strokeCol = color(0);
  }

  void display()
  {
    for (int y = 0; y < size.x/boxSize.x; y++)
    {
      for (int x = 0; x < size.y/boxSize.y; x++)
      {
        settings.applySettings();
        rect((boxSize.x * x) + offset.x, (boxSize.y * y) + offset.y, boxSize.x, boxSize.y);
      }
    }
    strokeWeight(2);
    line(0, height/2 + offset.y, width, height/2 + offset.y);
    line(width/2 + offset.x, 0, width/2 + offset.x, height);
    displayVertices();
  }

  void update()
  {
   boxSize.set(width/scale, height/scale);
   for(int i = 0 ; i < vertices.size(); i++)
   {
     vertices.get(i).update(); 
   }
  }

  void addVertex(PVector vert) // local to centre of the mesh
  {
    boolean isOccupied = false;
    for (int i = 0; i < vertices.size(); i++)
    {
      if (PVector.sub(getTransformedPos(vertices.get(i).getPos()),getTransformedPos(vert)).mag() == 0)
      {
        isOccupied = true;
      }      
    }
    if(!isOccupied)
      vertices.add(new Vertice(vert));
  }

  void removeVertex(PVector pos) // local
  {
    for (int i = 0; i < vertices.size(); i++)
    {
      if (dist(vertices.get(i).getPos().x,vertices.get(i).getPos().y,pos.x,pos.y) < 50)
      {
        vertices.remove(i);
      }      
    }
  }

  void sortVertices()
  {
    for (int j = 0; j < vertices.size(); j++) // sort by x, - to +
    {
      for (int i = 0; i < vertices.size() - 1; i++)
      {
        if (vertices.get(i).getPos().x > vertices.get(i+1).getPos().x) // if an x value earlier in the list is bigger than the next one
        {
          Vertice temp = new Vertice(vertices.get(i).getPos().x, vertices.get(i).getPos().y); 
          vertices.remove(i);
          vertices.add(i+1, temp); // switch them, this is done vertices.size() times so as to sort by x;
        }
      }
    }
  }
  
  void displayVertices()
  {
    for (int i = 0; i < vertices.size(); i++)
    {
      PVector posFirst = getTransformedPos(vertices.get(0).getPos()); 
      PVector pos = getTransformedPos(vertices.get(i).getPos());
      vertices.get(i).display();
      stroke(150,0,0);
      if(i < vertices.size() - 1)
      {
        PVector posNext = getTransformedPos(vertices.get(i + 1).getPos()); 

        line(pos.x,pos.y,posNext.x,posNext.y);
      }
      else
       //stroke(255,0,0);
       line(pos.x,pos.y,posFirst.x,posFirst.y);
      text(i,pos.x -4,pos.y-6);
    }
  }
  
  void moveVertex(float x, float y)
  {
    PVector pos = new PVector(getLocalPos(x,y).x,getLocalPos(x,y).y);
    for (int i = 0; i < vertices.size(); i++)
    {
      if (dist(vertices.get(i).getPos().x,vertices.get(i).getPos().y,pos.x,pos.y) < 50)
      {
        vertices.get(i).isDragged = true;
      }      
    }
  }
  
  void leaveVertex(float x, float y)
  {
    PVector pos = new PVector(getLocalPos(x,y).x,getLocalPos(x,y).y);
    for (int i = 0; i < vertices.size(); i++)
    {
      if (dist(vertices.get(i).getPos().x,vertices.get(i).getPos().y,pos.x,pos.y) < 50)
      {
        vertices.get(i).isDragged = false;
        println(i);
      }      
    }
  }
  
  PVector getLocalPos(float x ,float y)  // from global eg: mouseX to local
  {
    PVector pos = new PVector(x - centre.x - offset.x ,y - centre.y - offset.y);
    PVector meshPos = new PVector(pos.x * scale,pos.y * scale);
    return(meshPos);
  }
  
  PVector getTransformedPos(PVector pos) // from local pos, get scaled and offset pos, to draw vertices right
  {
    PVector meshPos = new PVector((pos.x / scale) + centre.x + offset.x,(pos.y / scale) + centre.y + offset.y);
    return(meshPos);
  }
  
  PVector snapToGrid(PVector pos) // local true pos
  {
    return(pos.set(round(pos.x),round(pos.y)));
  }
  
  PVector getTruePos(PVector Tpos) //from local gets the position where each line is equal to one
  {
    PVector pos = new PVector(Tpos.x,Tpos.y);
    pos.x = (pos.x/scale)/boxSize.x;
    pos.y = (pos.y/scale)/boxSize.y;
    return pos;
  }
  
  void scaleVertices(float mult)
  {

    for(int i = 0; i < vertices.size();i++)
    {
      PVector posT;
      posT = getFalsePos(PVector.mult(getTruePos(vertices.get(i).getPos()),mult));

      vertices.get(i).setPos(posT);
    }
  }
  
  PVector getFalsePos(PVector Tpos) // reverses the above
  {
    PVector pos = new PVector(Tpos.x,Tpos.y);
    pos.x = (pos.x*scale)*boxSize.x;
    pos.y = (pos.y*scale)*boxSize.y;
    return pos;
  }
  
  void displayGhost(){
    PVector pos;
    if(snapToGrid){
      pos = getTransformedPos((getFalsePos(snapToGrid(getTruePos(getLocalPos(mouseX,mouseY))))));
    }
    else
    {
      pos = getTransformedPos(getLocalPos(mouseX,mouseY));
    }
    stroke(0,0,0);
    fill(255,0,0,90);
    ellipse(pos.x,pos.y, 40/scale, 40/scale);
  }
  
  private float scale = 6;
  PVector size = new PVector(width, height);
  PVector boxSize =   new PVector(width/scale, height/scale);
  PVector offset = new PVector(0,0);
  ArrayList<Vertice> vertices = new ArrayList<Vertice>();
  Settings settings = new Settings();
}

class Vertice
{
  Vertice(PVector _pos)
  {
    pos.set(_pos);
  }
  Vertice(float x ,float y)
  {
   pos.set(x,y); 
  }
  
  PVector getPos()
  {
   return pos; 
  }
  
  void setPos(PVector _pos)
  {
   pos.set(_pos);  
  }
  
  void update()
  {
    if(isDragged)
    {
      PVector posT;
      if(snapToGrid)
      {
        posT = mesh.getFalsePos(mesh.snapToGrid(mesh.getTruePos(mesh.getLocalPos(mouseX,mouseY))));
      }
      else
      {
        posT = mesh.getLocalPos(mouseX,mouseY);
      }
      pos.set(posT); 
      settings.col = color(50,0,0,50);
    }
    else
    {
     settings.col = color(255,0,0); 
    }
    
    if(!mousePressed)
    {
      isDragged = false;  
    }
  }
  
  void display()
  {
      settings.applySettings();
      PVector posT = mesh.getTransformedPos(pos);
      ellipse(posT.x,posT.y, 40/mesh.scale, 40/mesh.scale);
  }
  PVector pos = new PVector(0,0);
  boolean isSelected = false;
  boolean isDragged = false;
  Settings settings = new Settings(color(255,0,0),color(0,0,0),2,MITER,PROJECT);
}