#include <ESP8266WiFi.h>

String WIFI_NAME = "TODO";
String WIFI_PASSWORD = "TODO";


void setup() {
  Serial.begin(115200);
  Serial.println();

  WiFi.begin(WIFI_NAME, WIFI_PASSWORD);

  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());
}


void loop() {}

