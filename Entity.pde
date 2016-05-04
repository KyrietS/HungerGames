class Entity
{
  Entity(int x, int y)
  {
    pos.set(x,y);
    debug();
  }
  
  void debug()
  {
    vertices.add( new PVector( 0, 50 ) );
    vertices.add( new PVector( 100, 0 ) );
    vertices.add( new PVector( 200, 50 ) );
    vertices.add( new PVector( 200, 150 ) );
    vertices.add( new PVector( 0, 150 ) );
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