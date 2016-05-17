import ddf.minim.*;           //audio library
import ddf.minim.analysis.*;  //audio library

import processing.serial.*;   //for serial communication with core

Minim minim;
AudioPlayer player;
BeatDetect beat;
BeatListener listener;
Serial serial;

float[] currentRGB = {255, 68, 219};    //red, green, blue values to be sent to core (range: 0 - 255)
float[] currentHSV = {312, 0.733, 1.0}; //hue, saturation, brightness (HSV color model), 
                                        //used to adjust brightness of a certain color
float valueFactor = 0;

boolean ready = false;  //ready to send serial commands to core

//needed so as to not miss an audio buffer
class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;
  
  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}



void setup()
{
  size(1000, 800); //size of window
  
  minim = new Minim(this);
  
  serial = new Serial(this, "COM4", 9600); //open serial connection @ 9600 baud
  
  player = minim.loadFile("knight.mp3", 1024); //load mp3 file
  player.play();                                       //play song

  beat = new BeatDetect(player.bufferSize(), player.sampleRate());
  beat.setSensitivity(600); //a beat can only be registered every 600ms
  
  valueFactor = beat.detectSize(); //max possible number of beats

  listener = new BeatListener(beat, player);  
  
  fill(currentRGB[0], currentRGB[1], currentRGB[2]);
}

//loops very fast continously
void draw()
{
  background(0);

  int numBeats = getNumBeats();
  
  //dim the LEDs if no beats detected
  if(numBeats == 0)
  {
    currentHSV[2] = constrain((currentHSV[2] - 0.1), 0.20, 1.0);
  }
  //set brighntess according to number of beats
  else
  {
    currentHSV[2] = 0.70 + constrain((0.30 / valueFactor * numBeats), 0, 0.29);
  }
  
  float[] setRGB = getCurrentRGB();
  fill(setRGB[0], setRGB[1], setRGB[2]);
  rect(0, 0, width, height);
  
  if(!ready && serial.available() > 0)
  {
   if(serial.read() == 255)
   {
     serial.write(255); //send HIGH signal to core to acknowledge start of serial communication
     ready = true; 
   }
  }
  else if (ready)
  {
    serial.write(int(setRGB[0])); //red led brightness
    serial.write(int(setRGB[1])); //green led brightness
    serial.write(int(setRGB[2])); //blue led brightness
  }
}

//converts current HSV color to RGB color
float[] getCurrentRGB()
{
    float intermediate1 = currentHSV[1] * currentHSV[2];
    float intermediate2 = intermediate1 * (1 - abs(((currentHSV[0] / 60.0) % 2) - 1));
    float intermediate3 = currentHSV[2] - intermediate1;
    
    float[] rgb = {0, 0, 0};
    
    if(currentHSV[0] < 60)
    {
      rgb[0] = intermediate1;
      rgb[1] = intermediate2;
    }
    else if(currentHSV[0] < 120)
    {
      rgb[0] = intermediate2;
      rgb[1] = intermediate1;
    }
    else if(currentHSV[0] < 180)
    {
      rgb[1] = intermediate1;
      rgb[2] = intermediate2;
    }
    else if(currentHSV[0] < 240)
    {
      rgb[1] = intermediate2;
      rgb[2] = intermediate1;
    }
    else if(currentHSV[0] < 300)
    {
      rgb[0] = intermediate2;
      rgb[2] = intermediate1;
    }
    else
    {
      rgb[0] = intermediate1;
      rgb[2] = intermediate2;
    }
    rgb[0] = (rgb[0] + intermediate3) * 255.0;
    rgb[1] = (rgb[1] + intermediate3) * 255.0;
    rgb[2] = (rgb[2] + intermediate3) * 255.0;
    
    return rgb;      
}

//returns number of beats detected
int getNumBeats()
{
  int numFreqBands = beat.detectSize(); 
  int numBeats = 0;
  
  //check each frequency band to see if beat detected
  for(int i=0; i < numFreqBands; i++)
   if(beat.isOnset(i))
     numBeats++;
      
  return numBeats;
}