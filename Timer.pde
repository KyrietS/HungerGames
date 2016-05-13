
class Timer{
 int timeStart, timeNow;
 float delay;
 
 Timer(float d){
   delay = d;
   timeStart = millis();
   timeNow = millis();
 }
 
 boolean passed()
 {
   boolean passed = false;
   if(float(timeNow - timeStart) >= delay)
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
  
  int getTime()
  {
    return timeNow - timeStart;
  }
  
  void setDelay(float d)
  {
    delay = d;
  }
}