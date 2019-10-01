(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/28/2019  AT: 20:24:53        *)
(***********************************************************)

MODULE_NAME='Player_UI'(dev vdvDevice,
			 dev dvTp,
			 
			 integer anBtnPower[], // On, Off
			 integer anBtnTransport[], // Play, Pause, Stop, Next, Previous, Search fwd, Search prev
			 integer anBtnMenu[]) // Setup, Return, Up, Down, Left, Right, Select

/*
    Example:
    // Device
    volatile integer anBtnPower[] = {000,000} // On, Off
    volatile integer anBtnTransport[] = {000,000,000,000,000,000,000} // Play, Pause, Stop, Next, Previous, Search fwd, Search prev
    volatile integer anBtnMenu[] = {000,000,000,000,000,000,000} // Setup, Return, Up, Down, Left, Right, Select    
    
    'Player_UI' device_UI(vdvDevice,
			  dvTp,
			  anBtnPower, // On, Off
			  anBtnTransport, // Play, Pause, Stop, Next, Previous, Search fwd, Search prev
			  anBtnMenu) // Setup, Return, Up, Down, Left, Right, Select
*/


#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_CONSTANT

    integer _BTN_ON  = 1
    integer _BTN_OFF = 2
    
    integer _BTN_PLAY  = 1
    integer _BTN_PAUSE = 2
    integer _BTN_STOP  = 3
    integer _BTN_FFWD  = 4
    integer _BTN_REW   = 5
    integer _BTN_SFWD  = 6
    integer _BTN_SREV  = 7
    
    integer _BTN_SETUP  = 1
    integer _BTN_RETURN = 2
    integer _BTN_UP     = 3
    integer _BTN_DOWN   = 4
    integer _BTN_LEFT   = 5
    integer _BTN_RIGHT  = 6
    integer _BTN_SELECT = 7

DEFINE_START

    define_function fnUpdateChannelFeedback(integer nChannel)
    {
	switch(nChannel)
	{
	    case POWER_FB: 
	    {
		[dvTp,anBtnPower[_BTN_ON]] = [vdvDevice,POWER_FB]
		[dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
	    }
	    case PLAY_FB:  {[dvTp,anBtnTransport[_BTN_PLAY]]  = [vdvDevice,PLAY_FB]}
	    case PAUSE_FB: {[dvTp,anBtnTransport[_BTN_PAUSE]] = [vdvDevice,PAUSE_FB]}
	    case STOP_FB:  {[dvTp,anBtnTransport[_BTN_STOP]]  = [vdvDevice,STOP_FB]}
	    case SFWD_FB:  {[dvTp,anBtnTransport[_BTN_SFWD]]  = [vdvDevice,SFWD_FB]}
	    case SREV_FB:  {[dvTp,anBtnTransport[_BTN_SREV]]  = [vdvDevice,SREV_FB]}
	}
    }
    
    define_function fnUpdateAllFeedback()
    {
	[dvTp,anBtnPower[_BTN_ON]] = [vdvDevice,POWER_FB]
	[dvTp,anBtnPower[_BTN_OFF]] = ![vdvDevice,POWER_FB]
	
	[dvTp,anBtnTransport[_BTN_PLAY]]  = [vdvDevice,PLAY_FB]
	[dvTp,anBtnTransport[_BTN_PAUSE]] = [vdvDevice,PAUSE_FB]
	[dvTp,anBtnTransport[_BTN_STOP]]  = [vdvDevice,STOP_FB]
	[dvTp,anBtnTransport[_BTN_SFWD]]  = [vdvDevice,SFWD_FB]
	[dvTp,anBtnTransport[_BTN_SREV]]  = [vdvDevice,SREV_FB]
	
    }

DEFINE_EVENT

    button_event[dvTp,anBtnTransport]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnTransport)
	    switch(nPush)
	    {
		case _BTN_PLAY: {pulse[vdvDevice,PLAY]}
		case _BTN_PAUSE: {pulse[vdvDevice,PAUSE]}
		case _BTN_STOP: {pulse[vdvDevice,STOP]}
		case _BTN_FFWD: 
		{
		    pulse[button.input.device,button.input.channel]
		    pulse[vdvDevice,FFWD]
		}
		case _BTN_REW: 
		{
		    pulse[button.input.device,button.input.channel]
		    pulse[vdvDevice,REW]
		}
		case _BTN_SFWD: {pulse[vdvDevice,SFWD]}
		case _BTN_SREV: {pulse[vdvDevice,SREV]}
	    }
	}
    }

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
    
    button_event[dvTp,anBtnMenu]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnMenu)
	    pulse[dvTp,anBtnMenu[nPush]]
	    switch(nPush)
	    {
		case _BTN_SETUP: {pulse[vdvDevice,MENU_SETUP]}
		case _BTN_RETURN: {pulse[vdvDevice,MENU_RETURN]}
		case _BTN_UP:     {pulse[vdvDevice,MENU_UP]}
		case _BTN_DOWN:   {pulse[vdvDevice,MENU_DN]}
		case _BTN_LEFT:   {pulse[vdvDevice,MENU_LT]}
		case _BTN_RIGHT:  {pulse[vdvDevice,MENU_RT]}
		case _BTN_SELECT: {pulse[vdvDevice,MENU_SELECT]}
	    }
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
    
    channel_event[vdvDevice,0]
    {
	on:
	{
	    fnUpdateChannelFeedback(channel.channel)
	}
	off:
	{
	    fnUpdateChannelFeedback(channel.channel)
	}
    }

    data_event[dvTp]
    {
	online:
	{
	    fnUpdateAllFeedback()
	}
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 