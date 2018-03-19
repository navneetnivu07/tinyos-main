

#include "Timer.h"

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <inttypes.h>


module SerialPrintSenseC @safe() 
{
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
  }
}
implementation
{
  // sampling frequency in binary milliseconds
  #define SAMPLING_FREQUENCY 3000
  
  event void Boot.booted() {
    call Timer.startPeriodic(SAMPLING_FREQUENCY);
  }

  event void Timer.fired() 
  {
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) 
  {
  	      printf("Hello iteration %d\r\n", data);

              printf("%" PRIu16 "\r\n",data);

  	
    if (result == SUCCESS){
      if (data & 0x0004)
        call Leds.led2On();
      else
        call Leds.led2Off();
      if (data & 0x0002)
        call Leds.led1On();
      else
        call Leds.led1Off();
      if (data & 0x0001)
        call Leds.led0On();
      else
        call Leds.led0Off();
    }
  }
}

