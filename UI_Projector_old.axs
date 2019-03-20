MODULE_NAME='UI_Projector'(dev vdvDevice,
									dev dvTp,
									integer anBtnGenerals[],
									integer anBtnStatus[],
									integer anBtnInputs[],
									integer anBtnOthers[])

(*Example of how to add this module*)

(*
(*UI Proyector*)
DEFINE_VARIABLE

volatile integer anBtnGeneralsProy[] = {401, // ON
													 402, // OFF
													 403} // MUTE

volatile integer anBtnStatusProy[] = {406, // BUSY
												  407, // COOLING
												  408} // WARMING
											 
volatile integer anBtnInputsProy[] = {404,405}
volatile integer anBtnOthersProy[] = {5001}



define_module 'UI_Proyector' uiProy(vdvProyector,
												dvTp,
												anBtnGeneralsProy,
												anBtnStatusProy,
												anBtnInputsProy,
												anBtnOthersProy)
*)

DEFINE_CONSTANT

_BTN_GRAL_ON   = 1
_BTN_GRAL_OFF  = 2
_BTN_GRAL_MUTE = 3

_BTN_STATUS_BUSY    = 1
_BTN_STATUS_COOLING = 2
_BTN_STATUS_WARMING = 3

DEFINE_VARIABLE

#include 'CTDefs.axi'

DEFINE_START

	define_function fnInputFeedback()
	{
		stack_var integer i
		for(i=1;i<=length_array(anBtnInputs);i++)
		{
			[dvTP,anBtnInputs[i]] = ([vdvDevice,i+_CT_CH_INPUT0-1] && [vdvDevice,_CT_CH_ON])	
		}
	}

DEFINE_EVENT

button_event[dvTp,anBtnGenerals]
{
   push:
   {
      stack_var integer nPush
      
         if(![vdvDevice,_CT_CH_BUSY])
         {
            nPush = get_last(anBtnGenerals)
            switch(nPush)
            {
               case _BTN_GRAL_ON:
               {
						if(![vdvDevice,_CT_CH_BUSY] && ![vdvDevice,_CT_CH_OFF_DISABLED] && ![vdvDevice,_CT_CH_COOLING])
						{
							if([vdvDevice,_CT_CH_DEBUG])
							{
								send_string 0,'UI PROYECTOR: POWER ON'
							}
							send_command vdvDevice,"_CT_CMD_POWER,1"
						}
               }
               case _BTN_GRAL_OFF:
               {
						if(![vdvDevice,_CT_CH_BUSY] && ![vdvDevice,_CT_CH_OFF_DISABLED] && ![vdvDevice,_CT_CH_COOLING])
						{
							if([vdvDevice,_CT_CH_DEBUG])
							{
								send_string 0,'UI PROYECTOR: POWER OFF'
							}
							send_command vdvDevice,"_CT_CMD_POWER,0"
						}
               }
               case _BTN_GRAL_MUTE:
               {
						if(![vdvDevice,_CT_CH_BUSY] && ![vdvDevice,_CT_CH_OFF_DISABLED] && ![vdvDevice,_CT_CH_COOLING])
						{
							if([vdvDevice,_CT_CH_DEBUG])
							{
								send_string 0,"'UI PROYECTOR: MUTE ',itoa(![vdvDevice,_CT_CH_VIDEO_MUTED])"
							}
							send_command vdvDevice,"_CT_CMD_VIDEO_MUTE,![vdvDevice,_CT_CH_VIDEO_MUTED]"
						}
               }
            }
         }
         else
         {
            send_command dvTp,'DBEEP'
         }
   }
}

button_event[dvTP,anBtnInputs]
{
   push:
   {
      stack_var integer nPush
      
		if(![vdvDevice,_CT_CH_BUSY] && ![vdvDevice,_CT_CH_OFF_DISABLED] && ![vdvDevice,_CT_CH_COOLING])
		{
			nPush = get_last(anBtnInputs)
			if([vdvDevice,_CT_CH_DEBUG])
			{
				send_string 0,"'UI PROYECTOR: INPUT ',itoa(nPush-1)"
			}
			send_command vdvDevice,"_CT_CMD_INPUT,nPush"
		}
		else
		{
			send_command dvTp,'DBEEP'
		}
   }
}

button_event[dvTp,anBtnOthers]
{
   push:
   {
      stack_var integer nPush
      
		if(![vdvDevice,_CT_CH_BUSY])
		{
			nPush = get_last(anBtnOthers)
			send_command vdvDevice,"_CT_CMD_REMOTE,nPush"
		}
		else
		{
			send_command dvTp,'DBEEP'
		}	
		to[dvTp,anBtnOthers[nPush]]
   }
}


channel_event[vdvDevice,_CT_CH_ON]
{
	on:
	{
		on[dvTp,anBtnGenerals[_BTN_GRAL_ON]]
		off[dvTp,anBtnGenerals[_BTN_GRAL_OFF]]
		fnInputFeedback()
	}
	off:
	{
		on[dvTp,anBtnGenerals[_BTN_GRAL_OFF]]		
		off[dvTp,anBtnGenerals[_BTN_GRAL_ON]]	
		fnInputFeedback()
	}
}

channel_event[vdvDevice,_CT_CH_VIDEO_MUTED]
{
	on:
	{
		on[dvTp,anBtnGenerals[_BTN_GRAL_MUTE]]
	}
	off:
	{
		off[dvTp,anBtnGenerals[_BTN_GRAL_MUTE]]
	}
}

channel_event[vdvDevice,_CT_CH_BUSY]
{
	on:
	{
		on[dvTp,anBtnStatus[_BTN_STATUS_BUSY]]
	}
	off:
	{
		off[dvTp,anBtnStatus[_BTN_STATUS_BUSY]]
	}
}

channel_event[vdvDevice,_CT_CH_COOLING]
{
	on:
	{
		on[dvTp,anBtnStatus[_BTN_STATUS_COOLING]]
	}
	off:
	{
		off[dvTp,anBtnStatus[_BTN_STATUS_COOLING]]
	}
}

channel_event[vdvDevice,_CT_CH_WARMING]
{
	on:
	{
		on[dvTp,anBtnStatus[_BTN_STATUS_WARMING]]
	}
	off:
	{
		off[dvTp,anBtnStatus[_BTN_STATUS_WARMING]]
		fnInputFeedback()
	}
}

channel_event[vdvDevice,_CT_CH_INPUTS]
{
	on:
	{
		fnInputFeedback()
	}
}

data_event[dvTp]
{
	online:
	{
		fnInputFeedback()
		
		[dvTp,anBtnGenerals[_BTN_GRAL_ON]] 	 	 = [vdvDevice,_CT_CH_ON]
		[dvTp,anBtnGenerals[_BTN_GRAL_OFF]]  	 = ![vdvDevice,_CT_CH_ON]
		[dvTp,anBtnGenerals[_BTN_GRAL_MUTE]] 	 = [vdvDevice,_CT_CH_VIDEO_MUTED]
		[dvTp,anBtnStatus[_BTN_STATUS_BUSY]] 	 = [vdvDevice,_CT_CH_BUSY]
		[dvTp,anBtnStatus[_BTN_STATUS_COOLING]] = [vdvDevice,_CT_CH_COOLING]
		[dvTp,anBtnStatus[_BTN_STATUS_WARMING]] = [vdvDEvice,_CT_CH_WARMING]
	}
}
 
(**********************************************************)
(******************** HC SVNT DRACONES ********************)
(**********************************************************)