class Gui
{
  Gui(PVector _size, PVector _localPos, Gui _parent)
  {
    size.set(_size);
    localPos.set(_localPos);
    parent = _parent;
    children = new Gui[0];
    settings.fill = false;
    settings.bold = 2;
  }
  
  void display()
  {
    settings.applySettings();
    rect(localPos.x,localPos.y,size.x,size.y);
    for(int i = 0; i < children.length;i++)
    {
      children[i].display(); 
    }
  }
  
  protected PVector size = new PVector(0,0);
  protected PVector localPos = new PVector(0,0);
  Gui parent;
  Gui[] children;
  Settings settings = new Settings();
  String text;
}

class GuiText extends Gui
{

  GuiText(PVector _size, PVector _localPos, Gui _parent,String _text){
    super(_size,_localPos,_parent);
    text = _text;
    settings.stroke = false;
  }
  
  void display()
  {
    super.display();
    fill(255);
    text(text,localPos.x + parent.localPos.x,localPos.y + parent.localPos.y,size.x,size.y);
  }
}

class Button
{
  Button(float x, float y, float w ,float h){ 
    
  }
 protected PVector size;
 protected PVector pos;
 PImage image;
}