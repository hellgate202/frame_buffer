`include "../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../lib/axi4_lib/src/class/AXI4MultiportMemory.sv"

module tb_frame_buffer;

parameter int    WR_CLK_T          = 13468;
parameter int    RD_CLK_T          = 6734;
parameter int    FRAME_RES_X       = 1920;
parameter int    FRAME_RES_Y       = 1080;
parameter int    TOTAL_X           = 2200;
parameter int    TOTAL_Y           = 1125;
parameter int    PX_WIDTH          = 16;
parameter string FILE_PATH         = "./img.hex";
parameter int    GEN_FRAME_RES_X   = 1920;
parameter int    GEN_FRAME_RES_Y   = 1080;
parameter int    GEN_FRAME_TOTAL_X = 2200;
parameter int    GEN_FRAME_TOTAL_Y = 1125;
parameter int    PX_AMOUNT         = FRAME_RES_X * FRAME_RES_Y;
parameter int    GEN_PX_AMOUNT     = GEN_FRAME_RES_X * GEN_FRAME_RES_Y;

bit wr_clk;
bit wr_rst;
bit rd_clk;
bit rd_rst;

bit [PX_WIDTH - 1 : 0] tx_frame  [GEN_PX_AMOUNT - 1 : 0];
bit [FRAME_RES_Y - 1 : 0][FRAME_RES_X - 1 : 0][PX_WIDTH - 1 : 0] ref_frame;

mailbox rx_video_mbx = new();

task automatic gen_wr_clk();
  forever
    begin
      #( WR_CLK_T / 2 );
      wr_clk = !wr_clk;
    end
endtask

task automatic gen_rd_clk();
  forever
    begin
      #( RD_CLK_T / 2 );
      rd_clk = !rd_clk;
    end
endtask

task automatic apply_wr_rst();
  wr_rst = 1'b1;
  @( posedge wr_clk );
  wr_rst = 1'b0;
endtask

task automatic apply_rd_rst();
  rd_rst = 1'b1;
  @( posedge rd_clk );
  rd_rst = 1'b0;
endtask

function automatic void init_frames();

$readmemh( FILE_PATH, tx_frame );
for( int y = 0; y < FRAME_RES_Y; y++ )
  for( int x = 0; x < FRAME_RES_X; x++ )
    if( x < GEN_FRAME_RES_X && y < GEN_FRAME_RES_Y )
      ref_frame[y][x] = tx_frame[y * GEN_FRAME_RES_X + x];
    else
      ref_frame[y][x] = PX_WIDTH'( 0 );

endfunction

task automatic check_rx_video();

int                                         line_num;
bit [7 : 0]                                 rx_line [$];
bit [FRAME_RES_X - 1 : 0][PX_WIDTH - 1 : 0] comp_line;
bit [PX_WIDTH - 1 : 0]                      comp_px;

forever
  begin
    if( rx_video_mbx.num() > 0 )
      begin
        rx_video_mbx.get( rx_line );
        for( int x = 0; x < FRAME_RES_X; x++ )
          begin
            comp_px[7 : 0]            = rx_line.pop_front();
            comp_px[PX_WIDTH - 1 : 8] = rx_line.pop_front();
            comp_line[x]              = comp_px;
          end
        if( comp_line != ref_frame[line_num] )
          begin
            $display( "oops" );
            for( int x = 0; x < FRAME_RES_X; x++ )
              $display( "0x%0h", comp_line[x] );
            $stop();
          end
        else
          if( line_num == ( FRAME_RES_Y - 1 ) )
            line_num = 0;
          else
            line_num++;
      end
    else
      @( posedge rd_clk );
  end

endtask

AXI4StreamVideoSource #(
  .PX_WIDTH    ( PX_WIDTH          ),
  .FRAME_RES_X ( GEN_FRAME_RES_X   ),
  .FRAME_RES_Y ( GEN_FRAME_RES_Y   ),
  .TOTAL_X     ( GEN_FRAME_TOTAL_X ),
  .TOTAL_Y     ( GEN_FRAME_TOTAL_Y ),
  .FILE_PATH   ( FILE_PATH         )
) video_gen;

axi4_stream_if #(
  .TDATA_WIDTH ( 16      ),
  .TID_WIDTH   ( 1       ),
  .TDEST_WIDTH ( 1       ),
  .TUSER_WIDTH ( 1       )
) video_i (
  .aclk        ( wr_clk  ),
  .aresetn     ( !wr_rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 16      ),
  .TID_WIDTH   ( 1       ),
  .TDEST_WIDTH ( 1       ),
  .TUSER_WIDTH ( 1       )
) video_o (
  .aclk        ( rd_clk  ),
  .aresetn     ( !rd_rst )
);

AXI4StreamSlave #(
  .TDATA_WIDTH ( 16 ),
  .TID_WIDTH   ( 1  ),
  .TDEST_WIDTH ( 1  ),
  .TUSER_WIDTH ( 1  ),
  .VERBOSE     ( 0  )
) video_receiver;

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
  .aclk         (      ),
  .aresetn      (      )
);

axi4_if #(
  .DATA_WIDTH   ( 64      ),
  .ADDR_WIDTH   ( 32      ),
  .ID_WIDTH     ( 1       ),
  .AWUSER_WIDTH ( 1       ),
  .WUSER_WIDTH  ( 1       ),
  .BUSER_WIDTH  ( 1       ),
  .ARUSER_WIDTH ( 1       ),
  .RUSER_WIDTH  ( 1       )
) mem_wr (
  .aclk         ( wr_clk  ),
  .aresetn      ( !wr_rst )
);

axi4_if #(
  .DATA_WIDTH   ( 64      ),
  .ADDR_WIDTH   ( 32      ),
  .ID_WIDTH     ( 1       ),
  .AWUSER_WIDTH ( 1       ),
  .WUSER_WIDTH  ( 1       ),
  .BUSER_WIDTH  ( 1       ),
  .ARUSER_WIDTH ( 1       ),
  .RUSER_WIDTH  ( 1       )
) mem_rd (
  .aclk         ( rd_clk  ),
  .aresetn      ( !rd_rst )
);

assign mem_if[0].awid     = mem_wr.awid;
assign mem_if[0].awaddr   = mem_wr.awaddr;
assign mem_if[0].awlen    = mem_wr.awlen;
assign mem_if[0].awsize   = mem_wr.awsize;
assign mem_if[0].awburst  = mem_wr.awburst;
assign mem_if[0].awlock   = mem_wr.awlock;
assign mem_if[0].awcache  = mem_wr.awcache;
assign mem_if[0].awprot   = mem_wr.awprot;
assign mem_if[0].awqos    = mem_wr.awqos;
assign mem_if[0].awregion = mem_wr.awregion;
assign mem_if[0].awuser   = mem_wr.awuser;
assign mem_if[0].awvalid  = mem_wr.awvalid;
assign mem_wr.awready     = mem_if[0].awready;
assign mem_if[0].wdata    = mem_wr.wdata;
assign mem_if[0].wstrb    = mem_wr.wstrb;
assign mem_if[0].wlast    = mem_wr.wlast;
assign mem_if[0].wuser    = mem_wr.wuser;
assign mem_if[0].wvalid   = mem_wr.wvalid;
assign mem_wr.wready      = mem_if[0].wready;
assign mem_wr.bid         = mem_if[0].bid;
assign mem_wr.bresp       = mem_if[0].bresp;
assign mem_wr.buser       = mem_if[0].buser;
assign mem_wr.bvalid      = mem_if[0].bvalid;
assign mem_if[0].bready   = mem_wr.bready;
assign mem_if[0].arid     = mem_wr.arid;
assign mem_if[0].araddr   = mem_wr.araddr;
assign mem_if[0].arlen    = mem_wr.arlen;
assign mem_if[0].arsize   = mem_wr.arsize;
assign mem_if[0].arburst  = mem_wr.arburst;
assign mem_if[0].arlock   = mem_wr.arlock;
assign mem_if[0].arcache  = mem_wr.arcache;
assign mem_if[0].arprot   = mem_wr.arprot;
assign mem_if[0].arqos    = mem_wr.arqos;
assign mem_if[0].arregion = mem_wr.arregion;
assign mem_if[0].aruser   = mem_wr.aruser;
assign mem_if[0].arvalid  = mem_wr.arvalid;
assign mem_wr.arready     = mem_if[0].arready;
assign mem_wr.rid         = mem_if[0].rid;
assign mem_wr.rdata       = mem_if[0].rdata;
assign mem_wr.rresp       = mem_if[0].rresp;
assign mem_wr.rlast       = mem_if[0].rlast;
assign mem_wr.ruser       = mem_if[0].ruser;
assign mem_wr.rvalid      = mem_if[0].rvalid;
assign mem_if[0].rready   = mem_wr.rready;
assign mem_if[0].aclk     = mem_wr.aclk;
assign mem_if[0].aresetn  = mem_wr.aresetn;

assign mem_if[1].awid     = mem_rd.awid;
assign mem_if[1].awaddr   = mem_rd.awaddr;
assign mem_if[1].awlen    = mem_rd.awlen;
assign mem_if[1].awsize   = mem_rd.awsize;
assign mem_if[1].awburst  = mem_rd.awburst;
assign mem_if[1].awlock   = mem_rd.awlock;
assign mem_if[1].awcache  = mem_rd.awcache;
assign mem_if[1].awprot   = mem_rd.awprot;
assign mem_if[1].awqos    = mem_rd.awqos;
assign mem_if[1].awregion = mem_rd.awregion;
assign mem_if[1].awuser   = mem_rd.awuser;
assign mem_if[1].awvalid  = mem_rd.awvalid;
assign mem_rd.awready     = mem_if[1].awready;
assign mem_if[1].wdata    = mem_rd.wdata;
assign mem_if[1].wstrb    = mem_rd.wstrb;
assign mem_if[1].wlast    = mem_rd.wlast;
assign mem_if[1].wuser    = mem_rd.wuser;
assign mem_if[1].wvalid   = mem_rd.wvalid;
assign mem_rd.wready      = mem_if[1].wready;
assign mem_rd.bid         = mem_if[1].bid;
assign mem_rd.bresp       = mem_if[1].bresp;
assign mem_rd.buser       = mem_if[1].buser;
assign mem_rd.bvalid      = mem_if[1].bvalid;
assign mem_if[1].bready   = mem_rd.bready;
assign mem_if[1].arid     = mem_rd.arid;
assign mem_if[1].araddr   = mem_rd.araddr;
assign mem_if[1].arlen    = mem_rd.arlen;
assign mem_if[1].arsize   = mem_rd.arsize;
assign mem_if[1].arburst  = mem_rd.arburst;
assign mem_if[1].arlock   = mem_rd.arlock;
assign mem_if[1].arcache  = mem_rd.arcache;
assign mem_if[1].arprot   = mem_rd.arprot;
assign mem_if[1].arqos    = mem_rd.arqos;
assign mem_if[1].arregion = mem_rd.arregion;
assign mem_if[1].aruser   = mem_rd.aruser;
assign mem_if[1].arvalid  = mem_rd.arvalid;
assign mem_rd.arready     = mem_if[1].arready;
assign mem_rd.rid         = mem_if[1].rid;
assign mem_rd.rdata       = mem_if[1].rdata;
assign mem_rd.rresp       = mem_if[1].rresp;
assign mem_rd.rlast       = mem_if[1].rlast;
assign mem_rd.ruser       = mem_if[1].ruser;
assign mem_rd.rvalid      = mem_if[1].rvalid;
assign mem_if[1].rready   = mem_rd.rready;
assign mem_if[1].aclk     = mem_rd.aclk;
assign mem_if[1].aresetn  = mem_rd.aresetn;


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
  .wr_clk_i      ( wr_clk       ),
  .wr_rst_i      ( wr_rst       ),
  .rd_clk_i      ( rd_clk       ),
  .rd_rst_i      ( rd_rst       ),
  .video_i       ( video_i      ),
  .video_o       ( video_o      ),
  .mem_wr        ( mem_wr       ),
  .mem_rd        ( mem_rd       )
);

bit [7 : 0] dummy_q [$];

initial
  begin
    video_gen      = new( video_i );
    video_receiver = new( video_o, rx_video_mbx );
    ram            = new( mem_if  );
    init_frames();
    fork
      gen_wr_clk();
      apply_wr_rst();
      gen_rd_clk();
      apply_rd_rst();
    join_none
    @( posedge wr_clk );
    video_receiver.stop();
    video_gen.run();
    while( !DUT.wr_done_stb_wr_clk )
      @( posedge wr_clk );
    while( !DUT.rd_done_stb_rd_clk )
      @( posedge rd_clk );
    @( posedge rd_clk );
    repeat( 4 )
      begin
        while( !( video_o.tvalid && video_o.tlast && video_o.tready ) )
          @( posedge rd_clk );
        @( posedge rd_clk );
      end
    while( rx_video_mbx.num() > 0 )
      rx_video_mbx.get( dummy_q );
    fork
      video_receiver.run();
      check_rx_video();
    join_none
    @( posedge rd_clk );
    repeat( 5 )
      begin
        while( !DUT.rd_done_stb_rd_clk )
          @( posedge rd_clk );
        @( posedge rd_clk );
      end
    while( !video_o.tuser || !video_o.tvalid || !video_o.tready )
      @( posedge rd_clk );
    repeat( 1000 )
      @( posedge rd_clk );
    $display( "Everything is fine." );
    $stop();
  end

endmodule
