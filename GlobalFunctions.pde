// functions to be used all around the code
int clamp(int value, int min , int max) // limit value to a range
{
  if(value > max)
   value = max;
  else if(value < min)
   value = min;
  return value;
}

float clamp(float value, float min , float max)
{
  if(value > max)
   value = max;
  else if(value < min)
   value = min;
  return value;
}

PVector clamp(PVector value, float minX, float maxX, float minY, float maxY)
{
  if(value.x > maxX)
   value.x = maxX;
  else if(value.x < minX)
   value.x = minX;
  if(value.y > maxY)
   value.y = maxY;
  else if(value.y < minY)
   value.y = minY;
  return value;
}

color toRGB(String hexColor) // convert hex to RGB
{
  color col = color(255,0,0); // set col as red in case of exception
  if ( hexColor.charAt(0) == '#')        // Checks if first character is '#'. It means that we have hex-style color.
  {
    try                                  // Try to convert R, G and B partf from hex-style color. For example: FF, 44, 88 (R, G, B).
    {
      col = color( unhex(hexColor.substring(1, 3)), unhex(hexColor.substring(3, 5)), unhex(hexColor.substring(5, 7)) );
    }
    catch( Exception e) {               // Problem with converting. leave color as red
    }
    } 
  return col;
}