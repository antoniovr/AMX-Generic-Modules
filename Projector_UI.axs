(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/28/2019  AT: 20:23:13        *)
(***********************************************************)

MODULE_NAME='Projector_UI'(dev vdvDevice,
			   dev dvTp,

			   integer anBtnPower[],
			   integer anBtnInputHDMI[],
			   integer anBtnInputDVI[],
			   integer anBtnInputUSBC[],
			   integer anBtnInputHDBaseT[],
			   integer anBtnInputVideo[],
			   integer anBtnInputSVideo[],
			   integer anBtnInputLetters[],
			   integer anBtnInput[],
			   integer nBtnMute,
			    
			   integer nBtnWarming,
			   integer nBtnCooling,
			    
			   integer anBtnOthers[])

/*
    Example:
    // Projector
    volatile integer anBtnPowerProj[] = {000,000}
    volatile integer anBtnInputHDMIProj[] = {000}
    volatile integer anBtnInputDVIProj[] = {000}
    volatile integer anBtnInputUSBCProj[] = {000}
    volatile integer anBtnInputHDBaseTProj[] = {000}
    volatile integer anBtnInputVideoProj[] = {000}
    volatile integer anBtnInputSVideoProj[] = {000}
    volatile integer anBtnInputLettersProj[] = {000,000,000,000}
    volatile integer anBtnInputProj[] = {000}
    volatile integer nBtnMuteProj = 000

    volatile integer nBtnWarmingProj = 000
    volatile integer nBtnCoolingProj = 000

    volatile integer anBtnOthersProj[] = {000}

    'Projector_UI' proj_UI(vdvProjector,
			   dvTp,
			   anBtnPowerProj,
			   anBtnInputHDMIProj,
			   anBtnInputDVIProj,
			   anBtnInputUSBCProj,
			   anBtnInputHDBaseTProj,
			   anBtnInputVideoProj,
			   anBtnInputSVideoProj,
			   anBtnInputLettersProj,
			   
			   anBtnInputProj,
			   nBtnMuteProj,
			   
			   nBtnWarmingProj,
			   nBtnCoolingProj,
			   
			   anBtnOthersProj)

*/

#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_CONSTANT

    volatile integer _BTN_ON  = 1
    volatile integer _BTN_OFF = 2
    
DEFINE_VARIABLE

    volatile integer nInputSelectedHDMI    = 0
    volatile integer nInputSelectedDVI     = 0
    volatile integer nInputSelectedUSBC    = 0
    volatile integer nInputSelectedHDBaseT = 0
    volatile integer nInputSelectedVideo   = 0
    volatile integer nInputSelectedSVideo  = 0
    volatile integer nInputSelectedLetters = 0
    volatile integer nInputSelected        = 0

DEFINE_START

    define_function fnSelInput(char sType[],integer nNumber)
    {
	send_command vdvDevice,"'INPUT-',sType,',',itoa(nNumber)"
    }

    define_function fnInputFeedback()
    {
	stack_var integer i
	
	if([vdvDevice,POWER_FB])
	{
	    for(i=1;i<=length_array(anBtnInputHDMI);i++)    {[dvTp,anBtnInputHDMI[i]] = (nInputSelectedHDMI == i)}		
	    for(i=1;i<=length_array(anBtnInputDVI);i++)     {[dvTp,anBtnInputDVI[i]] = (nInputSelectedDVI == i)}		
	    for(i=1;i<=length_array(anBtnInputUSBC);i++)    {[dvTp,anBtnInputUSBC[i]] = (nInputSelectedUSBC == i)}		
	    for(i=1;i<=length_array(anBtnInputHDBaseT);i++) {[dvTp,anBtnInputHDBaseT[i]] = (nInputSelectedHDBaseT == i)}	
	    for(i=1;i<=length_array(anBtnInputVideo);i++)   {[dvTp,anBtnInputVideo[i]] = (nInputSelectedVideo == i)}
	    for(i=1;i<=length_array(anBtnInputSVideo);i++)  {[dvTp,anBtnInputSVideo[i]] = (nInputSelectedSVideo == i)}
	    for(i=1;i<=length_array(anBtnInputLetters);i++) {[dvTp,anBtnInputLetters[i]] = (nInputSelectedLetters == i)}
	    for(i=1;i<=length_array(anBtnInput);i++)	    {[dvTp,anBtnInput[i]] = (nInputSelected == i)}
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
	
    define_function fnLampFeedback()
    {
	[dvTp,nBtnWarming] = [vdvDevice,LAMP_WARMING_FB]
	[dvTp,nBtnCooling] = [vdvDevice,LAMP_COOLING_FB]
    }
    
    define_function fnSetAllnInputToZero()
    {
	nInputSelectedHDMI    = 0
	nInputSelectedDVI     = 0
	nInputSelectedHDBaseT = 0
	nInputSelectedUSBC    = 0
	nInputSelectedVideo   = 0
	nInputSelectedSVideo  = 0
	nInputSelectedLetters = 0
	nInputSelected        = 0	
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

    button_event[dvTp,anBtnInputHDMI]{push:{fnSelInput('HDMI',get_last(anBtnInputHDMI))}}
    button_event[dvTp,anBtnInputDVI]{push:{fnSelInput('DVI',get_last(anBtnInputDVI))}}
    button_event[dvTp,anBtnInputUSBC]{push:{fnSelInput('USB-C',get_last(anBtnInputUSBC))}}
    button_event[dvTp,anBtnInputHDBaseT]{push:{fnSelInput('HDBaseT',get_last(anBtnInputHDBaseT))}}
    button_event[dvTp,anBtnInputVideo]{push:{fnSelInput('VIDEO',get_last(anBtnInputVideo))}}
    button_event[dvTp,anBtnInputSVideo]{push:{fnSelInput('SVIDEO',get_last(anBtnInputSVideo))}}
    button_event[dvTp,anBtnInputLetters]
    {
	push:
	{
	    stack_var integer nPush 
	    stack_var char cLetter 
	    nPush = get_last(anBtnInputLetters)
	    switch(nPush)
	    {
		case 1: {cLetter = 'A'}
		case 2: {cLetter = 'B'}
		case 3: {cLetter = 'C'}
		case 4: {cLetter = 'D'}
	    }
	    send_command vdvDevice,"'INPUT-INPUT_',cLetter"
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



    button_event[dvTp,anBtnOthers]
    {
	push:
	{
	}
    }

    channel_event[vdvDevice,LAMP_COOLING_FB]
    {
	on:
	{
	    fnInfo('Cooling ON FB')
	    fnLampFeedback()
	}
	off:
	{
	    fnInfo('Cooling OFF FB')
	    fnLampFeedback()
	}
    }

    channel_event[vdvDevice,LAMP_WARMING_FB]
    {
	on:
	{
	    fnInfo('Warming ON FB')
	    fnLampFeedback()
	}
	off:
	{
	    fnInfo('Warming OFF FB')
	    fnLampFeedback()
	}
    }

    channel_event[vdvDevice,POWER_FB]
    {
	on:
	{
	    fnInfo('Power ON FB UI')
	    on[dvTp,anBtnPower[_BTN_ON]]
	    off[dvTp,anBtnPower[_BTN_OFF]]
	    fnInputFeedback()
	}
	off:
	{
	    fnInfo('Power OFF FB UI)')
	    on[dvTp,anBtnPower[_BTN_OFF]]		
	    off[dvTp,anBtnPower[_BTN_ON]]	
	    fnInputFeedback()
	}
    }

    channel_event[vdvDevice,PIC_MUTE_FB]
    {
	on:
	{
	    fnInfo('Mute ON FB UI')
	    fnMuteFeedback()
	}
	off:
	{
	    fnInfo('Mute OFF FB UI')
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
	    
	    fnDebug("'sHeader: ',sHeader,' | sParam: ',sParam")
	    
	    switch(sHeader)
	    {
		case 'INPUTSELECTED':
		{
		    fnSetAllnInputToZero()
		    nInputSelected = atoi("sParam")
		    fnInputFeedback()		
		}
		case 'INPUT':
		{
		    fnSetAllnInputToZero()
		    switch(sParam)
		    {
			case 'HDMI': {nInputSelectedHDMI = atoi("DuetParseCmdParam(sCmd)")}
			case 'DVI': {nInputSelectedDVI = atoi("DuetParseCmdParam(sCmd)")}
			case 'HDBaseT': {nInputSelectedHDBaseT = atoi("DuetParseCmdParam(sCmd)")}
			case 'USB-C': {nInputSelectedUSBC = atoi("DuetParseCmdParam(sCmd)")}
			case 'VIDEO': {nInputSelectedVideo = atoi("DuetParseCmdParam(sCmd)")}
			case 'SVIDEO': {nInputSelectedHDMI = atoi("DuetParseCmdParam(sCmd)")}
			default:
			{
			    if(find_string(sParam,'INPUT_',1))
			    {
				remove_string(sParam,'INPUT_',1)
				switch(sParam)
				{
				    case 'A': {nInputSelectedLetters = 1}
				    case 'B': {nInputSelectedLetters = 2}
				    case 'C': {nInputSelectedLetters = 3}
				    case 'D': {nInputSelectedLetters = 4}
				}
			    }
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
	}
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 