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
   // sortVertices();
  }

  void addVertex(PVector vert) // local to centre of the mesh
  {
    boolean isOccupied = false;
    for (int i = 0; i < vertices.size(); i++)
    {
      if (PVector.sub(getTransformedPos(vertices.get(i)),getTransformedPos(vert)).mag() == 0)
      {
        isOccupied = true;
      }      
    }
    if(!isOccupied)
      vertices.add(vert);
  }

  void removeVertex(PVector pos) // local
  {
    for (int i = 0; i < vertices.size(); i++)
    {
      if (dist(vertices.get(i).x,vertices.get(i).y,pos.x,pos.y) < 50)
      {
        vertices.remove(i);
        println(i);
      }      
    }
  }

  void sortVertices()
  {
    for (int j = 0; j < vertices.size(); j++) // sort by x, - to +
    {
      for (int i = 0; i < vertices.size() - 1; i++)
      {
        if (vertices.get(i).x > vertices.get(i+1).x) // if an x value earlier in the list is bigger than the next one
        {
          PVector temp = new PVector(vertices.get(i).x, vertices.get(i).y); 
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
      fill(color(255, 0, 0));
      PVector pos = getTransformedPos(vertices.get(i));
      PVector posFirst = getTransformedPos(vertices.get(0)); 
      ellipse(pos.x,pos.y, 40/scale, 40/scale);
      if(i < vertices.size() - 1)
      {
        PVector posNext = getTransformedPos(vertices.get(i + 1)); 
        line(pos.x,pos.y,posNext.x,posNext.y);
      }
      else
       line(pos.x,pos.y,posFirst.x,posFirst.y);
      text(i,pos.x -4,pos.y-6);
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
  
  PVector snapToGrid(PVector pos) // local pos
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
  PVector getFalsePos(PVector Tpos) // reverses the above
  {
    PVector pos = new PVector(Tpos.x,Tpos.y);
    pos.x = (pos.x*scale)*boxSize.x;
    pos.y = (pos.y*scale)*boxSize.y;
    return pos;
  }
  
  private float scale = 1;
  PVector size = new PVector(width, height);
  PVector boxSize = new PVector(1, 1);
  PVector offset = new PVector(0,0);
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  Settings settings = new Settings();
}