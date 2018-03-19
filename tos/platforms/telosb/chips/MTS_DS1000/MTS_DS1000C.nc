/*****************************************************************************************
 * Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 * Copyright (c) 2005 Arch Rock Corporation
 * All rights reserved.
 * Copyright (c) 2006, Technische Universitaet Berlin
 * All rights reserved.
 * Copyright (c) 2010, ADVANTIC Sistemas y Servicios S.L.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 *
 *    * Redistributions of source code must retain the above copyright notice, this list  
 * of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright notice, this  
 * list of conditions and the following disclaimer in the documentation and/or other 
 * materials provided with the distribution.
 *    * Neither the name of ADVANTIC Sistemas y Servicios S.L. nor the names of its 
 * contributors may be used to endorse or promote products derived from this software 
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Revision -------------------------------------------------------------
 * $Revision: 1.0 $
 * $Date: 2010/12/12 18:24:06 $
 * @author: Manuel Fernandez <manuel.fernandez@advanticsys.com>
*****************************************************************************************/

generic configuration MTS_DS1000C() 
{
   provides 
   {
		interface DeviceMetadata;
				
		interface Read<uint16_t> as CO_Sensor_GS_02A;
		interface Read<uint16_t> as CO2_Sensor_SH_300_DH;
		interface Read<uint16_t> as Temp_Sensor_NTC_103F345FC;

  
		interface ReadStream<uint16_t> as CO_Sensor_GS_02A_Stream;
		interface ReadStream<uint16_t> as CO2_Sensor_SH_300_DH_Stream;
		interface ReadStream<uint16_t> as Temp_Sensor_NTC_103F345FC_Stream;
	}
}

implementation 
{
	components       MTS_DS1000P;               // Sensors data configuration
	DeviceMetadata = MTS_DS1000P;
    
	//--Read--
	components new AdcReadClientC() as AdcRead_CO_Sensor_GS_02A;
	components new AdcReadClientC() as AdcRead_CO2_Sensor_SH_300_DH;
	components new AdcReadClientC() as AdcRead_Temp_Sensor_NTC_103F345FC;

	CO_Sensor_GS_02A 		 			= AdcRead_CO_Sensor_GS_02A;
	CO2_Sensor_SH_300_DH 			= AdcRead_CO2_Sensor_SH_300_DH;
	Temp_Sensor_NTC_103F345FC = AdcRead_Temp_Sensor_NTC_103F345FC;	

	AdcRead_CO_Sensor_GS_02A.AdcConfigure 				 -> MTS_DS1000P.CO_Sensor_GS_02A;
	AdcRead_CO2_Sensor_SH_300_DH.AdcConfigure 		 -> MTS_DS1000P.CO2_Sensor_SH_300_DH;
	AdcRead_Temp_Sensor_NTC_103F345FC.AdcConfigure -> MTS_DS1000P.Temp_Sensor_NTC_103F345FC;

	
	//--Read Stream--
	components new AdcReadStreamClientC() as AdcReadStream_CO_Sensor_GS_02A;
	components new AdcReadStreamClientC() as AdcReadStream_CO2_Sensor_SH_300_DH;
	components new AdcReadStreamClientC() as AdcReadStream_Temp_Sensor_NTC_103F345FC;
	
	CO_Sensor_GS_02A_Stream 				 = AdcReadStream_CO_Sensor_GS_02A;
	CO2_Sensor_SH_300_DH_Stream 		 = AdcReadStream_CO2_Sensor_SH_300_DH;
	Temp_Sensor_NTC_103F345FC_Stream = AdcReadStream_Temp_Sensor_NTC_103F345FC;
  
	AdcReadStream_CO_Sensor_GS_02A.AdcConfigure 		-> MTS_DS1000P.CO_Sensor_GS_02A;
	AdcReadStream_CO2_Sensor_SH_300_DH.AdcConfigure -> MTS_DS1000P.CO2_Sensor_SH_300_DH;
	AdcReadStream_Temp_Sensor_NTC_103F345FC					-> MTS_DS1000P.Temp_Sensor_NTC_103F345FC;
        
}
