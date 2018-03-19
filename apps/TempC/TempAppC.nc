configuration TempAppC
{	
}
implementation
{
	components TempC as App;
	components MainC;
	components LedsC;
	components new TimerMilliC();
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
          components SerialPrintfC;
	components new SensirionSht11C() as Tsensor;
	App.Tempread -> Tsensor.Temperature;
	components new HamamatsuS10871TsrC() as Lsensor;
	App.Lightread -> Lsensor;
}