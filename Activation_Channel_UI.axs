(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/24/2019  AT: 09:15:43        *)
(***********************************************************)

MODULE_NAME='Activation_Channel_UI'(dev dvDev,
				    dev dvTp,
				    
				    integer anBtnPulse[],
				    integer anIrPulse[],
				    integer anPulseTimes[],
				    
				    integer anBtnTo[],
				    integer anIrTo[])

(* DEFINITION:

DEFINE_VARIABLE

    volatile integer anBtnPulseArec[]   = {331,332,333,334,335,336,337,338,339,340,341,342,343}
    volatile integer anIrPulseArec[]    = {  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13}
    volatile integer anPulseTimesArec[] = {  3,  3,  3,  3,  3,  3,  1,  3,  3,  3,  3,  3,  3}

    integer anBtnToArec[] = {9999}
    integer anIrToArec[] = {9999}

DEFINE_MODULE

    'Activation_Channel_UI' recorder_UI(dvArec,
					dvTp,
					
					anBtnPulseArec,
					anIrPulseArec,
					anPulseTimesArec,
					
					anBtnToArec,
					anIrToArec)

*)

DEFINE_VARIABLE

    volatile integer bActive = 0

DEFINE_EVENT

    data_event[dvDev]
    {
	online:
	{
	    send_command dvDev,'SET MODE IR'
	    send_command dvDev,'CARON'
	}
    }

    button_event[dvTp,anBtnPulse]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnPulse)
	    pulse[dvTp,anBtnPulse[nPush]]
	    
	    // Set the pulse time if specified
	    if(anPulseTimes[nPush])
	    {
		set_pulse_time(anPulseTimes[nPush])
	    }
	    
	    pulse[dvDev,anIrPulse[nPush]]
	    
	    // Restores the pulse time to the default values (reminder: pulse time affects the entire program)
	    if(anPulseTimes[nPush])
	    {
		set_pulse_time(5)
	    }
	}
    }

    button_event[dvTp,anBtnTo]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnTo)
	    to[dvTp,anBtnTo[nPush]]
	    to[dvDev,anIrTo[nPush]]
	}
    }

(***********************************************************)
(*		    	END OF PROGRAM			   *)
(***********************************************************) 