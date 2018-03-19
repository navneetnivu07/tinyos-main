#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration CoSensorPrintAppC
{
	
}
implementation
{
	components CoSensorPrintC as App;
	components MainC;
	components LedsC;
	components new TimerMilliC();
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
	
	components new MTS_DS1000C() as Csensor;
	App.Coread -> Csensor.CO_Sensor_GS_02A;
	App.Co2read -> Csensor.CO2_Sensor_SH_300_DH;

	//components new HamamatsuS10871TsrC() as Lsensor;
	//App.Lightread -> Lsensor;

	components PrintfC;
  	components SerialStartC;
	
  	//components new HamamatsuS1087ParC() as TotalSolarC;

  	//App.Solarread -> TotalSolarC;
	
}
