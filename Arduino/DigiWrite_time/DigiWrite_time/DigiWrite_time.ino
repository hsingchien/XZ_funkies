#define TEST_PIN 8
void setup() 
{
  Serial.begin(9600);
  pinMode(TEST_PIN, OUTPUT);
  unsigned long timeBegin = micros();
  
  for (int i = 0; i < 500; ++i)
  {
    digitalWrite(TEST_PIN,HIGH);
    digitalWrite(TEST_PIN,LOW);
  }
  
  unsigned long timeEnd = micros();
  unsigned long totalDuration = timeEnd - timeBegin;
  double duration = (double)totalDuration / 1000.0;
  Serial.print("Total duration: ");
  Serial.print(totalDuration);
  Serial.println(" µs");
  Serial.print("Duration for one DigitalWrite: ");
  Serial.print(duration);
  Serial.println(" µs");
}
void loop() {}
