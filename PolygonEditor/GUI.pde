class Gui
{
  Gui(PVector _size, PVector _localPos, Gui _parent)
  {
    size.set(_size);
    localPos.set(_localPos);
    parent = _parent;
  }
  
  void display()
  {
    settings.applySettings();
    rect(localPos.x,localPos.y,size.x,size.y); 
  }
  
  protected PVector size;
  protected PVector localPos;
  Gui parent;
  Gui[] children;
  Settings settings = new Settings();
}

class Button
{
  Button(float x, float y, float w ,float h){ 
    
  }
 protected PVector size;
 protected PVector pos;
 PImage image;
}