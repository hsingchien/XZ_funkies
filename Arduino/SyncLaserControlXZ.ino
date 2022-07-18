

//initial settings
int Mode = 0;
int value = 0;
int wavelength = 0;
int expduration = 0;
int cycleduration =0;
int dutylength = 0;
int pulsefreq = 0;
int pulsewidth = 0;
int pinOutLED1;
int pinOutLaser1;
int pinOutLaser2;
int pinOutLED2;
int count = 0;
int LaserChannel1 = 0;
int LaserChannel2 = 0;
int start1 = 0;
int start2 = 0;
int stop1 = 0;
int stop2 = 0;
int i;
int imemory = 0;
bool LEDon1 = 0;
bool LEDon2 = 0;
unsigned long time1 = 0;
unsigned long time0 = 0;
unsigned long time2 = 0;
unsigned long time3 = 0;
//define channel
const int pin473LED1 = 2; 
const int pin473Laser1 = 4;  
const int pin473LED2 = 7;
const int pin473Laser2 = 8;
const int pinIDLE1 = 5;
const int pinIDLE2 = 6;


//const int 635pinLED = 10;

void setup()
{
 Serial.begin(9600);  //Initialize serial port
 //setting of pins
  pinMode(pin473LED1, OUTPUT);
  pinMode(pin473Laser1, OUTPUT);
  pinMode(pin473LED2, OUTPUT);
  pinMode(pin473Laser2, OUTPUT);
  pinMode(pinIDLE1, OUTPUT);
  pinMode(pinIDLE2, OUTPUT);
  //pinMode(635pinLED, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  
 
} 

void loop()
{
  digitalWrite(LED_BUILTIN, LOW);
  switch(Mode)
  {
    case 0: // idle mode
    digitalWrite(LED_BUILTIN, HIGH); delay(600); digitalWrite(LED_BUILTIN, LOW);
    Serial.println("Input all parameters: e.g. p473,20,6,4,20,20,3,18,1,12,4,8,");
    Serial.println("p-wavelength,expdur,cycdur,dutydur,pulsefreq,pulsewidth,start1,stop1,start2,stop2,channel1,channel2");
    // wavelength, expduration, cycleduration, dutylength, pulsefreq, pulsewidth, startat1, stopat1, startat2, stopat2, pinLaser1, pinLaser2
//   Serial.println("Input total duration (sec):");
    Mode++;
    break;
    
    case 1:
    checkCommand(); // take input
    break;
    
    case 3:
    digitalWrite(LED_BUILTIN, HIGH); delay(200); digitalWrite(LED_BUILTIN, LOW); delay(100); 
    digitalWrite(LED_BUILTIN, HIGH); delay(200); digitalWrite(LED_BUILTIN, LOW); delay(100);
    digitalWrite(LED_BUILTIN, HIGH); delay(200); digitalWrite(LED_BUILTIN, LOW); 
    // assign Laser channels
    if (LaserChannel1 == pin473Laser1) {
      pinOutLED1 = pin473LED1;pinOutLaser1 = pin473Laser1;}
    else if (LaserChannel1 == pin473Laser2) {
      pinOutLED1 = pin473LED2; pinOutLaser1 = pin473Laser2;} 
    else 
    {
      Serial.println("Stim1 is IDLE, NO LASER!");
      pinOutLED1 = pin473LED1;  
      pinOutLaser1 = pinIDLE1;
      }

    if (LaserChannel2 == pin473Laser1) {
      pinOutLED2 = pin473LED1;pinOutLaser2 = pin473Laser1;}
    else if (LaserChannel2 == pin473Laser2) {
      pinOutLED2 = pin473LED2; pinOutLaser2 = pin473Laser2;} 
    else 
    {
      Serial.println("Stim2 is IDLE, NO LASER!");
      pinOutLED2 = pin473LED2;  
      pinOutLaser2 = pinIDLE2;
      }

    time0 = millis();
    for (i = imemory; i < (expduration * pulsefreq); i++) // total number of pulses
    {
      time2 = millis();
      if( i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop1*pulsefreq){
        digitalWrite(pinOutLaser1,HIGH);//Serial.println("Laser1 on!"); time1 = millis(); Serial.println(time1-time0);
      }
      if(!LEDon1 && i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) < dutylength * pulsefreq && i < stop1*pulsefreq){
        digitalWrite(pinOutLED1,HIGH); 
        LEDon1 = 1; Serial.println("LED1 is on at"); time1 = millis(); Serial.println(time1-time0);
      } else if (LEDon1 && (i>=stop1*pulsefreq || (i-start1*pulsefreq) % (cycleduration*pulsefreq) >= dutylength * pulsefreq)){
        digitalWrite(pinOutLED1,LOW);Serial.println("LED1 is off at"); time1 = millis(); Serial.println(time1-time0);
        LEDon1 = 0; 
      }

      if(i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop2*pulsefreq){
        digitalWrite(pinOutLaser2,HIGH); //Serial.println("Laser2 on!"); time1 = millis(); Serial.println(time1-time0);
        }
      if(!LEDon2 && i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) < dutylength * pulsefreq && i < stop2*pulsefreq){
        digitalWrite(pinOutLED2,HIGH);
        LEDon2 = 1; Serial.println("LED2 is on at"); time1 = millis(); Serial.println(time1-time0);
      } else if (LEDon2 && (i>=stop2*pulsefreq || (i-start2*pulsefreq) % (cycleduration*pulsefreq) >= dutylength * pulsefreq)){
        digitalWrite(pinOutLED2,LOW); Serial.println("LED2 is off at"); time1 = millis(); Serial.println(time1-time0);
        LEDon2 = 0;
      }
      
      delay(pulsewidth);
      if( i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop1*pulsefreq){
        digitalWrite(pinOutLaser1,LOW); //Serial.println("Laser1 off!"); time1 = millis(); Serial.println(time1-time0);
        }
      if(i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop2*pulsefreq){
        digitalWrite(pinOutLaser2,LOW); //Serial.println("Laser2 off!"); time1 = millis(); Serial.println(time1-time0);
        }
      checkCommand();
      if (Mode == 4) {imemory = i+1; break;} else if (Mode == 0){break;}
      time3 = millis();
      delay(1000/pulsefreq - (time3 - time2));
    }
    if (Mode == 4){break;} 
    else if (Mode == 0) {
      imemory = 0; 
      digitalWrite(pinOutLED1,LOW);
      digitalWrite(pinOutLED2,LOW);
      digitalWrite(pinOutLaser1,LOW);
      digitalWrite(pinOutLaser2, LOW);
      break;
      }
    digitalWrite(pinOutLED1,LOW);
    digitalWrite(pinOutLED2,LOW);
    digitalWrite(pinOutLaser1,LOW);
    digitalWrite(pinOutLaser2, LOW);
    imemory = 0;
    Mode = 0;
    break;
    
    case 4: // pause state
    digitalWrite(LED_BUILTIN, HIGH); delay(200); digitalWrite(LED_BUILTIN, LOW);
    Serial.println("User pausing... input q to continue current run!");
    if (Serial.available()) { // enter another 'q' to continue
    char ch = Serial.read();
    if(ch == 'q'){
      Mode = 3;
      Serial.println("Continue...");
      break;
    } else if (ch == 's') { // enter 's' during pause to stop
      Mode = 0;
      Serial.println("Stopped!");
      break;
    }
    }

    /*case 4:
    if (wavelength == 473) { pinOutLED = pin473LED; pinOutLaser = pin473Laser; }  
    else if (wavelength == 593) { pinOutLED = pin593LED; pinOutLaser = pin593Laser; }
    else if (wavelength == 635) { pinOutLED = pin593LED; pinOutLaser = pin593Laser; }
    digitalWrite(pinOutLED,HIGH);
    digitalWrite(pinOutLaser,HIGH);
    delay(totalDuration*1000);
    digitalWrite(pinOutLaser,LOW);
    digitalWrite(pinOutLED,LOW);
    Mode = 0;
    break;*/

    /*case 5:
    if (wavelength == 473) { pinOutLED = pin473LED; pinOutLaser = pin473Laser; }  
    else if (wavelength == 593) { pinOutLED = pin593LED; pinOutLaser = pin593Laser; }
    else if (wavelength == 635) { pinOutLED = pin593LED; pinOutLaser = pin593Laser; }
    digitalWrite(pinOutLED,HIGH);
    digitalWrite(pinOutLaser,HIGH);
    delay(totalDuration*1000);
    digitalWrite(pinOutLaser,LOW);
    digitalWrite(pinOutLED,LOW);
    Mode = 0;
    break;*/
  }
}

/*void checkCommand2()
{
  if (Serial.available()) //check if any character is available
  {
    char chr = Serial.read();
    if (chr >= '0' && chr <= '9')
    {
      totalDuration = (chr - '0');
      Mode = 4;
      Serial.println(totalDuration);
      
    }    
  }
}*/

//function to check trigger/continous/reset
void checkCommand()
{
  if (Serial.available()) //check if any character is available
  {
     // wavelength, expduration, cycleduration, dutylength, pulsefreq, pulsewidth, startat1, stopat1, startat2, stopat2, pinLaser1, pinLaser2
    char ch = Serial.read();
    if (ch == 'p'){ // start laser session
      wavelength = valueRead();
      expduration = valueRead();
      cycleduration = valueRead();
      dutylength = valueRead();
      pulsefreq = valueRead();
      pulsewidth = valueRead();
      start1 = valueRead();
      stop1 = valueRead();
      start2 = valueRead();
      stop2 = valueRead();
      LaserChannel1 = valueRead();
      LaserChannel2 = valueRead();

      
      count++;
      Serial.println("Mode = ");
      Serial.println(Mode);
      Serial.println("wavelength = ");
      Serial.println(wavelength);
      Serial.println("expduration = ");
      Serial.println(expduration);
      Serial.println("cycleduration = ");
      Serial.println(cycleduration);
      Serial.println("dutylength = ");
      Serial.println(dutylength);
      Serial.println("pulsefreq = ");
      Serial.println(pulsefreq);
      Serial.println("pulsewidth = ");
      Serial.println(pulsewidth);
      Serial.println("start1 = ");
      Serial.println(start1);
      Serial.println("stop1 = ");
      Serial.println(stop1);
      Serial.println("start2 = ");
      Serial.println(start2);
      Serial.println("stop2 = ");
      Serial.println(stop2);
      Serial.println("LaserChan1 = ");
      Serial.println(LaserChannel1);
      Serial.println("LaserChan2 = ");
      Serial.println(LaserChannel2);
      Serial.println("count = ");
      Serial.println(count);
      Mode = 3;}
    else if(ch == 'q' && Mode == 3) {
      Mode = 4;}// pause
    else if(ch == 's' && Mode != 1){
      Mode = 0;}//stop & reset
  }
}

int valueRead()
{
  value = 0;
  while (1)
  {
    char chr = Serial.read();
    if (chr >= '0' && chr <= '9') { value = value * 10 + (chr - '0'); }
    else if (chr == '-') { value = 0; }
    else if (chr == ',') { return value; }    
  }
}
