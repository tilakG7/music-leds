# Music LEDs

## Description
Check videos of this project: [here](https://www.youtube.com/watch?v=JqFhMSmfuxY) and [here](https://www.youtube.com/watch?v=llXvh4BSNa4). 

LEDs synchronized with music to help visualize sound and create cool visual lighting. LEDs primarily react to the rhythm and beats of a song.

## Firmware/Software
This project uses the [Processing](https://processing.org/) software to analyse sound. It then communicates with the Particle Core via USB to switch LED colors using the Core's PWM pins. Beats are detected in the music and the brightness of the LEDs' color is set accordingly. Communication between the computer software and the core is handled by a lightweight custom serial communication protocol. This protocol minimizes any unwanted flicker in the LEDs due to delay of sound processing.

## Hardware
* Particle Core (Originally Spark Core)
* 3 TIP122 NPN Darlington Transistors
* 3 100 ohm resistors
* 12 Volt Power Adapter
* 12 Volt RGB LED Strip

Schematic similar to the one shown [here](https://cdn-learn.adafruit.com/assets/assets/000/002/693/original/led_strips_ledstripbjt.gif?1448059603)


