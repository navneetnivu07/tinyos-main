#include<Timer.h>   // Header file to use timer component
#include<stdio.h>    // Standard Input Output
#include<string.h>  //  Various operations, such as copying, concatenation, 				      tokenization
module TempC
{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli>;
	uses interface Read<uint16_t> as Tempread;
	uses interface Read<uint16_t> as Lightread;
}

implementation
{
    uint16_t centiGrade;
    uint16_t luminance;	

	event void Boot.booted()
	{
		call Timer.startPeriodic(1000);
		call Leds.led0On();
	}

	event void Timer.fired()
	{
		if (call Tempread.read() == SUCCESS)
		{
			call Leds.led2Toggle();
		}
		else 
		{
			call Leds.led0Toggle();
		}
		if (call Lightread.read() == SUCCESS)
		{
			call Leds.led2Toggle();
		}
		else 
		{
			call Leds.led0Toggle();
		}
	}

	event void Tempread.readDone(error_t result, uint16_t val)
	{
		centiGrade = (-39.60 + 0.01 * val);
		if (result == SUCCESS)
		{
			printf("current temperature is: %d \r\n", centiGrade);
		}
		else
		{
			printf("Error reading from sensors \r\n");
		}
	}

	event void Lightread.readDone(error_t result, uint16_t val)
	{
		luminance = 2.5 *((val/4096.0) *6250.0);
		if (result == SUCCESS)
		{
			printf("current light is: %d \r\n", luminance);
		}
		else
		{
			printf("Error reading from sensors \r\n");
		}
	}
}