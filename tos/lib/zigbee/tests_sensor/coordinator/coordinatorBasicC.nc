/* PAN COORDINATOR NODE
 * @author Stefano Tennina <sota@isep.ipp.pt>
 * 
 */

#include <Timer.h>
#include "printfUART.h"
#include "log_enable.h"
#include <stdio.h>
#include <stdint.h>

module coordinatorBasicC 
{
  uses {
	interface Boot;
//	interface Leds;
	interface NLDE_DATA;
	//NLME NWK Management services
	interface NLME_NETWORK_FORMATION;	
	interface NLME_JOIN;
	interface NLME_LEAVE;
	interface NLME_SYNC;
	interface NLME_RESET;
	interface NLME_GET;
	interface NLME_SET;
	//Timers
	interface Timer<TMilli> as T_init;

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
	uint8_t networkStarted;
	// This function initializes the variables.
	void initVariables()
	{
		// Depth by configuration (initialize to default)
		atomic	networkStarted = 0;

		//atomic => Objects of atomic types are the only objects that are free from data races, that is, 
		//they may be modified by two threads concurrently or modified by one and read by another.
	}

	event void Boot.booted() 
	{
		initVariables();

	#if defined(PLATFORM_TELOSB)
		// TelosB: we can use the button to start
		call Notify.enable();  
	#else
		// In case of MicaZ, start immediately
		call NLME_RESET.request();
	#endif
	}


	//function used to schedule the beacon requests (PAN coordinator)
	void process_beacon_scheduling(uint16_t source_address, uint8_t beacon_order, uint8_t superframe_order)
	{
		//Sample data for router
			//source_address = 1, beacon_order = 8, superframe_order = 4 //from MACprofile.h

		uint8_t nsdu_pay[6];
		beacon_scheduling *beacon_scheduling_ptr = (beacon_scheduling *)(&nsdu_pay[0]);

		beacon_scheduling_ptr->beacon_order = beacon_order;
		beacon_scheduling_ptr->superframe_order = superframe_order;

		//TDBS Reference Paper -> https://link.springer.com/article/10.1007%2Fs11241-008-9063-4

		switch(source_address)
		{
			/*****************************************************************************/
			/*
			 * NORMAL TEST
				mwkMaxChildren (Cm)	6
				nwkMaxDepth (Lm)	3
				mwkMaxRouters (Rm)	4
			*/
		case 0x0001: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0020: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x01;
			beacon_scheduling_ptr->transmission_offset[1] = 0xE0;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0002: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0009: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0xF0;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0021: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0028: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0xF0;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0003: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0004: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x78;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x000a: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x000b: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x78;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0022: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0023: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x78;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x0029: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x3C;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		case 0x002a: 
			beacon_scheduling_ptr->request_type = SCHEDULING_ACCEPT;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x78;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;

		default: 
			beacon_scheduling_ptr->request_type = SCHEDULING_DENY;
			beacon_scheduling_ptr->transmission_offset[0] = 0x00;
			beacon_scheduling_ptr->transmission_offset[1] = 0x00;
			beacon_scheduling_ptr->transmission_offset[2] = 0x00;
			break;
		}
		
		printf("Coordinator: Sending negotiation reply\r\n", "");
		call NLDE_DATA.request(source_address, 0x06, nsdu_pay, 0, 1, 0x00, 0);
	}


	/*****************************************************
	****************NLDE EVENTS***************************
	******************************************************/

	/*************************NLDE_DATA*****************************/

	event error_t NLDE_DATA.confirm(uint8_t NsduHandle, uint8_t Status)
	{
		printf("NLDE_DATA.confirm\r\n", "");
		return SUCCESS;
	}

	event error_t NLDE_DATA.indication(uint16_t SrcAddress, uint8_t NsduLength, uint8_t Nsdu[120], uint16_t LinkQuality)
	{
		uint8_t packetCode = Nsdu[0];
		int i;
		// TDBS (Time Division Beacon Scheduling) mechanism
		beacon_scheduling *beacon_scheduling_ptr;
				
		printf("NLDE_DATA.indication\r\n", "");
		printf("packetCode %d\r\n", packetCode);
		printf("SrcAddress %d\r\n", SrcAddress);
		printf("NsduLength %d\r\n", NsduLength);
		printf("LinkQuality %d\r\n", LinkQuality);
		for(i=0; i < NsduLength; i++){
			printf("Nsdu i = %d val = %d\r\n", i, Nsdu[i]);
		}
		
		// The packet is for me (check has been done into MCPS_DATA.indication) /tos/lib/mac/tkn154/interfaces/MCPS/MCPS_DATA.nc

		// TDBS (Time Division Beacon Scheduling) mechanism
		if (packetCode == SCHEDULING_REQUEST) {
			beacon_scheduling_ptr = (beacon_scheduling *)Nsdu;

			// PAN coordinator receiving a negotiation request
			process_beacon_scheduling (SrcAddress, beacon_scheduling_ptr->beacon_order, beacon_scheduling_ptr->superframe_order);
		}
		
		// No other data is expected
   
		return SUCCESS;
	}


	/*****************************************************
	****************NLME EVENTS***************************
	******************************************************/ 

	/*****************NLME_NETWORK_FORMATION**********************/

	event error_t NLME_NETWORK_FORMATION.confirm(uint8_t Status)
	{	
		printf("NLME_NETWORK_FORMATION.confirm\r\n", ""); 
		networkStarted = 1;
		// The Coordinator is transmitting its own beacons
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
		return SUCCESS;
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
		// by the NWK

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
		return SUCCESS;
	}

	/*****************        NLME-GET     ********************/
	event error_t NLME_GET.confirm(uint8_t Status, uint8_t NIBAttribute, uint16_t NIBAttributeLength, uint16_t NIBAttributeValue)
	{
		return SUCCESS;
	}

	event error_t NLME_RESET.confirm(uint8_t status)
	{
		printf("NLME_RESET.confirm\r\n", "");
		printf("Status : %u \r\n", status);
		call T_init.startOneShot(5000);
		return SUCCESS;
	}

	/*******************T_init**************************/
	event void T_init.fired() 
	{
		printf("I'm THE coordinator\r\n", "");
		call NLME_NETWORK_FORMATION.request(LOGICAL_CHANNEL, 8, BEACON_ORDER, SUPERFRAME_ORDER, MAC_PANID, 0);
		return;
	}

#if defined(PLATFORM_TELOSB)
	event void Notify.notify(button_state_t state)
	{
		if (state == BUTTON_PRESSED && networkStarted == 0) 
		{
			printf("Button pressed\r\n", "");
			call NLME_RESET.request();
		}
	}
#endif
  
}

