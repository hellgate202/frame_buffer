# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "FRAMES_AMOUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_X" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_Y" -parent ${Page_0}
  ipgui::add_param $IPINST -name "START_ADDR" -parent ${Page_0}


}

proc update_PARAM_VALUE.FRAMES_AMOUNT { PARAM_VALUE.FRAMES_AMOUNT } {
	# Procedure called to update FRAMES_AMOUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAMES_AMOUNT { PARAM_VALUE.FRAMES_AMOUNT } {
	# Procedure called to validate FRAMES_AMOUNT
	return true
}

proc update_PARAM_VALUE.FRAME_RES_X { PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to update FRAME_RES_X when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_RES_X { PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to validate FRAME_RES_X
	return true
}

proc update_PARAM_VALUE.FRAME_RES_Y { PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to update FRAME_RES_Y when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_RES_Y { PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to validate FRAME_RES_Y
	return true
}

proc update_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to update START_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to validate START_ADDR
	return true
}


proc update_MODELPARAM_VALUE.START_ADDR { MODELPARAM_VALUE.START_ADDR PARAM_VALUE.START_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.START_ADDR}] ${MODELPARAM_VALUE.START_ADDR}
}

proc update_MODELPARAM_VALUE.FRAMES_AMOUNT { MODELPARAM_VALUE.FRAMES_AMOUNT PARAM_VALUE.FRAMES_AMOUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAMES_AMOUNT}] ${MODELPARAM_VALUE.FRAMES_AMOUNT}
}

proc update_MODELPARAM_VALUE.FRAME_RES_Y { MODELPARAM_VALUE.FRAME_RES_Y PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_RES_Y}] ${MODELPARAM_VALUE.FRAME_RES_Y}
}

proc update_MODELPARAM_VALUE.FRAME_RES_X { MODELPARAM_VALUE.FRAME_RES_X PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_RES_X}] ${MODELPARAM_VALUE.FRAME_RES_X}
}

