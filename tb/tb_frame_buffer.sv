`include "../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../lib/axi4_lib/src/class/AXI4MultiportMemory.sv"

module tb_frame_buffer;

parameter int    CLK_T       = 13468;
parameter int    FRAME_RES_X = 1920;
parameter int    FRAME_RES_Y = 1080;
parameter int    TOTAL_X     = 2200;
parameter int    TOTAL_Y     = 1125;
parameter int    PX_WIDTH    = 10;
parameter string FILE_PATH = "./img.hex";

bit clk;
bit rst;

task automatic gen_clk();
  forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end
endtask

task automatic apply_rst();
  rst = 1'b1;
  @( posedge clk );
  rst = 1'b0;
endtask

AXI4StreamVideoSource #(
  .PX_WIDTH    ( PX_WIDTH    ),
  .FRAME_RES_X ( FRAME_RES_X ),
  .FRAME_RES_Y ( FRAME_RES_Y ),
  .TOTAL_X     ( TOTAL_X     ),
  .TOTAL_Y     ( TOTAL_Y     ),
  .FILE_PATH   ( FILE_PATH   )
) video_gen;

axi4_stream_if #(
  .TDATA_WIDTH ( 16   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) video_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 16   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) video_o (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_if #(
  .DATA_WIDTH   ( 64   ),
  .ADDR_WIDTH   ( 32   ),
  .ID_WIDTH     ( 1    ),
  .AWUSER_WIDTH ( 1    ),
  .WUSER_WIDTH  ( 1    ),
  .BUSER_WIDTH  ( 1    ),
  .ARUSER_WIDTH ( 1    ),
  .RUSER_WIDTH  ( 1    )
) mem_if [1 : 0] (
  .aclk         ( clk  ),
  .aresetn      ( !rst )
);

AXI4MultiportMemory #(
  .DATA_WIDTH   ( 64 ),
  .ADDR_WIDTH   ( 32 ),
  .ID_WIDTH     ( 1  ),
  .AWUSER_WIDTH ( 1  ),
  .WUSER_WIDTH  ( 1  ),
  .BUSER_WIDTH  ( 1  ),
  .ARUSER_WIDTH ( 1  ),
  .RUSER_WIDTH  ( 1  )
) ram;

frame_buffer #(
  .START_ADDR    ( 32'h3fff0000 ),
  .FRAMES_AMOUNT ( 3            ),
  .FRAME_RES_X   ( FRAME_RES_X  ),
  .FRAME_RES_Y   ( FRAME_RES_Y  )
) DUT (
  .wr_clk_i      ( clk          ),
  .wr_rst_i      ( rst          ),
  .rd_clk_i      ( clk          ),
  .rd_rst_i      ( rst          ),
  .video_i       ( video_i      ),
  .video_o       ( video_o      ),
  .mem_wr        ( mem_if[0]    ),
  .mem_rd        ( mem_if[1]    )
);

assign video_o.tready = 1'b1;

initial
  begin
    video_gen = new( video_i );
    ram       = new( mem_if  );
    fork
      gen_clk();
      apply_rst();
    join_none
    @( posedge clk );
    video_gen.run();
    repeat( 3 )
      begin
        while( !DUT.wr_done_stb_wr_clk )
          @( posedge clk );
        repeat( 2200 * 1125 + 100000 )
          @( posedge clk );
      end
    $stop();
  end

endmodule
