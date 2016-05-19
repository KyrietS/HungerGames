class CollisionMesh
{
  CollisionMesh(float xBoxes, float yBoxes)                                             // the no. of boxes wide and high
  {
    collisionEvents = new ArrayList<CollisionEvent>(0);
    size.set(xBoxes, yBoxes);
    boxSize = new PVector(width/size.x, height/size.y);

    for (int y = 0; y < size.y; y++)                                                    // creates the table of cells by iterating through boxes, not x and y
    {
      for (int x = 0; x < size.x; x++)
      {
        PVector leftUp = new PVector(boxSize.x * x, boxSize.y * y);                     // the left up vertex is found (eg: one box is 10, so box 1 will have 0,0 left up vertex)
        PVector rightDown = new PVector(boxSize.x * (x + 1), boxSize.y * (y + 1));      // (eg: box one will have a right down vertex at 10,10)
        cells = (CollisionCell[])append(cells, new CollisionCell(leftUp, rightDown));   // the cells array is one dimensional
      }
    }
    
  }
  
  void displayMesh()                                                                    // for debuging, display the whole mesh\\
  {
    for (int i = 0; i < size.x * size.y; i++)
    {
      CollisionCell currentCell = cells[i];
      PVector pos = currentCell.getPos();
      
      if (currentCell.entityIds.size() > 0)
      {
        currentCell.settings.applySettings();
        rect(pos.x, pos.y, boxSize.x, boxSize.y);
        fill(255);
        text(currentCell.entityIds.get(0), pos.x, pos.y);
      }
      
    }
    
  }
  
  CollisionCell[] getCells(ArrayList<PVector> vertices)                                 // from an array of vertices, find out in which cells they are contained \\
  {
    CollisionCell[] inCells = new CollisionCell[0];

    for (int i = 0; i < vertices.size(); i++)
    {
      PVector currentVertice = vertices.get(i);
      int location = get1dLocation(currentVertice.x, currentVertice.y);                 // turns a global x,y into the location of the cell in its array (index)
      location = clamp(location, 0, int(size.x * size.y) - 1);                          // forces the location to the size of the grid (eg: -1,0 will be clamped to 0,0)
      inCells = (CollisionCell[])append(inCells, cells[location]);                      // adds the result to the inCells table

      for (int j = 0; j < inCells.length - 1; j++)                                      // many vertices could have been in the same table, this checks if this happened and removes duplicates
      {
        if (inCells[j].getPos() == inCells[inCells.length - 1].getPos())                // checks every element against the last element only (the one that was recently added)
        {
          inCells = (CollisionCell[])shorten(inCells);                                  // if one of the elements is the same as the last one in the array, the array is shrunk from the end
        }
      }
      
    }

    return inCells;
  }

  CollisionCell getCell(float x, float y) {                                            // from one vertex, find out in which cell it is contained \\
    return(cells[get1dLocation(x, y)]);
  }

  void clearAllCells()                                                                 // delete the information in cells about what entities are in them \\
  {
    
    for (int i = 0; i < cells.length; i++)
    {
      cells[i].removeAllEntities();
    }
    
  }

  void addCollisionEvent(Entity e1, Entity e2)                                         //  when a collision occurs, the coliding entity sends a collision event to the map, this is to synchronize all the collisions \\
  {
    collisionEvents.add(new CollisionEvent(e1, e2));
  }

  void resolveCollisions()                                                             // at each draw the collisions are then resolved \\
  {
    
    for (int i = collisionEvents.size() -1 ; i >= 0; i--)                               // loop backwards so that the arrayList doesnt push all the entities
    {
      collisionEvents.get(i).entity1.resolveCollision(collisionEvents.get(i).entity2); // call the resolve collision function in the first entity with respect to the second (both sent a collision event)
      collisionEvents.remove(i);                                                       // remove the collision event
    }
    
  }
  
  // ----------- PRIVATE ----------- 
  
  private int get1dLocation(float x, float y)                                          // from a global coordinate it finds the local coordinate in the grid (the x-th box) \\
  {
    float xBox = floor(x / boxSize.x);
    float yBox = floor(y / boxSize.y);
    int location = int(xBox + collisionMesh.size.x * yBox);
    return location;
  }
  
  private ArrayList<CollisionEvent> collisionEvents;
  private CollisionCell[] cells = new CollisionCell[0]; 
  private PVector size = new PVector(10, 10);                                          // number of boxes across width and height
  private PVector boxSize;
}

// CollisionCell ----------------------------------------------------- CollisionCell \\

class CollisionCell
{
  Settings settings = new Settings();
  
  CollisionCell(PVector leftUp, PVector rightDown)
  {
    vertexLeftUp.set(leftUp);
    vertexRightDown.set(rightDown);
    entityIds = new IntList();
    settings.col = color(5, 5, 5, 0);
    settings.strokeCol = color(0);
    settings.fill = true;
  }

  int[] getObjectsIds()                                                                // return all the ID's of entities inside \\
  {
    int[] array = entityIds.array();
    return(array);
  }

  void addEntity(int ID)
  {
    entityIds.append(ID);
  }

  void removeEntity(int ID)
  {
    
    for (int i = 0; i < entityIds.size(); i++)
    {
      if (entityIds.get(i) == ID)
        entityIds.remove(i);
    }
    
  } 

  void removeAllEntities()
  {
    
    for (int i = entityIds.size()-1; i >= 0; i--)                                      // again loop backwards to save on performance
    {
      entityIds.remove(i);
    }
    
  }
  
  PVector getPos()
  {
    return(vertexLeftUp);
  }
  
  private PVector vertexLeftUp = new PVector(0, 0), vertexRightDown = new PVector(0, 0);
  private IntList entityIds;
}

// CollisionEvent -------------------- CollisionEvent \\

class CollisionEvent
{
  Entity entity1;
  Entity entity2;
  
  CollisionEvent(Entity e1, Entity e2) 
  {
    entity1 = e1;
    entity2 = e2;
  }
}

// CollisionSystem ------------------------------ CollisionSystem \\

class CollisionSystem
{
  public boolean isCollision( ArrayList< PVector > shape1, ArrayList< PVector > shape2 )
  {
    if ( checkIntersection( shape1, shape2 ) )
    {
      return true;
    } else
    {
      return false;
    }
  }

  public boolean isContaining( ArrayList< PVector > shape1, ArrayList< PVector > shape2 )
  {
    for ( int i = 0; i < shape2.size(); i++ )
    {
      if ( checkContaining( shape1, shape2.get( i ) ) == true )
        return true;
    }
    return false;
  }

  public boolean isContaining( ArrayList< PVector > shape, PVector point )
  {
    return checkContaining( shape, point );
  }

  // ------------- PRIVATE -------------

  private boolean checkIntersection( ArrayList< PVector > tempShape1, ArrayList< PVector > tempShape2 )
  {
    //shape1.add( new PVector( shape1.get( 0 ).x, shape1.get(0).y ) );
    //shape2.add( new PVector( shape2.get( 0 ).x, shape2.get(0).y ) );
    ArrayList<PVector> shape1 = new ArrayList<PVector>(0);
    ArrayList<PVector> shape2 = new ArrayList<PVector>(0);
    shape1 = tempShape1;
    shape2 = tempShape2;
    // Chechks if point lies on an edge.
    for ( int i = 0; i < shape1.size()-1; i++ )
    {
      for ( int j = 0; j < shape2.size()-1; j++ )
      {
        if ( isOnEdge( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j ) ) )
          return true;
        if ( isOnEdge( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i ) ) )
          return true;
      }
    }

    // Checks intersections.
    for ( int i = 0; i < shape1.size()-1; i++ )
    {
      for ( int j = 0; j < shape2.size()-1; j++ )
      {
        if ( sign( det( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j ) ) ) == sign( det( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j + 1 ) ) ) )
        {
          // No intersection.
          continue;
        } else if ( sign( det( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i ) ) ) == sign( det( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i + 1 ) ) ) )
        {
          // No intersection.
          continue;
        } else
        {
          // Intersection.
          return true;
        }
      }
    }
    shape1.remove( shape1.size()-1 );
    shape2.remove( shape2.size()-1 );
    return false;
  }

  // Determinant of the matrix
  private float det( PVector x, PVector y, PVector z )
  {
    return (x.x*y.y + y.x*z.y + z.x*x.y - z.x*y.y - x.x*z.y - y.x*x.y);
  }

  // Checks if z point lie on |xy| line segment
  private boolean isOnEdge( PVector x, PVector y, PVector z )
  {

    if ( det( x, y, z ) != 0 )
    {
      return false;
    } else
    {
      if ( (min( x.x, y.x ) <= z.x) && (z.x <= max( x.x, y.x )) && (min( x.y, y.y ) <= z.y) && (z.y <= max( x.y, y.y )) )
      {
        return true;
      } else
      {
        return false;
      }
    }
  }

  // Temporary variables for checkContaining() and isCrossing().
  private int k;
  private PVector r = new PVector();
  private PVector tmp = new PVector();

  private boolean checkContaining( ArrayList< PVector > shape, PVector point )
  {
    int  nIntersections = 0;  //number of intersections

    float max_x = 0;

    for ( int i = 0; i < shape.size(); i++ )
    {
      if ( shape.get( i ).x > max_x )
        max_x = shape.get( i ).x;
    }
    r.x = max_x + 1;
    r.y = point.y;


    for ( int i = 0; i<shape.size(); i++ )
    {
      k = i;
      if ( isOnEdge( shape.get( i ), shape.get( (i + 1) % shape.size() ), point ) == true )
        return true;
      if ( isCrossing( shape.get( i ), shape.get( (i + 1) % shape.size() ), shape, point ) == true )
        nIntersections++;
    }
    if ( nIntersections % 2 == 0 )
    {
      return false;
    } else
    {
      return true;
    }
  }

  // Support function for isContaining.
  private boolean isCrossing( PVector a, PVector b, ArrayList< PVector > shape, PVector point )
  {
    if ( (isOnEdge( point, r, a ) == false) && (isOnEdge( point, r, b ) == false) )
    {
      if ( (sign( det( point, r, a ) ) != sign( det( point, r, b ) )) &&
        (sign( det( a, b, point ) ) != sign( det( a, b, r ) )) )
        return true;
      else
        return false;
    } else
    {
      if ( (isOnEdge( point, r, a ) == true) && (isOnEdge( point, r, b ) == true) )
      {
        if ( (sign( det( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) ) == sign( det( point, r, shape.get( (k + 2) % shape.size() ) ) )) &&
          (sign( det( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) ) != 0) )
          return false;
        else
          return true;
      } else
        if ( (isOnEdge( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) == true) || 
          (isOnEdge( point, r, shape.get( (k + 2) % shape.size() ) ) == true) )
          return false;
        else
        {
          if ( isOnEdge( point, r, b ) == true )
          {
            tmp = a;
            return false;
          }
          if ( isOnEdge( point, r, a ) == true )
          {
            if ( (sign( det( point, r, tmp ) ) == sign( det( point, r, b ) )) &&
              (sign( det( point, r, tmp ) ) != 0) )
              return false;
            else
              return true;
          }
        }
    }
    return false;
  }

  // ------------ SUPPORT FUNCTIONS ------------
  int sign( double a )
  {
    if ( a == 0 )
      return 0;
    if ( a < 0 )
      return -1;
    return 1;
  }
  // -------------------------------------------
}