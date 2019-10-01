(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/26/2019  AT: 09:04:14        *)
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
	    if(bActive) {bSaving = false}
	    nPush = get_last(anBtnPreset)
	    to[dvTp,anBtnPreset[nPush]]
	}
	hold[20]:
	{
	    if(bactive) {bSaving = true}
	}
	release:
	{
	    stack_var integer nPush
	    if(bActive)
	    {
		nPush = get_last(anBtnPreset)
		if(bSaving) {send_command vdvDevice,"'CAMERAPRESETSAVE-',itoa(nPush)"}
		else	    {send_command vdvDevice,"'CAMERAPRESET-',itoa(nPush)"}
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