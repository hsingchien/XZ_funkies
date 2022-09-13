#define pin473LED1 2 // portD 2
#define pin473Laser1 4 // portD 4
#define pin473LED2 5 // portB 5 (pin13)
#define pin473Laser2 4 // portB 4 (pin12)
#define pinIDLE1 7 // portD 7 (pin7)
#define pinIDLE2 0 // portB 5 (pin8)
// 1s are always on port D, 2s are always on port B
//initial settings
int Mode = 0;
int value = 0;
int wavelength = 0;
long expduration = 0;
long cycleduration =0;
long dutylength = 0;
long pulsefreq = 0;
int pulsewidth = 0;
int pinOutLED1;
int pinOutLaser1;
int pinOutLaser2;
int pinOutLED2;
int count = 0;
int LaserChannel1 = 0;
int LaserChannel2 = 0;
long start1 = 0;
long start2 = 0;
long stop1 = 0;
long stop2 = 0;
long i = 0;
long imemory = 0;
bool LEDon1 = 0;
bool LEDon2 = 0;
long time1 = 0;
long time0 = 0;
long time2 = 0;
long time3 = 0;
long timeout = 3600000;
volatile uint8_t *portforLaser1; // pointer to target Port
volatile uint8_t *portforLaser2;

void setup()
{
 Serial.begin(9600);  //Initialize serial port
 //setting of pins
  pinMode(2, OUTPUT); // pin473LED1
  pinMode(4, OUTPUT); // pin473Laser1
  pinMode(8, OUTPUT); // pin473LED2
  pinMode(12, OUTPUT); // pin473Laser2
  pinMode(7, OUTPUT); // pinIDLE1
  pinMode(13, OUTPUT); // pinIDLE2

  
 
} 

void loop()
{
  //digitalWrite(LED_BUILTIN, LOW);
  switch(Mode)
  {
    case 0: // idle mode
    Serial.println("Input all parameters: e.g. p473,20,6,4,20,20,3,18,1,13,4,12,");
    Serial.println("p-wavelength,expdur,cycdur,dutydur,pulsefreq,pulsewidth,start1,stop1,start2,stop2,channel1,channel2");
    // wavelength, expduration, cycleduration, dutylength, pulsefreq, pulsewidth, startat1, stopat1, startat2, stopat2, pinLaser1, pinLaser2
    Mode++;
    break;
    
    case 1:
    checkCommand(); // take input
    break;
    
    case 3:
    // assign Laser channels, assign pinOutLED & pinOutLaser as bitwise shift
    
    if (LaserChannel1 == 4) {
      pinOutLED1 = pin473LED1; pinOutLaser1 = pin473Laser1; portforLaser1 = &PORTD;}
    else if (LaserChannel1 == 12) {
      pinOutLED1 = pin473LED2; pinOutLaser1 = pin473Laser2; portforLaser1 = &PORTB;} 
    else 
    {
      Serial.println("Stim1 is IDLE, NO LASER!");
      pinOutLED1 = pin473LED1;  
      pinOutLaser1 = pinIDLE1;
      portforLaser1 = &PORTD;
      } 
    if (LaserChannel2 == 4) {
      pinOutLED2 = pin473LED1; pinOutLaser2 = pin473Laser1; portforLaser2 = &PORTD;}
    else if (LaserChannel2 == 12) {
      pinOutLED2 = pin473LED2; pinOutLaser2 = pin473Laser2; portforLaser2 = &PORTB;} 
    else 
    {
      Serial.println("Stim2 is IDLE, NO LASER!");
      pinOutLED2 = pin473LED2;  
      pinOutLaser2 = pinIDLE2;
      portforLaser2 = &PORTB;
      }

    time0 = millis();
    for (i = imemory; i < (expduration * pulsefreq); i++) // total number of pulses
    {
      //Serial.println(i);
      time2 = millis();
      if( i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop1*pulsefreq){
        //digitalWrite(pinOutLaser1,HIGH);
        *portforLaser1 |= (1<<pinOutLaser1); // turn on laser 1
        //Serial.println("Laser1 on!"); time1 = millis(); Serial.println(time1-time0);
      }
      if(!LEDon1 && i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) < dutylength * pulsefreq && i < stop1*pulsefreq){
        //digitalWrite(pinOutLED1,HIGH);
        *portforLaser1 |= (1<<pinOutLED1); // turn on led 1
        LEDon1 = 1; //Serial.println("LED1 is on at"); time1 = millis(); Serial.println(time1-time0);
      } else if (LEDon1 && (i>=stop1*pulsefreq || (i-start1*pulsefreq) % (cycleduration*pulsefreq) >= dutylength * pulsefreq)){
        //digitalWrite(pinOutLED1,LOW);
        *portforLaser1 &= ~(1<<pinOutLED1);
        //Serial.println("LED1 is off at"); time1 = millis(); Serial.println(time1-time0);
        LEDon1 = 0; 
      }

      if(i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop2*pulsefreq){
        //digitalWrite(pinOutLaser2,HIGH); 
        *portforLaser2 |= (1<<pinOutLaser2); // turn on laser 2 (pin7)
        //Serial.println("Laser2 on!"); time1 = millis(); Serial.println(time1-time0);
        }
      if(!LEDon2 && i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) < dutylength * pulsefreq && i < stop2*pulsefreq){
        //digitalWrite(pinOutLED2,HIGH);
        *portforLaser2 |= (1<<pinOutLED2); // turn on led 2 (pin8)
        LEDon2 = 1; //Serial.println("LED2 is on at"); time1 = millis(); Serial.println(time1-time0);
      } else if (LEDon2 && (i>=stop2*pulsefreq || (i-start2*pulsefreq) % (cycleduration*pulsefreq) >= dutylength * pulsefreq)){
        //digitalWrite(pinOutLED2,LOW); 
        *portforLaser2 &= ~(1<<pinOutLED2); // turn off led 2 (pin8)
        //Serial.println("LED2 is off at"); time1 = millis(); Serial.println(time1-time0);
        LEDon2 = 0;
      }
      
      delay(pulsewidth);
      
      if( i >= start1*pulsefreq && (i-start1*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop1*pulsefreq){
        //digitalWrite(pinOutLaser1,LOW);
        *portforLaser1 &= ~(1<<pinOutLaser1);
        //Serial.println("Laser1 off!"); //time1 = millis(); Serial.println(time1-time0);
        }
      if(i >= start2*pulsefreq && (i-start2*pulsefreq) % (cycleduration*pulsefreq) <dutylength * pulsefreq && i < stop2*pulsefreq){
        //digitalWrite(pinOutLaser2,LOW);
        *portforLaser2 &= ~(1<<pinOutLaser2); 
        //Serial.println("Laser2 off!"); //time1 = millis(); Serial.println(time1-time0);
        }
     
      checkCommand();
      if (Mode == 4) {imemory = i+1; break;} else if (Mode == 0){break;}
      time3 = millis();
      //Serial.println("cycle time"); Serial.println(time3-time2);
      
      delay(max(1000/pulsefreq - (time3 - time2),0)); // to avoid negative value
      //Serial.println(max(1000/long(pulsefreq) - (time3 - time2),0));
    }
    if (Mode == 4){
      LEDon1 = 0;
      LEDon2 = 0;
      *portforLaser1 &= ~(1<<pinOutLaser1);
      *portforLaser2 &= ~(1<<pinOutLaser2); 
      *portforLaser1 &= ~(1<<pinOutLED1);
      *portforLaser2 &= ~(1<<pinOutLED2);
      break;
      } 
    else if (Mode == 0) {
      imemory = 0; 
      LEDon1 = 0;
      LEDon2 = 0;
      *portforLaser1 &= ~(1<<pinOutLaser1);
      *portforLaser2 &= ~(1<<pinOutLaser2); 
      *portforLaser1 &= ~(1<<pinOutLED1);
      *portforLaser2 &= ~(1<<pinOutLED2);
      break;
      }
    *portforLaser1 &= ~(1<<pinOutLaser1);
    *portforLaser2 &= ~(1<<pinOutLaser2); 
    *portforLaser1 &= ~(1<<pinOutLED1);
    *portforLaser2 &= ~(1<<pinOutLED2);
    imemory = 0;
    Mode = 0;
    LEDon1 = 0;
    LEDon2 = 0;
    break;

    case 5: // constant ON state
    if (LaserChannel1 == 4) {
      pinOutLED1 = pin473LED1; pinOutLaser1 = pin473Laser1; portforLaser1 = &PORTD;}
    else if (LaserChannel1 == 12) {
      pinOutLED1 = pin473LED2; pinOutLaser1 = pin473Laser2; portforLaser1 = &PORTB;} 
    else 
    {
      Serial.println("Stim1 is IDLE, NO LASER!");
      pinOutLED1 = pin473LED1;  
      pinOutLaser1 = pinIDLE1;
      portforLaser1 = &PORTD;
      } 
    if (LaserChannel2 == 4) {
      pinOutLED2 = pin473LED1; pinOutLaser2 = pin473Laser1; portforLaser2 = &PORTD;}
    else if (LaserChannel2 == 12) {
      pinOutLED2 = pin473LED2; pinOutLaser2 = pin473Laser2; portforLaser2 = &PORTB;} 
    else 
    {
      Serial.println("Stim2 is IDLE, NO LASER!");
      pinOutLED2 = pin473LED2;  
      pinOutLaser2 = pinIDLE2;
      portforLaser2 = &PORTB;
      }

    time0 = millis();
    *portforLaser1 |= (1<<pinOutLED1); // turn on led 1
    *portforLaser2 |= (1<<pinOutLED2); //turn on LED2
    while (true) 
    {
      //Serial.println(i);
      time2 = millis();
      if ((time2 -time0) >= timeout) {Mode = 0; break;}

      *portforLaser1 |= (1<<pinOutLaser1); // turn on laser 1

      *portforLaser2 |= (1<<pinOutLaser2); // turn on laser 2 (pin7)
      
      
      delay(pulsewidth);
      
      *portforLaser1 &= ~(1<<pinOutLaser1);
      *portforLaser2 &= ~(1<<pinOutLaser2); 
      
      checkCommand();
      if (Mode == 0){break;}
      time3 = millis();
      //Serial.println("cycle time"); Serial.println(time3-time2);
      
      delay(max(1000/pulsefreq - (time3 - time2),0)); // to avoid negative value
      //Serial.println(max(1000/long(pulsefreq) - (time3 - time2),0));
    }
    if (Mode == 0) {
      *portforLaser1 &= ~(1<<pinOutLaser1);
      *portforLaser2 &= ~(1<<pinOutLaser2); 
      *portforLaser1 &= ~(1<<pinOutLED1);
      *portforLaser2 &= ~(1<<pinOutLED2);
      break;
      }
    break;

    
    case 4: // pause state
    //digitalWrite(LED_BUILTIN, HIGH); delay(200); digitalWrite(LED_BUILTIN, LOW);
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



  }
}


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
    else if(ch == 'c' && (Mode != 3 || Mode != 4)){ // constant on mode
      wavelength = valueRead();
      pulsefreq = valueRead();
      pulsewidth = valueRead();
      LaserChannel1 = valueRead();
      LaserChannel2 = valueRead();
      Serial.println(LaserChannel1);
      Serial.println(LaserChannel2);
      Mode = 5;
    }
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
