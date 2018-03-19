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

#include "Msp430Adc12.h"


module MTS_DS1000P 
{
	provides interface DeviceMetadata;
	provides interface AdcConfigure<const msp430adc12_channel_config_t*> as CO_Sensor_GS_02A;
	provides interface AdcConfigure<const msp430adc12_channel_config_t*> as CO2_Sensor_SH_300_DH;
	provides interface AdcConfigure<const msp430adc12_channel_config_t*> as Temp_Sensor_NTC_103F345FC;
}

implementation 
{
	const msp430adc12_channel_config_t config_CO_Sensor_GS_02A= {
		inch:	   INPUT_CHANNEL_A5, 
		sref:      REFERENCE_VREFplus_AVss,
		ref2_5v:   REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div:  SHT_CLOCK_DIV_1,
		sht:       SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id:   SAMPCON_CLOCK_DIV_1
		};
  
const msp430adc12_channel_config_t config_CO2_Sensor_SH_300_DH = {
		inch:	   INPUT_CHANNEL_A3, 
		sref:      REFERENCE_VREFplus_AVss,
		ref2_5v:   REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div:  SHT_CLOCK_DIV_1,
		sht:       SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id:   SAMPCON_CLOCK_DIV_1
		};

const msp430adc12_channel_config_t config_Temp_Sensor_NTC_103F345FC = {
		inch:	INPUT_CHANNEL_A4, 
		sref: REFERENCE_VREFplus_AVss,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div:	SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id: SAMPCON_CLOCK_DIV_1
		};
		
  async command const msp430adc12_channel_config_t* CO_Sensor_GS_02A.getConfiguration() {
    return &config_CO_Sensor_GS_02A;
  }

  async command const msp430adc12_channel_config_t* CO2_Sensor_SH_300_DH.getConfiguration() {
    return &config_CO2_Sensor_SH_300_DH;
  }

  async command const msp430adc12_channel_config_t* Temp_Sensor_NTC_103F345FC.getConfiguration() {
    return &config_Temp_Sensor_NTC_103F345FC;
  }

 command uint8_t DeviceMetadata.getSignificantBits() { return 12; }
}
