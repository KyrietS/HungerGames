class Map{
 PImage image;
 PVector dimensions;
 ArrayList<entity> entities;
 
 Map(int x, int y)
 {
  dimensions = new PVector(x,y);
  image = createImage(x,y,RGB);
 }
 
 void display()
 {
  image(image,0,0); 
 }
 
 void setColor(color Color)
 {
  image.loadPixels();
  for(int i = 0; i < image.pixels.length; i++)
  {
   image.pixels[i] = Color;
  }
  image.updatePixels();
 }
 
}