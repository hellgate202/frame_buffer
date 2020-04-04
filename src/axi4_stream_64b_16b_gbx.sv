module axi4_stream_64b_16b_gbx
(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  pkt_i,
  axi4_stream_if.master pkt_o
);

logic                 rx_handshake;
logic                 tx_handshake;
logic [1 : 0]         ins_pos;
logic [3 : 0][15 : 0] tdata_buf;
logic [3 : 0][1 : 0]  tstrb_buf;
logic [3 : 0][1 : 0]  tkeep_buf;
logic                 tuser_buf;
logic                 tdest_buf;
logic                 tid_buf;
logic                 tlast_buf;
logic                 word_lock;
logic [1 : 0]         syms_in_rx_w, syms_in_rx_w_lock;

assign rx_handshake = pkt_i.tvalid && pkt_i.tready;
assign tx_handshake = pkt_o.tvalid && pkt_o.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      tdata_buf <= 64'd0;
      tstrb_buf <= 8'd0;
      tkeep_buf <= 8'd0;
      tuser_buf <= 1'b0;
      tdest_buf <= 1'b0;
      tid_buf   <= 1'b0;
      tlast_buf <= 1'b0;
    end
  else
    if( rx_handshake )
      begin
        tdata_buf <= pkt_i.tdata;
        tstrb_buf <= pkt_i.tstrb;
        tkeep_buf <= pkt_i.tkeep;
        tuser_buf <= pkt_i.tuser;
        tdest_buf <= pkt_i.tdest;
        tid_buf   <= pkt_i.tid;
        tlast_buf <= pkt_i.tlast;
      end

always_comb
  begin
    syms_in_rx_w = 2'd0;
    for( int i = 1; i < 4; i++ )
      if( pkt_i.tkeep[i] )
        syms_in_rx_w = syms_in_rx_w + 1'b1;
  end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    syms_in_rx_w_lock <= 2'd0;
  else
    if( rx_handshake )
      syms_in_rx_w_lock <= syms_in_rx_w;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    word_lock <= 1'b0;
  else
    if( rx_handshake )
      word_lock <= 1'b1;
    else
      if( tx_handshake && ins_pos == 2'd3 )
        word_lock <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ins_pos <= 2'd0;
  else
    if( tx_handshake )
      if( ins_pos == syms_in_rx_w_lock )
        ins_pos <= 2'd0;
      else
        if( tx_handshake )
          ins_pos <= ins_pos + 1'b1;

assign pkt_i.tready = !word_lock || ins_pos == 2'd3;
assign pkt_o.tvalid = word_lock;
assign pkt_o.tdata  = tdata_buf[ins_pos];
assign pkt_o.tkeep  = tkeep_buf[ins_pos];
assign pkt_o.tstrb  = tstrb_buf[ins_pos];
assign pkt_o.tlast  = tlast_buf && ins_pos == syms_in_rx_w_lock;
assign pkt_o.tdest  = tdest_buf;
assign pkt_o.tid    = tid_buf;
assign pkt_o.tuser  = tuser_buf && ins_pos == 2'd0;

endmodule
