module rst_sync
(
  input  arst_i,
  input  clk_i,
  output rst_o
);

logic [1 : 0] rst_d;

always_ff @( posedge clk_i, posedge arst_i )
  if( arst_i )
    begin
      rst_d[0] <= 1'b1;
      rst_d[1] <= 1'b1;
    end
  else
    begin
      rst_d[0] <= 1'b0;
      rst_d[1] <= rst_d[0];
    end

assign rst_o = rst_d[1];

endmodule
