class CollisionMesh
{
  
  CollisionCell[] cells; 
}

class CollisionCell
{
  PVector vertexLeftUp,vertexRightDown;
  IntList entityIds;
  CollisionCell(PVector leftUp,PVector rightDown)
  {
    vertexLeftUp.set(leftUp);
    vertexRightDown.set(rightDown);
    entityIds = new IntList();
  }
  int[] getObjects()
  {
    int[] array = entityIds.array();
    return(array);
  }
}

class CollisionSystem
{

  public boolean isCollision( ArrayList< PVector > shape1, ArrayList< PVector > shape2 )
  {
    if( checkIntersection( shape1, shape2 ) )
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
    for( int i = 0; i < shape2.size(); i++ )
    {
      if( checkContaining( shape1, shape2.get( i ) ) == true )
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
    for( int i = 0; i < shape1.size()-1; i++ )
    {
      for( int j = 0; j < shape2.size()-1; j++ )
      {
        if( isOnEdge( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j ) ) )
          return true;
        if( isOnEdge( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i ) ) )
          return true;
      }
    }

    // Checks intersections.
    for( int i = 0; i < shape1.size()-1; i++ )
    {
      for( int j = 0; j < shape2.size()-1; j++ )
      {
        if( sign( det( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j ) ) ) == sign( det( shape1.get( i ), shape1.get( i + 1 ), shape2.get( j + 1 ) ) ) )
        {
          // No intersection.
          continue;
        }
        else if( sign( det( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i ) ) ) == sign( det( shape2.get( j ), shape2.get( j + 1 ), shape1.get( i + 1 ) ) ) )
        {
          // No intersection.
          continue;
        }
        else
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
  private long det( PVector x, PVector y, PVector z )
  {
    return (long)(x.x*y.y + y.x*z.y + z.x*x.y - z.x*y.y - x.x*z.y - y.x*x.y);
  }

  // Checks if z point lie on |xy| line segment
  private boolean isOnEdge( PVector x, PVector y, PVector z )
  {

    if( det( x, y, z ) != 0 )
    {
      return false;
    }
    else
    {
      if( (min( x.x, y.x ) <= z.x) && (z.x <= max( x.x, y.x )) && (min( x.y, y.y ) <= z.y) && (z.y <= max( x.y, y.y )) )
      {
        return true;
      }
      else
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

    for( int i = 0; i < shape.size(); i++ )
    {
      if( shape.get( i ).x > max_x )
        max_x = shape.get( i ).x;
    }
    r.x = max_x + 1;
    r.y = point.y;


    for( int i = 0; i<shape.size(); i++ )
    {
      k = i;
      if( isOnEdge( shape.get( i ), shape.get( (i + 1) % shape.size() ), point ) == true )
      {
        return true;
      }
      if( isCrossing( shape.get( i ), shape.get( (i + 1) % shape.size() ), shape, point ) == true )
        nIntersections++;
    }
    if( nIntersections % 2 == 0 )
    {
      return false;
    }
    else
    {
      return true;
    }
  }

  // Support function for isContaining.
  private boolean isCrossing( PVector a, PVector b, ArrayList< PVector > shape, PVector point )
  {
    if( (isOnEdge( point, r, a ) == false) && (isOnEdge( point, r, b ) == false) )
    {
      if( (sign( det( point, r, a ) ) != sign( det( point, r, b ) )) &&
        (sign( det( a, b, point ) ) != sign( det( a, b, r ) )) )
        return true;
      else
        return false;
    }
    else
    {
      if( (isOnEdge( point, r, a ) == true) && (isOnEdge( point, r, b ) == true) )
      {
        if( (sign( det( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) ) == sign( det( point, r, shape.get( (k + 2) % shape.size() ) ) )) &&
          (sign( det( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) ) != 0) )
          return false;
        else
          return true;
      }
      else
        if( (isOnEdge( point, r, shape.get( (k - 1 + shape.size()) % shape.size() ) ) == true) || 
          (isOnEdge( point, r, shape.get( (k + 2) % shape.size() ) ) == true) )
          return false;
        else
        {
          if( isOnEdge( point, r, b ) == true )
          {
            tmp = a;
            return false;
          }
          if( isOnEdge( point, r, a ) == true )
          {
            if( (sign( det( point, r, tmp ) ) == sign( det( point, r, b ) )) &&
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
  int sign( long a )
  {
    if( a == 0 )
      return 0;
    if( a < 0 )
      return -1;
    return 1;
  }
  // -------------------------------------------
  
}