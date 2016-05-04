
class timer
{
  float timeStart, timeNow, delay;
  int ID;
  timer(float d) 
  {
    delay = d;
    timeStart = millis();
    timeNow = millis();
  }
  boolean passed()
  {
    boolean passed = false;
    if (timeNow - timeStart > delay)
    {
      passed = true;
    }
    return(passed);
  }
  void update()
  {
    timeNow = millis();
  }
  void set()
  {
    timeStart = millis();
  }
}