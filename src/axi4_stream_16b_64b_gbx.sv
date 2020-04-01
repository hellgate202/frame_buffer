module axi4_stream_16b_64b_gbx
(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  pkt_i,
  axi4_stream_if.master pkt_o
);

logic         rx_handshake;
logic         tx_handshake;
logic [1 : 0] ins_pos;
logic         tfirst;

assign rx_handshake = pkt_i.tvalid && pkt_i.tready;
assign tx_handshake = pkt_o.tvalid && pkt_o.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tfirst <= 1'b1;
  else
    if( rx_handshake )
      if( pkt_i.tlast )
        tfirst <= 1'b1;
      else
        tfirst <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ins_pos <= 2'd0;
  else
    if( rx_handshake )
      if( pkt_i.tlast )
        ins_pos <= 2'd0;
      else
        ins_pos <= ins_pos + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    pkt_o.tvalid <= 1'b0;
  else
    if( pkt_i.tlast || pkt_i.tvalid && ins_pos == 2'd3 )
      pkt_o.tvalid <= 1'b1;
    else
      if( pkt_i.tready )
        pkt_o.tvalid <= 1'b0;

assign pkt_i.tready = !( pkt_o.tvalid && !pkt_o.tready );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      pkt_o.tdata <= 64'd0;
      pkt_o.tkeep <= 8'd0;
      pkt_o.tstrb <= 8'd0;
    end
  else
    if( rx_handshake )
      if( ins_pos == 2'd0 )
        begin
          pkt_o.tdata <= 64'( pkt_i.tdata );
          pkt_o.tkeep <= 8'( pkt_i.tkeep );
          pkt_o.tstrb <= 8'( pkt_i.tkeep );
        end
      else
        begin
          pkt_o.tdata[( ins_pos + 1 ) * 16 - 1 -: 16] <= pkt_i.tdata;
          pkt_o.tkeep[( ins_pos + 1 ) * 2 - 1 -: 2]   <= pkt_i.tkeep;
          pkt_o.tstrb[( ins_pos + 1 ) * 2 - 1 -: 2]   <= pkt_i.tstrb;
        end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      pkt_o.tdest <= 1'b0;
      pkt_o.tid   <= 1'b0;
      pkt_o.tlast <= 1'b0;
    end
  else
    if( rx_handshake  )
      begin
        pkt_o.tdest <= pkt_i.tdest;
        pkt_o.tid   <= pkt_i.tid;
        pkt_o.tlast <= pkt_i.tlast;
      end        

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    pkt_o.tuser <= 1'b0;
  else
    if( rx_handshake && tfirst )
      pkt_o.tuser <= pkt_i.tuser;
    else
      if( tx_handshake )
        pkt_o.tuser <= 1'b0;
                 
endmodule
