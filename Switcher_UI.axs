(***********************************************************)
(*  FILE CREATED ON: 09/10/2019  AT: 11:29:06              *)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/17/2020  AT: 12:57:13        *)
(***********************************************************)

MODULE_NAME='Switcher_UI' (dev dvTp,
			   dev vdvDevice,
			   integer anBtnInputs[],
			   integer anBtnOutputs[],
			   integer anBtnLevels[])

/*
    Example:
    // Switcher
    volatile integer anBtnInputs[]  = {000,000,000,000}
    volatile integer anBtnOutputs[] = {000,000,000,000}   
    volatile integer anBtnLevels[]  = {000,000,000} 
    
    'Switcher_UI' switcher_UI(dvTp,
			  vdvSwitcher,
			  anBtnInputs,
			  anBtnOutputs,
			  anBtnLevels)
*/


#include 'SNAPI'
#include 'CUSTOMAPI'


DEFINE_CONSTANT

    long _TLID = 1
    long lTimes[] = {200}
    
DEFINE_VARIABLE

    volatile integer nInputSelected = 0
    
    volatile integer anOutputStatus[2][40]
    //volatile integer anOutputStatusAux[2][40]
    
    volatile integer nLevel = _LEVEL_ALL

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
	    select
	    {
		active(nLevel == _LEVEL_ALL):
		{
		    for(i=1;i<=max_length_array(anBtnOutputs);i++)
		    {
			[dvTp,anBtnOutputs[i]] = (anOutputStatus[1][i] == nInputSelected && anOutputStatus[2][i] == nInputSelected)
		    }		
		}
		active(nLevel == _LEVEL_VIDEO):
		{
		    for(i=1;i<=max_length_array(anBtnOutputs);i++)
		    {
			[dvTp,anBtnOutputs[i]] = (anOutputStatus[1][i] == nInputSelected)
		    }
		}
		active(nLevel == _LEVEL_AUDIO):
		{
		    for(i=1;i<=max_length_array(anBtnOutputs);i++)
		    {
			[dvTp,anBtnOutputs[i]] = (anOutputStatus[2][i] == nInputSelected)
		    }
		}
	    }

	}
	
	[dvTp,anBtnLevels[_LEVEL_ALL]] = (nLevel == _LEVEL_ALL)
	[dvTp,anBtnLevels[_LEVEL_VIDEO]] = (nLevel == _LEVEL_VIDEO)
	[dvTp,anBtnLevels[_LEVEL_AUDIO]] = (nLevel == _LEVEL_AUDIO)
    }

DEFINE_EVENT

    button_event[dvTp,anBtnLevels]
    {
	push:
	{
	    stack_var integer nPush
	    nLevel = get_last(anBtnLevels)
	}
    }

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
	    
	    select
	    {
		active(nLevel == _LEVEL_ALL):
		{
		    if(anOutputStatus[1][nPush] != nInputSelected && anOutputStatus[2][nPush] != nInputSelected)
		    {
			send_command vdvDevice,"'CI',itoa(nInputSelected),'O',itoa(nPush)"
		    }
		    else
		    {
			send_command vdvDevice,"'CI0O',itoa(nPush)"	
		    }
		}
		active(nLevel == _LEVEL_VIDEO):
		{
		    if(anOutputStatus[1][nPush] != nInputSelected)
		    {
			send_command vdvDevice,"'VI',itoa(nInputSelected),'O',itoa(nPush)"
		    }
		    else
		    {
			send_command vdvDevice,"'VI0O',itoa(nPush)"	
		    }
		}
		active(nLevel == _LEVEL_AUDIO):
		{
		    if(anOutputStatus[2][nPush] != nInputSelected)
		    {
			send_command vdvDevice,"'AI',itoa(nInputSelected),'O',itoa(nPush)"
		    }
		    else
		    {
			send_command vdvDevice,"'AI0O',itoa(nPush)"
		    }
		}
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
		    select
		    {
			active(find_string(sHeader,'CI',1)):
			{
			    stack_var char sInput[4]
			    stack_var char sOutput[4]
			    stack_var integer nInput
			    stack_var integer nOutput
			    sInput = remove_string(sHeader,'O',1)
			    nInput = atoi(sInput)
			    sOutput = sHeader
			    nOutput = atoi(sOutput)
			    anOutputStatus[1][nOutput] = nInput
			    anOutputStatus[2][nOutput] = nInput
			}
			active(find_string(sHeader,'VI',1)):
			{
			    stack_var char sInput[4]
			    stack_var char sOutput[4]
			    stack_var integer nInput
			    stack_var integer nOutput
			    sInput = remove_string(sHeader,'O',1)
			    nInput = atoi(sInput)
			    sOutput = sHeader
			    nOutput = atoi(sOutput)
			    anOutputStatus[1][nOutput] = nInput
			}
			active(find_string(sHeader,'AI',1)):
			{
			    stack_var char sInput[4]
			    stack_var char sOutput[4]
			    stack_var integer nInput
			    stack_var integer nOutput
			    sInput = remove_string(sHeader,'O',1)
			    nInput = atoi(sInput)
			    sOutput = sHeader
			    nOutput = atoi(sOutput)
			    anOutputStatus[2][nOutput] = nInput
			}			
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