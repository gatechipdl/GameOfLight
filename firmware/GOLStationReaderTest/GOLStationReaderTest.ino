#define PIN_READER1 14
#define PIN_READER2 16

void setup() {
  Serial.begin(9600);
}

void loop() {
  int front = digitalRead(PIN_READER1);
  int back = digitalRead(PIN_READER2);
  Serial.print("front: ");
  Serial.print(front);
  Serial.print(", back: ");
  Serial.print(back);
  Serial.println();
  delay(250);
}
