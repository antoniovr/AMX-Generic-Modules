MODULE_NAME='UI_Projector'(dev vdvDevice,
			   dev dvTp,

			   integer anBtnPower[],
			   integer anBtnInputHDMI[],
			   integer anBtnInputDVI[],
			   integer anBtnInputUSBC[],
			   integer anBtnInputHDBaseT[],
			   integer anBtnInput[],
			   integer nBtnMute,
			    
			   integer nBtnWarming,
			   integer nBtnCooling,
			    
			   integer anBtnOthers[])

#include 'EarAPI.axi'
#include 'SNAPI.axi'

DEFINE_CONSTANT

    volatile integer _BTN_ON  = 1
    volatile integer _BTN_OFF = 2
    
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
	    for(i=1;i<=length_array(anBtnInputHDMI);i++)    {[dvTp,anBtnInputHDMI[i]] = (nInputSelectedHDMI == i)}		
	    for(i=1;i<=length_array(anBtnInputDVI);i++)     {[dvTp,anBtnInputDVI[i]] = (nInputSelectedDVI == i)}		
	    for(i=1;i<=length_array(anBtnInputUSBC);i++)    {[dvTp,anBtnInputUSBC[i]] = (nInputSelectedUSBC == i)}		
	    for(i=1;i<=length_array(anBtnInputHDBaseT);i++) {[dvTp,anBtnInputHDBaseT[i]] = (nInputSelectedHDBaseT == i)}		
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
	    send_command vdvDevice,"'INPUT-',asSources[_SOURCE_HDMI],',',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputDVI]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputDVI)
	    send_command vdvDevice,"'INPUT-',asSources[_SOURCE_DVI],',',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputUSBC]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputUSBC)
	    send_command vdvDevice,"'INPUT-',asSources[_SOURCE_USBC],',',itoa(nPush)"
	}
    }

    button_event[dvTp,anBtnInputHDBaseT]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInputHDBaseT)
	    send_command vdvDevice,"'INPUT-',asSources[_SOURCE_HDBASET],',',itoa(nPush)"
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
	    fnLampFeedback()
	}
	off:
	{
	    fnLampFeedback()
	}
    }

    channel_event[vdvDevice,LAMP_WARMING_FB]
    {
	on:
	{
	    fnLampFeedback()
	}
	off:
	{
	    fnLampFeedback()
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
	string:
	{
	    stack_var char sFeedback[256]
	    sFeedback = data.text
	    select
	    {
		active(find_string(sFeedback,'INPUTSELECTED-',1)):
		{
		    remove_string(sFeedback,'INPUTSELECTED-',1)
		    nInputSelected = atoi("sFeedback")
		    nInputSelectedHDMI = 0
		    nInputSelectedDVI = 0
		    nInputSelectedHDBaseT = 0
		    nInputSelectedUSBC = 0
		    fnInputFeedback()
		}
		active(find_string(sFeedback,'INPUT-',1)):
		{
		    remove_string(sFeedback,'INPUT-',1)
		    select
		    {
			active(find_string(sFeedback,asSources[_SOURCE_HDMI],1)):
			{
			    nInputSelectedHDMI = atoi("sFeedback")
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = 0
			    nInputSelected = 0
			}
			active(find_string(sFeedback,asSources[_SOURCE_DVI],1)):
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = atoi("sFeedback")
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = 0
			    nInputSelected = 0						
			}
			active(find_string(sFeedback,asSources[_SOURCE_HDBaseT],1)):
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = atoi("sFeedback")
			    nInputSelectedUSBC = 0
			    nInputSelected = 0						
			}
			active(find_string(sFeedback,asSources[_SOURCE_USBC],1)):
			{
			    nInputSelectedHDMI = 0
			    nInputSelectedDVI = 0
			    nInputSelectedHDBaseT = 0
			    nInputSelectedUSBC = atoi("sFeedback")
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
	}
    }

(**********************************************************)
(********************   EARPRO 2019   *********************)
(**********************************************************) 