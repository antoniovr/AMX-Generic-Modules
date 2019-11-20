(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/18/2019  AT: 08:45:05        *)
(***********************************************************)

MODULE_NAME='Display_UI'(dev vdvDevice,
			 dev dvTp,
			 
			 integer anBtnPower[],
			 integer anBtnInputHDMI[],
			 integer anBtnInputDVI[],
			 integer anBtnInputUSBC[],
			 integer anBtnInputHDBaseT[],
			 integer anBtnInput[],
			 integer nBtnMute,
			 
			 integer anBtnVol[], // Up, Down, Mute
			 
			 integer anBtnOthers[])

/* DEFINITION:

DEFINE_VARIABLE

    volatile integer anBtnPowerDisplay[] = {000}
    volatile integer anBtnInputHDMIDisplay[] = {000}
    volatile integer anBtnInputDVIDisplay[] = {000}
    volatile integer anBtnInputUSBCDisplay[] = {000}
    volatile integer anBtnInputHDBaseTDisplay[] = {000}
    volatile integer anBtnInputDisplay[] = {000}
    volatile integer nBtnMuteDisplay = 000

    volatile integer anBtnVolDisplay[] = {000,000,000}

    volatile integer anBtnOthersDisplay[] = {000}

DEFINE_MODULE

    'Display_UI' display_UI(vdvDisplay,
			    dvTp,
			    anBtnPowerDisplay,
			    anBtnInputHDMIDisplay,
			    
			    anBtnInputDVIDisplay,
			    anBtnInputUSBCDisplay,
			    anBtnInputHDBaseTDisplay,
			    anBtnInputDisplay,
			    nBtnMuteDisplay,
			    
			    anBtnVolDisplay,
			    
			    anBtnOthersDisplay)

*/

#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_CONSTANT

    // Power
    volatile integer _BTN_ON  = 1
    volatile integer _BTN_OFF = 2
    
    // Vol
    volatile integer _BTN_MUTE = 3

DEFINE_VARIABLE

    volatile integer nInputSelectedHDMI    = 0
    volatile integer nInputSelectedDVI     = 0
    volatile integer nInputSelectedUSBC    = 0
    volatile integer nInputSelectedHDBaseT = 0
    volatile integer nInputSelected        = 0

DEFINE_START

    define_function fnInputFeedback()
    {
	stack_var integer i
	
	if([vdvDevice,POWER_FB])
	{
	    for(i=1;i<=length_array(anBtnInputHDMI);i++)    {[dvTp,anBtnInputHDMI[i]]    = (nInputSelectedHDMI == i)}		
	    for(i=1;i<=length_array(anBtnInputDVI);i++)     {[dvTp,anBtnInputDVI[i]]     = (nInputSelectedDVI == i)}		
	    for(i=1;i<=length_array(anBtnInputUSBC);i++)    {[dvTp,anBtnInputUSBC[i]]    = (nInputSelectedUSBC == i)}		
	    for(i=1;i<=length_array(anBtnInputHDBaseT);i++) {[dvTp,anBtnInputHDBaseT[i]] = (nInputSelectedHDBaseT == i)}		
	    for(i=1;i<=length_array(anBtnInput);i++)        {[dvTp,anBtnInput[i]] 	 = (nInputSelected == i)}
	}
    }
    
    define_function fnMuteFeedback()
    {
	if([vdvDevice,POWER_FB]) {[dvTp,nBtnMute] = [vdvDevice,PIC_MUTE_FB]}
    }
    
    define_function fnPowerFeedback()
    {
	[dvTp,anBtnPower[_BTN_ON]]  = [vdvDevice,POWER_FB]
	[dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
    }
    
    define_function fnVolFeedback()
    {
	[dvTp,anBtnVol[_BTN_MUTE]] = [vdvDevice,VOL_MUTE_FB]
    }

DEFINE_EVENT

    button_event[dvTp,anBtnPower]
    {
	push:
	{	    
	    stack_var integer nPush
	    nPush = get_last(anBtnPower)
	    if(nPush == 1) // Power On
	    {	
		pulse[vdvDevice,PWR_ON]
	    }
	    else // Power Off
	    {
		pulse[vdvDevice,PWR_OFF]
	    }
	}
    }

    button_event[dvTp,nBtnMute]
    {
	push:
	{
	    pulse[vdvDevice,PIC_MUTE]
	}
    }

    button_event[dvTp,anBtnInputHDMI]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputHDMI)
	    send_command vdvDevice,"'INPUT-HDMI,',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputDVI]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputDVI)
	    send_command vdvDevice,"'INPUT-DVI,',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputUSBC]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputUSBC)
	    send_command vdvDevice,"'INPUT-USB-C,',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputHDBaseT]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputHDBaseT)
	    send_command vdvDevice,"'INPUT-HDBaseT,',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInput]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInput)
	    send_command vdvDevice,"'INPUTSELECT-',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnVol]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnVol)
	    switch(nPush)
	    {
		case 1: // Vol +
		{
		    to[dvTp,anBtnVol[nPush]]
		    to[vdvDevice,VOL_UP]
		}
		case 2: // Vol -
		{
		    to[dvTp,anBtnVol[nPush]]
		    to[vdvDevice,VOL_DN]
		}
		case 3: // Vol Mute
		{
		    pulse[vdvDevice,VOL_MUTE]
		}
	    }
	    fnVolFeedback()
	}
    }


    button_event[dvTp,anBtnOthers]
    {
	push:
	{
	}
    }

    channel_event[vdvDevice,POWER_FB]
    {
	on:
	{
	    on[dvTp,anBtnPower[_BTN_ON]]
	    off[dvTp,anBtnPower[_BTN_OFF]]
	    fnInputFeedback()
	}
	off:
	{
	    on[dvTp,anBtnPower[_BTN_OFF]]		
	    off[dvTp,anBtnPower[_BTN_ON]]	
	    fnInputFeedback()
	}
    }

    channel_event[vdvDevice,PIC_MUTE_FB]
    {
	on:
	{
	    fnMuteFeedback()
	}
	off:
	{
	    fnMuteFeedback()
	}
    }


    data_event[vdvDevice]
    {
	command:
	{
	    stack_var char sCmd[DUET_MAX_CMD_LEN]
	    stack_var char sHeader[DUET_MAX_HDR_LEN]
	    stack_var char sParam[DUET_MAX_PARAM_LEN]
	    sCmd = data.text
	    sHeader = DuetParseCmdHeader(sCmd)
	    sParam = DuetParseCmdParam(sCmd)

	    switch(sHeader)
	    {
		case 'INPUTSELECTED':
		{
		    nInputSelected = atoi("sParam")
		    nInputSelectedHDMI = 0
		    nInputSelectedDVI = 0
		    nInputSelectedHDBaseT = 0
		    nInputSelectedUSBC = 0
		    fnInputFeedback()		
		}
		case 'INPUT':
		{
		    stack_var integer nNumber
		    nNumber = atoi(DuetParseCmdParam(sCmd))
		    fnDebug("'Input type: ',sParam,' number: ',itoa(nNumber)")
		    switch(sParam)
		    {
			case 'HDMI':
			{
			    nInputSelectedHDMI = nNumber
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = 0
			    nInputSelected = 0
			}
			case 'DVI':
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = nNumber
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = 0
			    nInputSelected = 0			
			}
			case 'HDBaseT':
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = nNumber
			    nInputSelectedUSBC = 0
			    nInputSelected = 0						
			}
			case 'USB-C':
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = nNumber
			    nInputSelected = 0						
			}			
			
		    }
		    fnInputFeedback()
		}
	    }
	}
    }

    data_event[dvTp]
    {
	online:
	{
	    fnInputFeedback()
	    fnMuteFeedback()
	    fnPowerFeedback()
	    fnVolFeedback()
	}
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 