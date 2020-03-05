onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider pkt_i
add wave -noupdate /tb_frame_buffer/pkt_i/aclk
add wave -noupdate /tb_frame_buffer/pkt_i/aresetn
add wave -noupdate /tb_frame_buffer/pkt_i/tvalid
add wave -noupdate /tb_frame_buffer/pkt_i/tready
add wave -noupdate /tb_frame_buffer/pkt_i/tdata
add wave -noupdate /tb_frame_buffer/pkt_i/tstrb
add wave -noupdate /tb_frame_buffer/pkt_i/tkeep
add wave -noupdate /tb_frame_buffer/pkt_i/tlast
add wave -noupdate /tb_frame_buffer/pkt_i/tid
add wave -noupdate /tb_frame_buffer/pkt_i/tdest
add wave -noupdate /tb_frame_buffer/pkt_i/tuser
add wave -noupdate -divider pkt_o
add wave -noupdate /tb_frame_buffer/pkt_o/aclk
add wave -noupdate /tb_frame_buffer/pkt_o/aresetn
add wave -noupdate /tb_frame_buffer/pkt_o/tvalid
add wave -noupdate /tb_frame_buffer/pkt_o/tready
add wave -noupdate /tb_frame_buffer/pkt_o/tdata
add wave -noupdate /tb_frame_buffer/pkt_o/tstrb
add wave -noupdate /tb_frame_buffer/pkt_o/tkeep
add wave -noupdate /tb_frame_buffer/pkt_o/tlast
add wave -noupdate /tb_frame_buffer/pkt_o/tid
add wave -noupdate /tb_frame_buffer/pkt_o/tdest
add wave -noupdate /tb_frame_buffer/pkt_o/tuser
add wave -noupdate -divider axi4_stream_to_axi4
add wave -noupdate /tb_frame_buffer/DUT_0/clk_i
add wave -noupdate /tb_frame_buffer/DUT_0/rst_i
add wave -noupdate /tb_frame_buffer/DUT_0/pkt_size_i
add wave -noupdate /tb_frame_buffer/DUT_0/addr_i
add wave -noupdate /tb_frame_buffer/DUT_0/tfirst
add wave -noupdate /tb_frame_buffer/DUT_0/rx_handshake
add wave -noupdate /tb_frame_buffer/DUT_0/w_handshake
add wave -noupdate /tb_frame_buffer/DUT_0/aw_handshake
add wave -noupdate /tb_frame_buffer/DUT_0/pkt_words_left
add wave -noupdate /tb_frame_buffer/DUT_0/burst_words_left
add wave -noupdate /tb_frame_buffer/DUT_0/cur_addr
add wave -noupdate /tb_frame_buffer/DUT_0/was_aw_handshake
add wave -noupdate /tb_frame_buffer/DUT_0/state
add wave -noupdate /tb_frame_buffer/DUT_0/next_state
add wave -noupdate -divider axi4_to_axi4_stream
add wave -noupdate /tb_frame_buffer/DUT_1/clk_i
add wave -noupdate /tb_frame_buffer/DUT_1/rst_i
add wave -noupdate /tb_frame_buffer/DUT_1/pkt_size_i
add wave -noupdate /tb_frame_buffer/DUT_1/addr_i
add wave -noupdate /tb_frame_buffer/DUT_1/rd_stb
add wave -noupdate /tb_frame_buffer/DUT_1/r_handshake
add wave -noupdate /tb_frame_buffer/DUT_1/ar_handshake
add wave -noupdate /tb_frame_buffer/DUT_1/pkt_words_left
add wave -noupdate /tb_frame_buffer/DUT_1/burst_words_left
add wave -noupdate /tb_frame_buffer/DUT_1/cur_addr
add wave -noupdate /tb_frame_buffer/DUT_1/was_ar_handshake
add wave -noupdate /tb_frame_buffer/DUT_1/tlast_tstrb
add wave -noupdate /tb_frame_buffer/DUT_1/state
add wave -noupdate /tb_frame_buffer/DUT_1/next_state
add wave -noupdate -divider wr_mem
add wave -noupdate {/tb_frame_buffer/mem[0]/aclk}
add wave -noupdate {/tb_frame_buffer/mem[0]/aresetn}
add wave -noupdate {/tb_frame_buffer/mem[0]/awid}
add wave -noupdate {/tb_frame_buffer/mem[0]/awaddr}
add wave -noupdate {/tb_frame_buffer/mem[0]/awlen}
add wave -noupdate {/tb_frame_buffer/mem[0]/awsize}
add wave -noupdate {/tb_frame_buffer/mem[0]/awburst}
add wave -noupdate {/tb_frame_buffer/mem[0]/awlock}
add wave -noupdate {/tb_frame_buffer/mem[0]/awcache}
add wave -noupdate {/tb_frame_buffer/mem[0]/awprot}
add wave -noupdate {/tb_frame_buffer/mem[0]/awqos}
add wave -noupdate {/tb_frame_buffer/mem[0]/awregion}
add wave -noupdate {/tb_frame_buffer/mem[0]/awuser}
add wave -noupdate {/tb_frame_buffer/mem[0]/awvalid}
add wave -noupdate {/tb_frame_buffer/mem[0]/awready}
add wave -noupdate {/tb_frame_buffer/mem[0]/wdata}
add wave -noupdate {/tb_frame_buffer/mem[0]/wstrb}
add wave -noupdate {/tb_frame_buffer/mem[0]/wlast}
add wave -noupdate {/tb_frame_buffer/mem[0]/wuser}
add wave -noupdate {/tb_frame_buffer/mem[0]/wvalid}
add wave -noupdate {/tb_frame_buffer/mem[0]/wready}
add wave -noupdate {/tb_frame_buffer/mem[0]/bid}
add wave -noupdate {/tb_frame_buffer/mem[0]/bresp}
add wave -noupdate {/tb_frame_buffer/mem[0]/buser}
add wave -noupdate {/tb_frame_buffer/mem[0]/bvalid}
add wave -noupdate {/tb_frame_buffer/mem[0]/bready}
add wave -noupdate {/tb_frame_buffer/mem[0]/arid}
add wave -noupdate {/tb_frame_buffer/mem[0]/araddr}
add wave -noupdate {/tb_frame_buffer/mem[0]/arlen}
add wave -noupdate {/tb_frame_buffer/mem[0]/arsize}
add wave -noupdate {/tb_frame_buffer/mem[0]/arburst}
add wave -noupdate {/tb_frame_buffer/mem[0]/arlock}
add wave -noupdate {/tb_frame_buffer/mem[0]/arcache}
add wave -noupdate {/tb_frame_buffer/mem[0]/arprot}
add wave -noupdate {/tb_frame_buffer/mem[0]/arqos}
add wave -noupdate {/tb_frame_buffer/mem[0]/arregion}
add wave -noupdate {/tb_frame_buffer/mem[0]/aruser}
add wave -noupdate {/tb_frame_buffer/mem[0]/arvalid}
add wave -noupdate {/tb_frame_buffer/mem[0]/arready}
add wave -noupdate {/tb_frame_buffer/mem[0]/rid}
add wave -noupdate {/tb_frame_buffer/mem[0]/rdata}
add wave -noupdate {/tb_frame_buffer/mem[0]/rresp}
add wave -noupdate {/tb_frame_buffer/mem[0]/rlast}
add wave -noupdate {/tb_frame_buffer/mem[0]/ruser}
add wave -noupdate {/tb_frame_buffer/mem[0]/rvalid}
add wave -noupdate {/tb_frame_buffer/mem[0]/rready}
add wave -noupdate -divider rd_mem
add wave -noupdate {/tb_frame_buffer/mem[1]/aclk}
add wave -noupdate {/tb_frame_buffer/mem[1]/aresetn}
add wave -noupdate {/tb_frame_buffer/mem[1]/awid}
add wave -noupdate {/tb_frame_buffer/mem[1]/awaddr}
add wave -noupdate {/tb_frame_buffer/mem[1]/awlen}
add wave -noupdate {/tb_frame_buffer/mem[1]/awsize}
add wave -noupdate {/tb_frame_buffer/mem[1]/awburst}
add wave -noupdate {/tb_frame_buffer/mem[1]/awlock}
add wave -noupdate {/tb_frame_buffer/mem[1]/awcache}
add wave -noupdate {/tb_frame_buffer/mem[1]/awprot}
add wave -noupdate {/tb_frame_buffer/mem[1]/awqos}
add wave -noupdate {/tb_frame_buffer/mem[1]/awregion}
add wave -noupdate {/tb_frame_buffer/mem[1]/awuser}
add wave -noupdate {/tb_frame_buffer/mem[1]/awvalid}
add wave -noupdate {/tb_frame_buffer/mem[1]/awready}
add wave -noupdate {/tb_frame_buffer/mem[1]/wdata}
add wave -noupdate {/tb_frame_buffer/mem[1]/wstrb}
add wave -noupdate {/tb_frame_buffer/mem[1]/wlast}
add wave -noupdate {/tb_frame_buffer/mem[1]/wuser}
add wave -noupdate {/tb_frame_buffer/mem[1]/wvalid}
add wave -noupdate {/tb_frame_buffer/mem[1]/wready}
add wave -noupdate {/tb_frame_buffer/mem[1]/bid}
add wave -noupdate {/tb_frame_buffer/mem[1]/bresp}
add wave -noupdate {/tb_frame_buffer/mem[1]/buser}
add wave -noupdate {/tb_frame_buffer/mem[1]/bvalid}
add wave -noupdate {/tb_frame_buffer/mem[1]/bready}
add wave -noupdate {/tb_frame_buffer/mem[1]/arid}
add wave -noupdate {/tb_frame_buffer/mem[1]/araddr}
add wave -noupdate {/tb_frame_buffer/mem[1]/arlen}
add wave -noupdate {/tb_frame_buffer/mem[1]/arsize}
add wave -noupdate {/tb_frame_buffer/mem[1]/arburst}
add wave -noupdate {/tb_frame_buffer/mem[1]/arlock}
add wave -noupdate {/tb_frame_buffer/mem[1]/arcache}
add wave -noupdate {/tb_frame_buffer/mem[1]/arprot}
add wave -noupdate {/tb_frame_buffer/mem[1]/arqos}
add wave -noupdate {/tb_frame_buffer/mem[1]/arregion}
add wave -noupdate {/tb_frame_buffer/mem[1]/aruser}
add wave -noupdate {/tb_frame_buffer/mem[1]/arvalid}
add wave -noupdate {/tb_frame_buffer/mem[1]/arready}
add wave -noupdate {/tb_frame_buffer/mem[1]/rid}
add wave -noupdate {/tb_frame_buffer/mem[1]/rdata}
add wave -noupdate {/tb_frame_buffer/mem[1]/rresp}
add wave -noupdate {/tb_frame_buffer/mem[1]/rlast}
add wave -noupdate {/tb_frame_buffer/mem[1]/ruser}
add wave -noupdate {/tb_frame_buffer/mem[1]/rvalid}
add wave -noupdate {/tb_frame_buffer/mem[1]/rready}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12771493 ps} 0}
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
WaveRestoreZoom {4615124 ps} {14743440 ps}
