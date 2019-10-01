(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/25/2019  AT: 10:04:19        *)
(***********************************************************)

MODULE_NAME='Videoconference_UI'(dev vdvDevice,
				 dev dvTp,
				    
				 integer anBtnPower[],
				 integer anBtnMenu[], // Menu, Up, Down, Left, Right, Select, Back
				 integer anBtnCall[], // Accept, Reject
				 integer anBtnKeypad[], // 0,1,2,3,4,5,6,7,8,9,*,.,#
				 integer anBtnVol[], // Up, Down, Mute
				 integer anBtnSend[] // Input, Graphics
				 )

#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_CONSTANT

    // anBtnPower
    integer _BTN_ON  = 1
    integer _BTN_OFF = 2
    
    // anBtnMenu
    integer _BTN_MENU = 1
    integer _BTN_UP = 2
    integer _BTN_DOWN = 3
    integer _BTN_LEFT = 4
    integer _BTN_RIGHT = 5
    integer _BTN_SELECT = 6
    integer _BTN_BACK = 7
    
    // anBtnVol
    integer _BTN_MUTE = 3
    

DEFINE_VARIABLE

    volatile integer nInputSelectedHDMI    = 0
    volatile integer nInputSelectedDVI     = 0
    volatile integer nInputSelectedUSBC    = 0
    volatile integer nInputSelectedHDBaseT = 0
    volatile integer nInputSelected        = 0

DEFINE_START
    
    define_function fnFeedback()
    {
	[dvTp,anBtnVol[_BTN_MUTE]] = [vdvDevice,VOL_MUTE_FB]
	//[dvTp,anBtnPower[_BTN_ON]]  = [vdvDevice,POWER_FB]
	//[dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
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
    
    // Menu, Up, Down, Left, Right, Select, Back
    button_event[dvTp,anBtnMenu] 
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnMenu)
	    to[dvTp,anBtnMenu[nPush]]
	    switch(nPush)
	    {
		case _BTN_MENU: {pulse[vdvDevice,MENU_FUNC]}
		case _BTN_UP: {pulse[vdvDevice,MENU_UP]}
		case _BTN_DOWN: {pulse[vdvDevice,MENU_DN]}
		case _BTN_LEFT: {pulse[vdvDevice,MENU_LT]}
		case _BTN_RIGHT: {pulse[vdvDevice,MENU_RT]}
		case _BTN_SELECT: {pulse[vdvDevice,MENU_SELECT]}
		case _BTN_BACK: {pulse[vdvDevice,MENU_BACK]}
	    }
	}
    }
    
    // Accept, Reject
    button_event[dvTp,anBtnCall]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnCall)
	    pulse[dvTp,anBtnCall[nPush]]
	    if(nPush == 1) // Accept
	    {
		pulse[vdvDevice,MENU_ACCEPT]
	    }
	    else // Reject
	    {
		pulse[vdvDevice,MENU_REJECT]
	    }
	}
    }

    // 0,1,2,3,4,5,6,7,8,9,*,.,#
    button_event[dvTp,anBtnKeypad] 
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnKeypad)
	    to[dvTp,anBtnKeypad[nPush]]
	    switch(nPush)
	    {
		case 1:  {pulse[vdvDevice,DIGIT_0]}
		case 2:  {pulse[vdvDevice,DIGIT_1]}
		case 3:  {pulse[vdvDevice,DIGIT_2]}
		case 4:  {pulse[vdvDevice,DIGIT_3]}
		case 5:  {pulse[vdvDevice,DIGIT_4]}
		case 6:  {pulse[vdvDevice,DIGIT_5]}
		case 7:  {pulse[vdvDevice,DIGIT_6]}
		case 8:  {pulse[vdvDevice,DIGIT_7]}
		case 9:  {pulse[vdvDevice,DIGIT_8]}
		case 10: {pulse[vdvDevice,DIGIT_9]}
		case 11: {pulse[vdvDevice,MENU_ASTERISK]}
		case 12: {pulse[vdvDevice,MENU_DOT]}
		case 13: {pulse[vdvDevice,MENU_POUND]}
	    }
	}
    }
    
    // Up, Down, Mute
    button_event[dvTp,anBtnVol]
    {
	push:
	{
	    stack_var integer nPush 
	    nPush = get_last(anBtnVol)
	    to[dvTp,anBtnVol[nPush]]
	    switch(nPush)
	    {
		case 1: // Vol Up
		{
		    to[vdvDevice,VOL_UP]
		}
		case 2: // Vol Down
		{
		    to[vdvDevice,VOL_DN]
		}
		case 3: // Vol Mute
		{
		    pulse[vdvDevice,VOL_MUTE]
		}
	    }
	}
    }
    
    
    // Input, Graphics    
    button_event[dvTp,anBtnSend] 
    {
	push:
	{
	    stack_var integer nPush 
	    nPush = get_last(anBtnSend)
	    pulse[dvTp,anBtnSend[nPush]]
	    if(nPush == 1) // Input
	    {
		pulse[vdvDevice,MENU_SEND_INPUT]
	    }
	    else // Graphics
	    {
		pulse[vdvDevice,MENU_SEND_GRAPHICS]
	    }
	}
    }

    channel_event[vdvDevice,POWER_FB]
    {
	on:
	{
	    on[dvTp,anBtnPower[_BTN_ON]]
	    off[dvTp,anBtnPower[_BTN_OFF]]
	}
	off:
	{
	    on[dvTp,anBtnPower[_BTN_OFF]]		
	    off[dvTp,anBtnPower[_BTN_ON]]	
	}
    }
    
    channel_event[vdvDevice,VOL_MUTE_FB]
    {
	on:
	{
	    on[dvTp,anBtnVol[_BTN_MUTE]]
	}
	off:
	{
	    off[dvTp,anBtnVol[_BTN_MUTE]]
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
		case 'INPUT':
		{
		    stack_var integer nNumber
		    nNumber = atoi(DuetParseCmdParam(sCmd))
		    fnInfo("'Input type: ',sParam,' number: ',itoa(nNumber)")
		}
	    }
	}
    }

    data_event[dvTp]
    {
	online:
	{
	    fnFeedback()
	}
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 