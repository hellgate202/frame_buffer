onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_frame_buffer/video_i/aclk
add wave -noupdate /tb_frame_buffer/video_i/aresetn
add wave -noupdate /tb_frame_buffer/video_i/tvalid
add wave -noupdate /tb_frame_buffer/video_i/tready
add wave -noupdate /tb_frame_buffer/video_i/tdata
add wave -noupdate /tb_frame_buffer/video_i/tstrb
add wave -noupdate /tb_frame_buffer/video_i/tkeep
add wave -noupdate /tb_frame_buffer/video_i/tlast
add wave -noupdate /tb_frame_buffer/video_i/tid
add wave -noupdate /tb_frame_buffer/video_i/tdest
add wave -noupdate /tb_frame_buffer/video_i/tuser
add wave -noupdate /tb_frame_buffer/DUT/video_o/aclk
add wave -noupdate /tb_frame_buffer/DUT/video_o/aresetn
add wave -noupdate /tb_frame_buffer/DUT/video_o/tvalid
add wave -noupdate /tb_frame_buffer/DUT/video_o/tready
add wave -noupdate /tb_frame_buffer/DUT/video_o/tdata
add wave -noupdate /tb_frame_buffer/DUT/video_o/tstrb
add wave -noupdate /tb_frame_buffer/DUT/video_o/tkeep
add wave -noupdate /tb_frame_buffer/DUT/video_o/tlast
add wave -noupdate /tb_frame_buffer/DUT/video_o/tid
add wave -noupdate /tb_frame_buffer/DUT/video_o/tdest
add wave -noupdate /tb_frame_buffer/DUT/video_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31996218078 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {68553172861 ps}
