private class Settings
{
  Settings(color _col,color _strokeCol, float lineWeight, int edgeStyle,int capStyle){
    col = _col;
    strokeCol = _strokeCol;
    bold = lineWeight;
    edge = edgeStyle;
    cap = capStyle;
  }
  
  void applySettings()
  {
    fill( col );              // setting: fill color
    stroke( strokeCol );        // setting: line color
    strokeWeight( bold );     // setting: line weight
    strokeCap( cap );         // setting: line cap
    strokeJoin( edge );       // setting: line edge 
  }
  
  protected color col;                         // Setting: fill color.
  protected float bold;                        // Setting: line weight.
  protected color strokeCol;                   // line color
  protected int edge;                          // Setting: line edge style.
  protected int cap;                           // Setting: line cap style.
}