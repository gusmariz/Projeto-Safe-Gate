void setup() {
  Serial.begin(9600);
  pinMode(13, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {
    String acao = Serial.readStringUntil('\n');

    if (acao == 'abrir') {
      digitalWrite(13, HIGH);
      Serial.println('Portão aberto!');
    } else if (acao == 'fechar') {
      digitalWrite(13, LOW);
      Serial.println('Portão fechado!');
    }
  }
}