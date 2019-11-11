(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/24/2019  AT: 09:16:58        *)
(***********************************************************)

MODULE_NAME='Camera_UI'(dev vdvDevice,
			dev dvTp,
			 
			integer anBtnPower[], // On, Off
			integer anBtnPantilt[], // Up, Down, Left, Right, Home
			integer nLevelPantilt, 
			integer anBtnZoom[], // In, Out
			integer nLevelZoom,
			integer anBtnFocus[], // Near, Far
			integer nLevelFocus,
			integer nBtnAutofocus,
			integer anBtnPreset[],
			integer bActive)

(* DEFINITION:
DEFINE_VARIABLE

    volatile integer anBtnCamPower[] = {101,102} // On, Off
    volatile integer anBtnCamPantilt[] = {103,104,105,106,107} // Up, Down, Left, Right, Home
    volatile integer nLevelCamPantilt = 101 
    volatile integer anBtnCamZoom[] = {108,109} // In, Out
    volatile integer nLevelCamZoom = 102
    volatile integer anBtnCamFocus[] = {110,111} // Near, Far
    volatile integer nLevelCamFocus = 103
    volatile integer nBtnCamAutoFocus = 112
    volatile integer anBtnCamPreset[] = {113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130}

DEFINE_MODULE

    'Camera_UI' cam1(avdvCams[_CAM_1],
		     dvTp,
		     anBtnCamPower, // On, Off
		     anBtnCamPantilt, // Up, Down, Left, Right, Home
		     nLevelCamPantilt, 
		     anBtnCamZoom, // In, Out
		     nLevelCamZoom,
		     anBtnCamFocus, // Near, Far
		     nLevelCamFocus,
		     nBtnCamAutofocus,
		     anBtnCamPreset,
		     abCamActivates[_CAM_1])

*)

#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_CONSTANT

    integer _BTN_ON  = 1
    integer _BTN_OFF = 2
    
    integer _TLID = 1
    long lTimes[] = {200} // Update feedback every .20 sec

DEFINE_VARIABLE

    volatile integer bSaving = false
    
    volatile integer bActiveAux = false

DEFINE_START
    
    timeline_create(_TLID,lTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
    
    define_function fnPowerFeedback()
    {
	[dvTp,anBtnPower[_BTN_ON]]  = [vdvDevice,POWER_FB]
	[dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
    }
    
    define_function fnFeedback()
    {
	if(bActive)
	{
	    [dvTp,anBtnPower[_BTN_ON]] = [vdvDevice,POWER_FB]
	    [dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
	    [dvTp,nBtnAutofocus] = [vdvDevice,AUTO_FOCUS_FB]
	}
    }

DEFINE_EVENT

    button_event[dvTp,anBtnPower]
    {
	push:
	{	    
	    stack_var integer nPush
	    if(bactive)
	    {
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
    }

    button_event[dvTp,anBtnPanTilt]
    {
	push:
	{
	    stack_var integer nPush
	    if(bActive)
	    {
		nPush = get_last(anBtnPanTilt)
		to[dvTp,anBtnPanTilt[nPush]]
		switch(nPush)
		{
		    case 1: {pulse[vdvDevice,TILT_UP]}
		    case 2: {pulse[vdvDevice,TILT_DN]}
		    case 3: {pulse[vdvDevice,PAN_LT]}
		    case 4: {pulse[vdvDevice,PAN_RT]}
		    case 5: {pulse[vdvDevice,_CAM_HOME]}
		}
	    }
	}
	release:
	{
	    if(bactive)
	    {
		pulse[vdvDevice,_PANTILT_STOP]
	    }
	}
    }

    button_event[dvTp,anBtnZoom]
    {
	push:
	{
	    stack_var integer nPush
	    if(bActive)
	    {
		nPush = get_last(anBtnZoom)
		to[dvTp,anBtnZoom[nPush]]
		if(nPush == 1) // Zoom In
		{
		    to[vdvDevice,ZOOM_IN]
		}
		else if(nPush == 2) // Zoom Out
		{
		    to[vdvDevice,ZOOM_OUT]
		}
	    }
	}
    }
    
    button_event[dvTp,anBtnFocus]
    {
	push:
	{
	    stack_var integer nPush
	    if(bActive)
	    {
		nPush = get_last(anBtnFocus)
		to[dvTp,anBtnFocus[nPush]]
		if(nPush == 1) // Focus Near
		{
		    to[vdvDevice,FOCUS_NEAR]
		}
		else if(nPush == 2) // Focus Far
		{
		    to[vdvDevice,FOCUS_FAR]
		}
	    }
	}
    }
    
    button_event[dvTp,nBtnAutofocus]
    {
	push:
	{
	    if(bactive)
	    {
		[vdvDevice,AUTO_FOCUS] = ![vdvDevice,AUTO_FOCUS]
	    }
	}
    }
    
    button_event[dvTp,anBtnPreset]    
    {
	push:
	{
	    stack_var integer nPush
	    if(bActive) 
	    {
		bSaving = false
		nPush = get_last(anBtnPreset)
		to[dvTp,anBtnPreset[nPush]]
		wait 20 'saving_preset'
		{
		    fnBeep(dvTp)
		    bSaving = true
		}
	    }
	    
	}
	release:
	{
	    stack_var integer nPush
	    if(bActive)
	    {
		nPush = get_last(anBtnPreset)
		cancel_wait 'saving_preset'
		if(bSaving) {send_command vdvDevice,"'CAMERAPRESETSAVE-',itoa(nPush)"}
		else	    {send_command vdvDevice,"'CAMERAPRESET-',itoa(nPush)"}
		bSaving = false
	    }
	}
    }

    channel_event[vdvDevice,AUTO_FOCUS_FB]
    {
	on:
	{
	    if(bActive) {[dvTp,nBtnAutofocus] = [vdvDevice,AUTO_FOCUS_FB]}
	}
	off:
	{
	    if(bActive) {[dvTp,nBtnAutofocus] = [vdvDevice,AUTO_FOCUS_FB]}
	}
    }

    channel_event[vdvDevice,POWER_FB]
    {
	on:
	{
	    if(bActive)
	    {
		on[dvTp,anBtnPower[_BTN_ON]]
		off[dvTp,anBtnPower[_BTN_OFF]]
	    }
	}
	off:
	{
	    if(bactive)
	    {
		on[dvTp,anBtnPower[_BTN_OFF]]		
		off[dvTp,anBtnPower[_BTN_ON]]	
	    }
	}
    }

    level_event[dvTp,nLevelPanTilt]
    {
	send_level vdvDevice,PAN_SPEED_LVL,level.value
	send_level vdvDevice,TILT_SPEED_LVL,level.value
    }

    level_event[dvTp,nLevelZoom]
    {
	send_level vdvDevice,ZOOM_SPEED_LVL,level.value
    }
    
    level_event[dvTp,nLevelFocus]
    {
	send_level vdvDevice,FOCUS_SPEED_LVL,level.value
    }

    data_event[vdvDevice]
    {
	command:
	{
	    stack_var char sFeedback[256]
	    sFeedback = data.text
	    select
	    {
		active(find_string(sFeedback,'INPUTSELECTED-',1)):
		{
		    remove_string(sFeedback,'INPUTSELECTED-',1)
		}
	    }
	}
    }

    data_event[dvTp]
    {
	online:
	{
	    if(bactive)
	    {
		fnPowerFeedback()
	    }
	}
    }
    
    timeline_event[_TLID]
    {
	fnFeedback()
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 