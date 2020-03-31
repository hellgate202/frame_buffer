module stb_cdc
(
  input        stb_i_clk,
  input        stb_o_clk,
  input        stb_i,
  output logic stb_o
);

logic         stb_i_lock = 1'b0;
logic         lock_rst;
logic [1 : 0] stb_sync = 2'd0;

always_ff @( posedge stb_i_clk, posedge lock_rst )
  if( lock_rst )
    stb_i_lock <= 1'b0;
  else
    if( stb_i )
      stb_i_lock <= 1'b1;

always_ff @( posedge stb_o_clk )
  begin
    stb_sync[0] <= stb_i_lock;
    stb_sync[1] <= stb_sync[0];
  end

rst_sync stb_deasset
(
  .arst_i ( stb_sync[0] ),
  .clk_i  ( stb_i_clk   ),
  .rst_o  ( lock_rst    )
);

always_ff @( posedge stb_o_clk )
  stb_o <= stb_sync[1];

endmodule
