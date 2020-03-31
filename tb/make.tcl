vlib work
vlog -sv -f files
vopt +acc tb_frame_buffer -o tb_frame_buffer_opt
vsim tb_frame_buffer_opt
do wave.do
run -all
