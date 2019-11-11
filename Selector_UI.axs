(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/28/2019  AT: 13:33:55        *)
(***********************************************************)

MODULE_NAME='Selector_UI'(dev vdvDevice,
			  dev dvTp,
			 
			  integer anBtnInput[],
			  integer nInputSelected) 

#include 'CUSTOMAPI'
#include 'SNAPI'

DEFINE_START

    define_function fnFeedback()
    {
	stack_var integer i
	for(i=1;i<=max_length_array(anBtnInput);i++)
	{
	    [dvTp,anBtnInput[i]] = (nInputSelected == i)
	}
    }

DEFINE_EVENT

    button_event[dvTp,anBtnInput]
    {
	push:
	{
	    stack_var integer nPush
	    nPush = get_last(anBtnInput)
	    send_command vdvDevice,"'INPUT-HDMI,',itoa(nPush)"
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
		    nInputSelected = nNumber
		    fnFeedback()
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