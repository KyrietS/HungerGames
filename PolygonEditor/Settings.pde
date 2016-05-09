class Settings
{
  Settings(color _col,color _strokeCol, float lineWeight, int edgeStyle,int capStyle){
    col = _col;
    strokeCol = _strokeCol;
    bold = lineWeight;
    edge = edgeStyle;
    cap = capStyle;
  }
  
  Settings()
  { 
  }
  void applySettings()
  {
    fill( col );              // setting: fill color
    stroke( strokeCol );        // setting: line color
    strokeWeight( bold );     // setting: line weight
    strokeCap( cap );         // setting: line cap
    strokeJoin( edge );       // setting: line edge 
    if(!fill)
      noFill();
  }
  
  
  protected color col = #000000;                         // Setting: fill color.
  protected float bold = 1;                        // Setting: line weight.
  protected color strokeCol = #000000;                   // line color
  protected boolean fill = true;                               //fill or no fill
  protected int edge = MITER;                          // Setting: line edge style.
  protected int cap = PROJECT;                           // Setting: line cap style.
}