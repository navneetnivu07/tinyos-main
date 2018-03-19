#include "TestCM5000.h"
#include <printf.h>

module TestCM5000P @safe() {
  uses {
  
  	// Main, Leds
    interface Boot;
    interface Leds;
    
	// Timers
	interface Timer<TMilli>  as SampleTimer;
	
	// Sensors    
	interface Read<uint16_t> as Vref;
  	interface Read<uint16_t> as Temperature;    
  	interface Read<uint16_t> as Humidity;    
	interface Read<uint16_t> as Photo;
	interface Read<uint16_t> as Radiation;
  }
}

implementation
{

	event void Boot.booted() {
		call SampleTimer.startPeriodic(DEFAULT_TIMER); // Start timer
	}

	event void SampleTimer.fired() {
		call Vref.read();
		call Temperature.read();
		call Humidity.read();
		call Photo.read();
		call Radiation.read();
	}

	event void Vref.readDone(error_t result, uint16_t value) {
		printf("Vref: %d \r\n", value);

	}

	event void Temperature.readDone(error_t result, uint16_t value) {
        printf("Temperature: %d \r\n", value);
        temperature = (-39.60 + 0.01 * val);
		if (result == SUCCESS){
			printf("current temperature is: %d \r\n", temperature);
		}else{
			printf("Error reading from sensors \r\n");
		}

	}

	event void Humidity.readDone(error_t result, uint16_t value) {
	    printf("Humidity: %d \r\n", value);
	    humidity = -4 + 0.0405*val + (-2.8 * pow(10,-6))*pow(val,2);
		humidity_true = (temperature - 25) * (0.01 + 0.00008*val) + humidity;
		if (result == SUCCESS){
			printf("current humidity is: %d \r\n", humidity_true);
		}else{
			printf("Error reading from sensors \r\n");
		}

	}    

	event void Photo.readDone(error_t result, uint16_t value) {
	    printf("Photo: %d \r\n", value);
	    luminance = 2.5 *((val/4096.0) *6250.0);
		if (result == SUCCESS){
			printf("current light is: %d \r\n", luminance);
		}else{
			printf("Error reading from sensors \r\n");
		}

	}  

	event void Radiation.readDone(error_t result, uint16_t value) {
	    printf("Radiation: %d \r\n", value);

	}

}// End  
