# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CAPTURE_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAMES_AMOUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_X" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_Y" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PX_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "START_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDATA_WIDTH_B" -parent ${Page_0}


}

proc update_PARAM_VALUE.CAPTURE_EN { PARAM_VALUE.CAPTURE_EN } {
	# Procedure called to update CAPTURE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CAPTURE_EN { PARAM_VALUE.CAPTURE_EN } {
	# Procedure called to validate CAPTURE_EN
	return true
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

proc update_PARAM_VALUE.PX_WIDTH { PARAM_VALUE.PX_WIDTH } {
	# Procedure called to update PX_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PX_WIDTH { PARAM_VALUE.PX_WIDTH } {
	# Procedure called to validate PX_WIDTH
	return true
}

proc update_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to update START_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to validate START_ADDR
	return true
}

proc update_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to update TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to validate TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.TDATA_WIDTH_B { PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to update TDATA_WIDTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_WIDTH_B { PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to validate TDATA_WIDTH_B
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

proc update_MODELPARAM_VALUE.PX_WIDTH { MODELPARAM_VALUE.PX_WIDTH PARAM_VALUE.PX_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PX_WIDTH}] ${MODELPARAM_VALUE.PX_WIDTH}
}

proc update_MODELPARAM_VALUE.TDATA_WIDTH { MODELPARAM_VALUE.TDATA_WIDTH PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_WIDTH}] ${MODELPARAM_VALUE.TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.TDATA_WIDTH_B { MODELPARAM_VALUE.TDATA_WIDTH_B PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_WIDTH_B}] ${MODELPARAM_VALUE.TDATA_WIDTH_B}
}

proc update_MODELPARAM_VALUE.CAPTURE_EN { MODELPARAM_VALUE.CAPTURE_EN PARAM_VALUE.CAPTURE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CAPTURE_EN}] ${MODELPARAM_VALUE.CAPTURE_EN}
}

