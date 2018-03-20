/* ROUTER
 * @author Ricardo Severino <rars@isep.ipp.pt>
 * 
 *
 */

#include <Timer.h>
#include "printfUART.h"
#include "log_enable.h"
#include <stdio.h>
#include <stdint.h>

module routerBasicC 
{
	uses 
	{
		interface Boot;
		interface Leds;

		interface NLDE_DATA;
		//NLME NWK Management services
		interface NLME_NETWORK_DISCOVERY;
		interface NLME_START_ROUTER;
		interface NLME_JOIN;
		interface NLME_LEAVE;
		interface NLME_SYNC;
		interface NLME_RESET;
		interface NLME_GET;
		interface NLME_SET;

		//Timers
		interface Timer<TMilli> as T_init;
		interface Timer<TMilli> as T_schedule;
		interface Timer<TMilli> as NetAssociationDeferredTimer;
	#if defined(PLATFORM_TELOSB)
		//user button
		interface Get<button_state_t>;
		interface Notify<button_state_t>;
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
	//boolean variable defining if the device is waiting for the beacon request response
	uint8_t requested_scheduling;
	//function used to start the beacon broadcast (router devices)
	task void start_sending_beacons_request();

	// This function initializes the variables.
	void initVariables()
	{
		// Depth by configuration (initialize to default)
		myDepth = DEF_DEVICE_DEPTH;
		//boolean variable definig if the device has joined to the PAN
		joined = 0x00;
		// Maximum number of join trials before restart from network discovery
		maxJoinTrials = MAX_JOIN_TRIALS;
		//boolean variable defining if the device is waiting for the beacon request response
		requested_scheduling = 0x00;	
	}

	event void Boot.booted() 
	{
		initVariables();
		call NLME_RESET.request();
	}

	task void start_sending_beacons_request()
	{
		uint8_t nsdu_pay[6];
		beacon_scheduling *beacon_scheduling_ptr;
		beacon_scheduling_ptr = (beacon_scheduling *)&nsdu_pay[0]; 
		   
		beacon_scheduling_ptr->request_type = SCHEDULING_REQUEST;
		beacon_scheduling_ptr->beacon_order = BEACON_ORDER;
		beacon_scheduling_ptr->superframe_order = SUPERFRAME_ORDER;
		beacon_scheduling_ptr->transmission_offset[0] = 0x00;
		beacon_scheduling_ptr->transmission_offset[1] = 0x00;
		beacon_scheduling_ptr->transmission_offset[2] = 0x00;	
		
		requested_scheduling = 0x01;
		
		//lclPrintf("Router: Sending negotiation request\r\n", "");
		printf("Router: Sending negotiation request\r\n", "");
		call NLDE_DATA.request(0x0000, 0x06, nsdu_pay, 0, 1, 0x00, 0);
		
		call T_schedule.startOneShot(20000);   
		return;
	}

	/*****************************************************
	****************NLDE EVENTS***************************
	******************************************************/

	/*************************NLDE_DATA*****************************/

	event error_t NLDE_DATA.confirm(uint8_t NsduHandle, uint8_t Status)
	{
		printf("NLDE_DATA.confirm\r\n", "");
		printf("NsduHandle %d\r\n", NsduHandle);
		printf("Status %d\r\n", Status);

		call Leds.led1Toggle();
		return SUCCESS;
	}

	event error_t NLDE_DATA.indication(uint16_t SrcAddress, uint8_t NsduLength, uint8_t Nsdu[120], uint16_t LinkQuality)
	{
		uint8_t packetCode = Nsdu[0];
		int i;
		// TDBS mechanism
		beacon_scheduling *beacon_scheduling_ptr;
	
		printf("NLDE_DATA.indication\r\n", "");
		printf("SrcAddress %d\r\n", SrcAddress);
		printf("NsduLength %d\r\n", NsduLength);
		printf("LinkQuality %d\r\n", LinkQuality);
		for(i=0; i < NsduLength; i++){
			printf("Nsdu i = %d val = %d\r\n", i, Nsdu[i]);
		}
	
		// The packet is for me (check has been done into MCPS_DATA.indication in NWKP.nc)
		// TDBS mechanism  
		if(requested_scheduling == 0x01)
		{
			//the router receives a negotiation reply
			atomic requested_scheduling = 0x00;    
			// Stop this timer to prevent a further fire event (if any)
			call T_schedule.stop();
			if(packetCode == SCHEDULING_ACCEPT)
			{
				// TDBS Mechanism
				uint32_t start_time = 0x00000000;
				uint16_t start_time1= 0x0000;
				uint16_t start_time2= 0x0000;
				beacon_scheduling_ptr = (beacon_scheduling *)Nsdu;

				start_time1 = ( (beacon_scheduling_ptr->transmission_offset[0] << 0) ) ;
				start_time2 = ( (beacon_scheduling_ptr->transmission_offset[1] << 8 ) | 
								(beacon_scheduling_ptr->transmission_offset[2] << 0 ) );

				start_time  = ( ((uint32_t)start_time1 << 16) | (start_time2 << 0) );

				printf("start_time=0x%x\r\n", start_time);

				call NLME_START_ROUTER.request (
						beacon_scheduling_ptr->beacon_order, 
						beacon_scheduling_ptr->superframe_order, 
						0, 
						start_time);
			}
		}
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

	/*****************NLME_START_ROUTER*****************************/
	event error_t NLME_START_ROUTER.confirm(uint8_t Status)
	{ 
		printf("NLME_START_ROUTER.confirm\r\n", "");
		printf("Status %d\r\n", Status);
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
		printf("PANId : %zu \r\n", PANId);
		printf("Status : %u \r\n", Status);
		printf("parentAddress : %zu \r\n", parentAddress);
		switch(Status)
		{
		case NWK_SUCCESS:
			// Join procedure successful
			joined = 0x01;

			call Leds.led0Off();
			requested_scheduling = 0x01;
			call T_schedule.startOneShot(9000);
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
		return SUCCESS;
	}

	/*************************NLME_SYNC*****************************/
	event error_t NLME_SYNC.indication()
	{
		printf("NLME_SYNC.indication\r\n", "");
	
		// We lost connection with our parent. Automatic rescan is done
		// at the NWK layer

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
		call T_init.startOneShot(5000);
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
		printf("go join as router\r\n", ""); 
		call NLME_JOIN.request(MAC_PANID, TRUE, FALSE, 0, 0, 0, 0, 0);
	}

	/*******************T_schedule**************************/
	event void T_schedule.fired()
	{  
		//event that fires if the negotiation for beacon transmission is unsuccessful 
		//(the device does not receive any negotiation reply)
		if(requested_scheduling == 0x01)
		{
			post start_sending_beacons_request();
		}
	}

#if defined(PLATFORM_TELOSB)
	event void Notify.notify(button_state_t state){
		if (state == BUTTON_PRESSED) {
			printf("Button pressed\r\n", "");
			call Leds.led0On();
			call NLME_RESET.request();
		}
	}
#endif

}