class Entity
{
  Entity(int x, int y)
  {
    pos = new PVector(x,y);
    debug();
  }
  
  void debug()
  {
    vertices.add( new PVector( 0, 1 ) );
    vertices.add( new PVector( 2, 0 ) );
    vertices.add( new PVector( 4, 1 ) );
    vertices.add( new PVector( 4, 3 ) );
    vertices.add( new PVector( 1, 3 ) );
    col = #FF6905;
  }
  
  void display()
  {
    pushMatrix();
    translate( pos.x, pos.y );
    fill( col );
    beginShape();
    
    for( int i = 0; i < vertices.size(); i++ )
    {
      vertex( vertices.get( i ).x, vertices.get(i).y );
    }
    
    endShape(CLOSE);
    popMatrix();
  }
  
  PVector getPos()
  {
    return pos;
  }
  
  void setPos( float x, float y )
  {
    pos.x = x;
    pos.y = y;
  }
  
  void setPos( PVector v )
  {
    pos = v;
  }
  
  private PVector pos = new PVector(0,0);
  private ArrayList< PVector > vertices = new ArrayList< PVector >();
  private color col = #000000;
}