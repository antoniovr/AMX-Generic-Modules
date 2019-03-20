MODULE_NAME='UI_Activation_Channel'(dev dvDev,
												dev dvTp,
												
												integer anBtnPulse[],
												integer anIrPulse[],
												integer anPulseTimes[],
												
												integer anBtnTo[],
												integer anIrTo[])


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

(**********************************************************)
(******************** 	EARPRO 2019 	********************)
(**********************************************************) 