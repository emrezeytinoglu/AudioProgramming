
#define DRY_WET_PIN     4
#define CHARACTER_PIN   5
#define LENGTH_PIN      6
#define AIR_PIN         7
#define NOISE_PIN       1
#define DELAY_TIME_PIN  2
#define DELAY_FB_PIN    13
#define DELAY_MIX_PIN   14
#define FREQ_RATE_PIN   8
#define FREQ_AMT_PIN    9
#define FREQ_MIX_PIN    15

#define ROOM_BTN        10
#define HALL_BTN        11
#define CATHEDRAL_BTN   12
#define LFO_BTN         17
#define LFO_SINE_LED    18
#define LFO_TRI_LED     19
#define LFO_SQR_LED     20

int lfo_index = 0;
unsigned long lastLfoPress = 0;
String lfoShapes[3] = {"sine", "triangle", "square"};

String currentPreset = "-";
unsigned long lastPresetPress = 0;
const int presetDebounce = 200;

void setup() {
  Serial.begin(115200);


  pinMode(ROOM_BTN, INPUT_PULLUP);
  pinMode(HALL_BTN, INPUT_PULLUP);
  pinMode(CATHEDRAL_BTN, INPUT_PULLUP);
  pinMode(LFO_BTN, INPUT_PULLUP);


  pinMode(LFO_SINE_LED, OUTPUT);
  pinMode(LFO_TRI_LED, OUTPUT);
  pinMode(LFO_SQR_LED, OUTPUT);
}

void loop() {

  float dryWet     = analogRead(DRY_WET_PIN)     / 4095.0;
  float character  = analogRead(CHARACTER_PIN)   / 4095.0;
  float length     = analogRead(LENGTH_PIN)      / 4095.0;
  float air        = analogRead(AIR_PIN)         / 4095.0;
  float noiseAmp   = analogRead(NOISE_PIN)       / 4095.0;
  float delayTime  = analogRead(DELAY_TIME_PIN)  / 4095.0;
  float delayFb    = analogRead(DELAY_FB_PIN)    / 4095.0;
  float delayMix   = analogRead(DELAY_MIX_PIN)   / 4095.0;
  float fsRate     = analogRead(FREQ_RATE_PIN)   / 4095.0;
  float fsAmount   = analogRead(FREQ_AMT_PIN)    / 4095.0;
  float fsMix      = analogRead(FREQ_MIX_PIN)    / 4095.0;


  if (millis() - lastPresetPress > presetDebounce) {
    if (!digitalRead(ROOM_BTN)) {
      currentPreset = (currentPreset != "Room") ? "Room" : "-";
      lastPresetPress = millis();
    } else if (!digitalRead(HALL_BTN)) {
      currentPreset = (currentPreset != "Hall") ? "Hall" : "-";
      lastPresetPress = millis();
    } else if (!digitalRead(CATHEDRAL_BTN)) {
      currentPreset = (currentPreset != "Cathedral") ? "Cathedral" : "-";
      lastPresetPress = millis();
    }
  }


  if (currentPreset == "Room") {
    pinMode(ROOM_BTN, OUTPUT); digitalWrite(ROOM_BTN, HIGH); delay(1);
    pinMode(HALL_BTN, OUTPUT); digitalWrite(HALL_BTN, LOW); delay(1);
    pinMode(CATHEDRAL_BTN, OUTPUT); digitalWrite(CATHEDRAL_BTN, LOW); delay(1);
  }
  else if (currentPreset == "Hall") {
    pinMode(ROOM_BTN, OUTPUT); digitalWrite(ROOM_BTN, LOW); delay(1);
    pinMode(HALL_BTN, OUTPUT); digitalWrite(HALL_BTN, HIGH); delay(1);
    pinMode(CATHEDRAL_BTN, OUTPUT); digitalWrite(CATHEDRAL_BTN, LOW); delay(1);
  }
  else if (currentPreset == "Cathedral") {
    pinMode(ROOM_BTN, OUTPUT); digitalWrite(ROOM_BTN, LOW); delay(1);
    pinMode(HALL_BTN, OUTPUT); digitalWrite(HALL_BTN, LOW); delay(1);
    pinMode(CATHEDRAL_BTN, OUTPUT); digitalWrite(CATHEDRAL_BTN, HIGH); delay(1);
  }
  else {
    pinMode(ROOM_BTN, OUTPUT); digitalWrite(ROOM_BTN, LOW); delay(1);
    pinMode(HALL_BTN, OUTPUT); digitalWrite(HALL_BTN, LOW); delay(1);
    pinMode(CATHEDRAL_BTN, OUTPUT); digitalWrite(CATHEDRAL_BTN, LOW); delay(1);
  }


  pinMode(ROOM_BTN, INPUT_PULLUP);
  pinMode(HALL_BTN, INPUT_PULLUP);
  pinMode(CATHEDRAL_BTN, INPUT_PULLUP);


  if (!digitalRead(LFO_BTN) && (millis() - lastLfoPress > 300)) {
    lfo_index = (lfo_index + 1) % 3;
    lastLfoPress = millis();
  }

  digitalWrite(LFO_SINE_LED, lfo_index == 0);
  digitalWrite(LFO_TRI_LED,  lfo_index == 1);
  digitalWrite(LFO_SQR_LED,  lfo_index == 2);


  Serial.print(dryWet, 2);      Serial.print(",");
  Serial.print(character, 2);   Serial.print(",");
  Serial.print(length, 2);      Serial.print(",");
  Serial.print(air, 2);         Serial.print(",");
  Serial.print(noiseAmp, 2);    Serial.print(",");
  Serial.print(delayMix, 2);    Serial.print(",");
  Serial.print(delayTime, 2);   Serial.print(",");
  Serial.print(delayFb, 2);     Serial.print(",");
  Serial.print(fsRate, 2);      Serial.print(",");
  Serial.print(fsAmount, 2);    Serial.print(",");
  Serial.print(fsMix, 2);       Serial.print(",");
  Serial.print(currentPreset);  Serial.print(",");
  Serial.println(lfoShapes[lfo_index]);

  delay(50);
}
