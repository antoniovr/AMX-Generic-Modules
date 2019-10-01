(***********************************************************)
(*  FILE CREATED ON: 09/10/2019  AT: 11:29:06              *)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/28/2019  AT: 20:27:15        *)
(***********************************************************)

MODULE_NAME='Switcher_UI' (dev dvTp,
			   dev vdvDevice,
			   integer anBtnInputs[],
			   integer anBtnOutputs[])

/*
    Example:
    // Switcher
    volatile integer anBtnInputs[]  = {000,000,000,000}
    volatile integer anBtnOutputs[] = {000,000,000,000}   
    
    'Switcher_UI' switcher_UI(dvTp,
			  vdvSwitcher,
			  anBtnInputs,
			  anBtnOutputs)
*/


#include 'SNAPI'
#include 'CUSTOMAPI'


DEFINE_CONSTANT

    long _TLID = 1
    long lTimes[] = {200}
    
DEFINE_VARIABLE

    volatile integer nInputSelected = 0
    
    volatile integer anOutputStatus[40]
    volatile integer anOutputStatusAux[40]

DEFINE_START

    timeline_create(_TLID,lTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
    
    define_function fnFeedback()
    {
	stack_var integer i
	for(i=1;i<=max_length_array(anBtnInputs);i++)
	{
	    [dvTp,anBtnInputs[i]] = (nInputSelected == i)
	}
	
	if(nInputSelected)
	{
	    for(i=1;i<=max_length_array(anBtnOutputs);i++)
	    {
		[dvTp,anBtnOutputs[i]] = (anOutputStatus[i] == nInputSelected)
	    }
	}
    }

DEFINE_EVENT

    button_event[dvTp,anBtnInputs]
    {
	push:
	{
	    nInputSelected = get_last(anBtnInputs)	    
	}
    }
    
    button_event[dvTp,anBtnOutputs]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnOutputs)
	    if(anOutputStatus[nPush] != nInputSelected)
	    {
		send_command vdvDevice,"'CI',itoa(nInputSelected),'O',itoa(nPush)"
	    }
	    else
	    {
		//send_command vdvDevice,"'CI0O',itoa(nPush)"
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
		default:
		{
		    if(find_string(sHeader,'CI',1))
		    {
			stack_var char sInput[4]
			stack_var char sOutput[4]
			stack_var integer nInput
			stack_var integer nOutput
			sInput = remove_string(sHeader,'O',1)
			nInput = atoi(sInput)
			sOutput = sHeader
			nOutput = atoi(sOutput)
			anOutputStatus[nOutput] = nInput
		    }	  
		}
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