// pins motorshield
int pinDir1 = D6; // 8
int pinSpeed1 = D8; // 10

/*
int pinDir1 = D5; // 8
int pinSpeed1 = D7; // 10*/

void setup() {

  // init serial
  Serial.begin(115200);

  // pin modes
  pinMode(pinDir1, OUTPUT);
  pinMode(pinSpeed1, OUTPUT);

}


void loop() {

  // test motor

  // direction
  digitalWrite(pinDir1, LOW);

  analogWrite(pinSpeed1, 1023);
  delay(1500);
  analogWrite(pinSpeed1, 0);
  delay(1500);


  digitalWrite(pinDir1, HIGH);

  analogWrite(pinSpeed1, 500);
  delay(1500);
  analogWrite(pinSpeed1, 0);
  delay(1500);


}
