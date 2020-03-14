#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

#define PIN 22
#define NUM_LEDS 19
#define BRIGHTNESS 50

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, PIN, NEO_GRB + NEO_KHZ800);
int8_t pixel_i;


void setup() {
  strip.setBrightness(BRIGHTNESS);
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}


void loop() {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    
      if (i == pixel_i)
        strip.setPixelColor(i, random(0xffffff));
      else
        strip.setPixelColor(i, 0x000000);
  }
  strip.show();  
  pixel_i = (++pixel_i) % NUM_LEDS;

  delay(2000 / NUM_LEDS);
}
