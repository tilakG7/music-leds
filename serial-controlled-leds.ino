SYSTEM_MODE(MANUAL);

int RED_PIN = A1;
int GREEN_PIN = A0;
int BLUE_PIN = A4;

bool isOutputting = false; //indicates whether core has started driving LEDs
int colorOutput = 0;       //tracks which LED color to output to (R, G or B)

void setup() {
    pinMode(RED_PIN, OUTPUT);
    pinMode(GREEN_PIN, OUTPUT);
    pinMode(BLUE_PIN, OUTPUT);
    pinMode(D7, OUTPUT);

    Serial.begin(9600);
}

void loop() {
    if(!isOutputting)
        Serial.write(255); //send high signals to indicate ready
    
    if(Serial.available() && !isOutputting)
        //if received a reply, start driving LEDs
        if(Serial.read() == 255)
            isOutputting = true; 
            
    if (Serial.available() && isOutputting)
    {
        digitalWrite(D7, HIGH);
        int data = Serial.read();
        
        //adjust either red, green or blue brightness
        //based on value of color output
        if(colorOutput == 0)
        {
            analogWrite(RED_PIN, data);
            colorOutput++;
        }
        else if(colorOutput == 1)
        {
            analogWrite(GREEN_PIN, data);
            colorOutput++;
        }
        else if(colorOutput == 2)
        {
            analogWrite(BLUE_PIN, data);
            colorOutput = 0;
        }
    }
}
