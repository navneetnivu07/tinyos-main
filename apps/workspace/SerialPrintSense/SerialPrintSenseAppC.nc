configuration SerialPrintSenseAppC{
	
}
implementation{
	
	  components SerialPrintSenseC, MainC, LedsC, new TimerMilliC(), new DemoSensorC() as Sensor;

  SerialPrintSenseC.Boot -> MainC;
  SerialPrintSenseC.Leds -> LedsC;
  SerialPrintSenseC.Timer -> TimerMilliC;
  SerialPrintSenseC.Read -> Sensor;
  
    components SerialPrintfC;
  
}
