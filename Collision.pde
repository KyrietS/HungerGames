class CollisionMesh
{
  CollisionMesh(float xBoxes, float yBoxes)
  {
    size.set(xBoxes, yBoxes);
    boxSize = new PVector(width/size.x, height/size.y);
    for (int y = 0; y < size.y; y++)
    {
      for (int x = 0; x < size.x; x++)
      {
        PVector leftUp = new PVector(boxSize.x * x, boxSize.y * y);
        PVector rightDown = new PVector(boxSize.x * (x + 1), boxSize.y * (y + 1));
        cells = (CollisionCell[])append(cells, new CollisionCell(leftUp, rightDown));
      }
    }
  }

  CollisionCell[] getCells(ArrayList<PVector> vertices)
  {
    CollisionCell[] inCells = new CollisionCell[0];
    for (int i = 0; i < vertices.size(); i++)
    {
      PVector pos = vertices.get(i);
      int location = get1dLocation(pos.x, pos.y);
      location = clamp(location, 0, int(size.x * size.y) - 1);
      inCells = (CollisionCell[])append(inCells, cells[location]);
      for (int j = 0; j < inCells.length - 1; j++)
      {
        if (inCells[j].getPos() == inCells[inCells.length - 1].getPos())
        {
          inCells = (CollisionCell[])shorten(inCells);
        }
      }
    }
    return inCells;
  }
  CollisionCell getCell(float x, float y) {
    return(cells[get1dLocation(x, y)]);
  }
  int get1dLocation(float x, float y)
  {
    float xBox = floor(x / boxSize.x);
    float yBox = floor(y / boxSize.y);
    int location = int(xBox + collisionMesh.size.x * yBox);
    return location;
  }

  void displayMesh()
  {
    for (int i = 0; i < size.x * size.y; i++)
    {
      CollisionCell currentCell = cells[i];
      PVector pos = currentCell.getPos();
      if (currentCell.entityIds.size() > 0)
      {
        currentCell.settings.applySettings();
        rect(pos.x, pos.y, boxSize.x, boxSize.y);
      }
    }
  }
  void clearAllCells()
  {
    for (int i = 0; i < cells.length; i++)
    {
      cells[i].removeAllEntities();
    }
  }

  private CollisionCell[] cells = new CollisionCell[0]; 
  private PVector size = new PVector(10, 10); // number of boxes across width and height
  private PVector boxSize;
}

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

  int[] getObjectsIds()
  {
    int[] array = entityIds.array();
    return(array);
  }

  PVector getPos()
  {
    return(vertexLeftUp);
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
    for (int i = 0; i < entityIds.size(); i++)
    {
      entityIds.remove(i);
    }
  }
  private PVector vertexLeftUp = new PVector(0, 0), vertexRightDown = new PVector(0, 0);
  private IntList entityIds;
}

class CollisionSystem
{
  public boolean isCollision( ArrayList< PVector > shape1, ArrayList< PVector > shape2 )
  {
    if ( checkIntersection( shape1, shape2 ) )
    {
      return true;
    } 
    else
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
      {
        return true;
      }
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