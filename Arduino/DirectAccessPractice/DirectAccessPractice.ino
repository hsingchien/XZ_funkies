#define LED_PIN1 4
#define LED_PIN2 2
#define LED_PIN3 13
#define LED_PIN4 12
int i = 0;
int time0 = 0;
int time1 = 0;
void setup() {
  // put your setup code here, to run once:
  pinMode(LED_PIN1, OUTPUT);
  pinMode(LED_PIN2, OUTPUT);
  pinMode(LED_PIN3, OUTPUT);
  pinMode(LED_PIN4, OUTPUT);
  Serial.begin(9600);  //Initialize serial port
}

void loop() {
  // put your main code here, to run repeatedly:

    digitalWrite(4,HIGH);
    //PORTD |= (1<<4);
    delayMicroseconds(50);
    //PORTB |= (1<<5);
    //PORTD |= (1<<2);
    //PORTB |= (1<<4);
    
    //digitalWrite(13,HIGH);
    //digitalWrite(2,HIGH);
   // digitalWrite(12,HIGH);
    //delay(3000);
    //delay(100);
    //PORTD &= ~(1<<4);
    digitalWrite(4,LOW);
    delayMicroseconds(50);
    
    //PORTB &= ~(1<<5);
    //PORTD &= ~(1<<2);
    //PORTB &= ~(1<<4);
    //digitalWrite(13,LOW);
    //digitalWrite(12,LOW);
    /*digitalWrite(4,LOW);
    digitalWrite(8,LOW);
    digitalWrite(12,LOW);
    digitalWrite(2,LOW);*/
    //delay(100);
    //time1 = millis();

    //Serial.println(time1-time0);
    
    


}
