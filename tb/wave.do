onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/aclk
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/aresetn
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tvalid
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tready
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tdata
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tstrb
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tkeep
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tlast
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tid
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tdest
add wave -noupdate /tb_frame_buffer/DUT/pkt_i/tuser
add wave -noupdate /tb_frame_buffer/DUT/clk_i
add wave -noupdate /tb_frame_buffer/DUT/rst_i
add wave -noupdate -radix unsigned /tb_frame_buffer/DUT/pkt_size_i
add wave -noupdate /tb_frame_buffer/DUT/addr_i
add wave -noupdate /tb_frame_buffer/DUT/tfirst
add wave -noupdate /tb_frame_buffer/DUT/rx_handshake
add wave -noupdate /tb_frame_buffer/DUT/w_handshake
add wave -noupdate /tb_frame_buffer/DUT/aw_handshake
add wave -noupdate -radix unsigned /tb_frame_buffer/DUT/pkt_words_left
add wave -noupdate -radix unsigned /tb_frame_buffer/DUT/burst_words_left
add wave -noupdate /tb_frame_buffer/DUT/cur_addr
add wave -noupdate /tb_frame_buffer/DUT/was_aw_handshake
add wave -noupdate /tb_frame_buffer/DUT/state
add wave -noupdate /tb_frame_buffer/DUT/next_state
add wave -noupdate /tb_frame_buffer/DUT/mem_o/aclk
add wave -noupdate /tb_frame_buffer/DUT/mem_o/aresetn
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awaddr
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awlen
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awsize
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awburst
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awlock
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awcache
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awprot
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awqos
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awregion
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awuser
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awvalid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/awready
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wdata
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wstrb
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wlast
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wuser
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wvalid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/wready
add wave -noupdate /tb_frame_buffer/DUT/mem_o/bid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/bresp
add wave -noupdate /tb_frame_buffer/DUT/mem_o/buser
add wave -noupdate /tb_frame_buffer/DUT/mem_o/bvalid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/bready
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/araddr
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arlen
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arsize
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arburst
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arlock
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arcache
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arprot
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arqos
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arregion
add wave -noupdate /tb_frame_buffer/DUT/mem_o/aruser
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arvalid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/arready
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rdata
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rresp
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rlast
add wave -noupdate /tb_frame_buffer/DUT/mem_o/ruser
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rvalid
add wave -noupdate /tb_frame_buffer/DUT/mem_o/rready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8376000 ps} 0}
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
WaveRestoreZoom {0 ps} {14154 ns}
