#include "printf.h"

module CoSensorPrintC
{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli>;
	
	uses interface Read<uint16_t> as Coread;
	uses interface Read<uint16_t> as Co2read;
	
}
implementation
{
    uint16_t Co;
    uint16_t Co2;
    

	event void Boot.booted()
	{
		
		call Timer.startPeriodic(5000);
		call Leds.led0On();		
	}

	event void Timer.fired()
	{
          call Coread.read();
          call Co2read.read();	
	}

	 event void Coread.readDone(error_t result, uint16_t val)
	{
		if (result == SUCCESS)
		{
			printf("Carbon Monoxide is: %d \r\n", val);
		}
		else
		{
			printf("Error reading from sensors \r\n");
		}	
	}

	event void Co2read.readDone(error_t result, uint16_t val)
	{
		if (result == SUCCESS)
		{
			printf("Carbon Dioxide is: %d \r\n", val);
		}
		else
		{
			printf("Error reading from sensors \r\n");
		}
	}
}
