/*
 * @author Ricardo Severino <rars@isep.ipp.pt>
 * END DEVICE
 *
 */

#include <Timer.h>
#include "printfUART.h"
#include "log_enable.h"
#include <stdio.h>
#include <stdint.h>

module end_deviceBasicC 
{
	uses {
		interface Boot;
		interface Leds;

		interface NLDE_DATA;

		//NLME NWK Management services
		interface NLME_NETWORK_DISCOVERY;
		interface NLME_JOIN;
		interface NLME_LEAVE;
		interface NLME_SYNC;
		interface NLME_RESET;
		interface NLME_GET;
		interface NLME_SET;

		//Timers
		interface Timer<TMilli> as T_init;
		interface Timer<TMilli> as KeepAliveTimer;
		interface Timer<TMilli> as NetAssociationDeferredTimer;

		#if defined(PLATFORM_TELOSB)
			//user button
			interface Get<button_state_t>;
			interface Notify<button_state_t>;

			interface Read<uint16_t> as Tempread;
			interface Read<uint16_t> as Lightread;
			interface Read<uint16_t> as Humread;
		#endif

	}   
}
implementation
{
	// Depth by configuration
	uint8_t myDepth;
	//boolean variable definig if the device has joined to the PAN
	uint8_t joined;
	// Maximum number of join trials before restart from network discovery
	uint8_t maxJoinTrials;
	uint16_t myParentAddress;

	// Sensor Variables
	uint8_t temperature;
    uint8_t luminance;
    uint8_t humidity;	
	uint8_t humidity_true;	

	task void KeepAlive();

	task void KeepAlive()
	{
		uint8_t nsdu_pay[7];
		
		nsdu_pay[0]=TOS_NODE_ID & 0x00FF;
		nsdu_pay[1]='T';
		nsdu_pay[2]=temperature;
		nsdu_pay[3]='L';
		nsdu_pay[4]=luminance;
		nsdu_pay[5]='H';
		nsdu_pay[6]=humidity_true;

		// Send the message towards the coordinator 
		// (default network address: 0x0000)
		printf("nsdu_pay %s\r\n", nsdu_pay);
		//  command error_t request(uint16_t DstAddr, uint8_t NsduLength, uint8_t Nsdu[120], uint8_t NsduHandle, uint8_t Radius, uint8_t DiscoverRoute, uint8_t SecurityEnable);
		call NLDE_DATA.request(0x0000, 7, nsdu_pay, 0, 1, 0x00, 0);
	}
  
	// This function initializes the variables.
	void initVariables()
	{
		// Depth by configuration (initialize to default)
		myDepth = DEF_DEVICE_DEPTH;  
		//boolean variable definig if the device has joined to the PAN
		joined = 0x00;
		// Maximum number of join trials before restart from network discovery
		maxJoinTrials = MAX_JOIN_TRIALS;
	}

	event void Boot.booted() 
	{

		initVariables();
		
		#if defined(PLATFORM_TELOSB)
			call Notify.enable();  
		#endif

		// Start the application
		call NLME_RESET.request();
	}


	event void Tempread.readDone(error_t result, uint16_t val){
		temperature = (-39.60 + 0.01 * val);
	}

	event void Lightread.readDone(error_t result, uint16_t val){
		luminance = 2.5 *((val/4096.0) *6250.0);
	}

	event void Humread.readDone(error_t result, uint16_t val){
		humidity = -4 + 0.0405*val + (-2.8 * pow(10,-6))*pow(val,2);
		humidity_true = (temperature - 25) * (0.01 + 0.00008*val) + humidity;
	}


	/*****************************************************
	****************NLDE EVENTS***************************
	******************************************************/

	/*************************NLDE_DATA*****************************/

	event error_t NLDE_DATA.confirm(uint8_t NsduHandle, uint8_t Status)
	{
		printf("NLDE_DATA.confirm\r\n", "");
		printf("NsduHandle %d\r\n", NsduHandle);
		printf("Status : %u \r\n", Status);
		if (joined != 0x00)
			call Leds.led1Toggle();
			
		return SUCCESS;
	}

	event error_t NLDE_DATA.indication(uint16_t SrcAddress, uint8_t NsduLength, uint8_t Nsdu[120], uint16_t LinkQuality)
	{
		printf("NLDE_DATA.indication\r\n", "");
		printf("SrcAddress %d\r\n", SrcAddress);
		printf("NsduLength %d\r\n", NsduLength);
		printf("Nsdu %s\r\n", Nsdu);
		printf("LinkQuality %d\r\n", LinkQuality);
		return SUCCESS;
	}

	/*****************************************************
	****************NLME EVENTS***************************
	******************************************************/ 

	/*****************NLME_NETWORK_DISCOVERY**************************/
	// This is not called anymore by the NKWP since it tries to associate 
	// directly to the parent and issuing a JOIN confirm, instead
	event error_t NLME_NETWORK_DISCOVERY.confirm(uint8_t NetworkCount,networkdescriptor networkdescriptorlist[], uint8_t Status)
	{
		printf("NLME_NETWORK_DISCOVERY.confirm\r\n", "");
		printf("NetworkCount : %u \r\n", NetworkCount);
		printf("networkdescriptor : %s \r\n", networkdescriptorlist);
		printf("Status : %u \r\n", Status); 
		return SUCCESS;
	}

	/*************************NLME_JOIN*****************************/
	event error_t NLME_JOIN.indication(uint16_t ShortAddress, uint32_t ExtendedAddress[], uint8_t CapabilityInformation, bool SecureJoin)
	{
		printf("NLME_JOIN.indication\r\n", "");
		printf("ShortAddress : %u \r\n", ShortAddress);
		printf("ExtendedAddress : %u \r\n", ExtendedAddress);
		printf("CapabilityInformation : %u \r\n", CapabilityInformation);
		printf("SecureJoin : %d \r\n", SecureJoin);
		return SUCCESS;
	}

	event error_t NLME_JOIN.confirm(uint16_t PANId, uint8_t Status, uint16_t parentAddress)
	{	
		printf("NLME_JOIN.confirm\r\n", "");
		printf("PANId : %u \r\n", PANId);
		printf("Status : %u \r\n", Status);
		printf("parentAddress : %u \r\n", parentAddress);
		switch(Status)
		{
		case NWK_SUCCESS:
			// Join procedure successful
			joined = 0x01;
			myParentAddress=parentAddress;
			call KeepAliveTimer.startPeriodic(10000);

			break;

		case NWK_NOT_PERMITTED:
			joined = 0x00;
			//join failed
			break;

		case NWK_STARTUP_FAILURE:
			joined = 0x00;
			maxJoinTrials--;
			if (maxJoinTrials == 0)
			{
				// Retry restarting from the network discovery phase
				call T_init.startOneShot(5000);
			}
			else
			{
				// Retry after a few seconds
				call NetAssociationDeferredTimer.startOneShot(JOIN_TIMER_RETRY);
			}
			break;

		default:
			//default procedure - join failed
			joined = 0x00;
			break;
		}
		return Status;
	}

	/*************************NLME_LEAVE****************************/
	event error_t NLME_LEAVE.indication(uint64_t DeviceAddress)
	{
		printf("NLME_LEAVE.indication\r\n", "");
		return SUCCESS;
	}

	event error_t NLME_LEAVE.confirm(uint64_t DeviceAddress, uint8_t Status)
	{
		printf("NLME_LEAVE.confirm\r\n", "");
		joined=0x00;
		return SUCCESS;
	}

	/*************************NLME_SYNC*****************************/
	event error_t NLME_SYNC.indication()
	{
		printf("NLME_SYNC.indication\r\n", "");

		// We lost connection with our parent. Automatic rescan is done
		// at the NWK layer, unless it is after a disassociation request
		
		joined=0x00;
		
		// Stop the keep alive timer, if it is still running
		if (call KeepAliveTimer.isRunning())
			call KeepAliveTimer.stop();
		
		// Switch off all leds
		call Leds.led0Off();
		call Leds.led1Off();
		call Leds.led2Off();

		return SUCCESS;
	}

	event error_t NLME_SYNC.confirm(uint8_t Status)
	{
		printf("NLME_SYNC.confirm\r\n", "");
		printf("Status : %u \r\n", Status);
		return SUCCESS;
	}

	/*****************        NLME-SET     ********************/
	event error_t NLME_SET.confirm(uint8_t Status, uint8_t NIBAttribute)
	{
		printf("NLME_SET.confirm\r\n", "");
		return SUCCESS;
	}

	/*****************        NLME-GET     ********************/
	event error_t NLME_GET.confirm(uint8_t Status, uint8_t NIBAttribute, uint16_t NIBAttributeLength, uint16_t NIBAttributeValue)
	{
		printf("NLME_GET.confirm\r\n", "");
		return SUCCESS;
	}

	event error_t NLME_RESET.confirm(uint8_t status)
	{
		printf("NLME_RESET.confirm\r\n", "");
		printf("Status : %u \r\n", status);
		call T_init.startOneShot(2000);
		return SUCCESS;
	}

	/*****************************************************
	****************TIMER EVENTS***************************
	******************************************************/ 
	/*******************T_init**************************/
	event void T_init.fired() 
	{
		printf("I'm NOT the coordinator\r\n", "");
		call NLME_NETWORK_DISCOVERY.request(LOGICAL_CHANNEL, BEACON_ORDER);
		return;
	}

	/*******************NetAssociationDeferredTimer**************************/
	event void NetAssociationDeferredTimer.fired()
	{
		printf("go join as end device\r\n", ""); 
		call NLME_JOIN.request(MAC_PANID, FALSE, FALSE, 0, 0, 0, 0, 0);
		return;
	}

	/*******************KeepAlive**************************/
	event void KeepAliveTimer.fired()
	{
		call Tempread.read();
        call Lightread.read();
        call Humread.read();
		post KeepAlive();
	}

#if defined(PLATFORM_TELOSB)
	event void Notify.notify(button_state_t state)
	{
		if (state == BUTTON_PRESSED && joined) 
		{
			call KeepAliveTimer.stop();
			call NLME_LEAVE.request(0,0,0);
		}
	}
	#endif

  
}