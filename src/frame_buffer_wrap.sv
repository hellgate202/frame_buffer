module frame_buffer_wrap #(
  parameter int START_ADDR    = 0,
  parameter int FRAMES_AMOUNT = 3,
  parameter int FRAME_RES_Y   = 1080,
  parameter int FRAME_RES_X   = 1920,
  parameter int PX_WIDTH      = 10,
  parameter int TDATA_WIDTH   = 16,
  parameter int TDATA_WIDTH_B = 2
)(
  input                          wr_clk_i,
  input                          wr_rst_i,
  input                          rd_clk_i,
  input                          rd_rst_i,
  // Input video stream
  input                          video_i_tvalid,
  output                         video_i_tready,
  input  [TDATA_WIDTH - 1 : 0]   video_i_tdata,
  input  [TDATA_WIDTH_B - 1 : 0] video_i_tstrb,
  input  [TDATA_WIDTH_B - 1 : 0] video_i_tkeep,
  input                          video_i_tlast,
  input                          video_i_tid,
  input                          video_i_tdest,
  input                          video_i_tuser,
  // Output video stream
  output                         video_o_tvalid,
  input                          video_o_tready,
  output [TDATA_WIDTH - 1 : 0]   video_o_tdata,
  output [TDATA_WIDTH_B - 1 : 0] video_o_tstrb,
  output [TDATA_WIDTH_B - 1 : 0] video_o_tkeep,
  output                         video_o_tlast,
  output                         video_o_tid,
  output                         video_o_tdest,
  output                         video_o_tuser,
  // Write memory port 
  output                         mem_wr_awid,
  output [31 : 0]                mem_wr_awaddr,
  output [7 : 0]                 mem_wr_awlen,
  output [2 : 0]                 mem_wr_awsize,
  output [1 : 0]                 mem_wr_awburst,
  output                         mem_wr_awlock,
  output [3 : 0]                 mem_wr_awcache,
  output [2 : 0]                 mem_wr_awprot,
  output [3 : 0]                 mem_wr_awqos,
  output [3 : 0]                 mem_wr_awregion,
  output                         mem_wr_awuser,
  output                         mem_wr_awvalid,
  input                          mem_wr_awready,
  output [63 : 0]                mem_wr_wdata,
  output [7 : 0]                 mem_wr_wstrb,
  output                         mem_wr_wlast,
  output                         mem_wr_wuser,
  output                         mem_wr_wvalid,
  input                          mem_wr_wready,
  input                          mem_wr_bid,
  input  [1 : 0]                 mem_wr_bresp,
  input                          mem_wr_buser,
  input                          mem_wr_bvalid,
  output                         mem_wr_bready,
  output                         mem_wr_arid,
  output [31 : 0]                mem_wr_araddr,
  output [7 : 0]                 mem_wr_arlen,
  output [2 : 0]                 mem_wr_arsize,
  output [1 : 0]                 mem_wr_arburst,
  output                         mem_wr_arlock,
  output [3 : 0]                 mem_wr_arcache,
  output [2 : 0]                 mem_wr_arprot,
  output [3 : 0]                 mem_wr_arqos,
  output [3 : 0]                 mem_wr_arregion,
  output                         mem_wr_aruser,
  output                         mem_wr_arvalid,
  input                          mem_wr_arready,
  input                          mem_wr_rid,
  input  [63 : 0]                mem_wr_rdata,
  input  [1 : 0]                 mem_wr_rresp,
  input                          mem_wr_rlast,
  input                          mem_wr_ruser,
  input                          mem_wr_rvalid,
  output                         mem_wr_rready,
  // Read memory port
  output                         mem_rd_awid,
  output [31 : 0]                mem_rd_awaddr,
  output [7 : 0]                 mem_rd_awlen,
  output [2 : 0]                 mem_rd_awsize,
  output [1 : 0]                 mem_rd_awburst,
  output                         mem_rd_awlock,
  output [3 : 0]                 mem_rd_awcache,
  output [2 : 0]                 mem_rd_awprot,
  output [3 : 0]                 mem_rd_awqos,
  output [3 : 0]                 mem_rd_awregion,
  output                         mem_rd_awuser,
  output                         mem_rd_awvalid,
  input                          mem_rd_awready,
  output [63 : 0]                mem_rd_wdata,
  output [7 : 0]                 mem_rd_wstrb,
  output                         mem_rd_wlast,
  output                         mem_rd_wuser,
  output                         mem_rd_wvalid,
  input                          mem_rd_wready,
  input                          mem_rd_bid,
  input  [1 : 0]                 mem_rd_bresp,
  input                          mem_rd_buser,
  input                          mem_rd_bvalid,
  output                         mem_rd_bready,
  output                         mem_rd_arid,
  output [31 : 0]                mem_rd_araddr,
  output [7 : 0]                 mem_rd_arlen,
  output [2 : 0]                 mem_rd_arsize,
  output [1 : 0]                 mem_rd_arburst,
  output                         mem_rd_arlock,
  output [3 : 0]                 mem_rd_arcache,
  output [2 : 0]                 mem_rd_arprot,
  output [3 : 0]                 mem_rd_arqos,
  output [3 : 0]                 mem_rd_arregion,
  output                         mem_rd_aruser,
  output                         mem_rd_arvalid,
  input                          mem_rd_arready,
  input                          mem_rd_rid,
  input  [63 : 0]                mem_rd_rdata,
  input  [1 : 0]                 mem_rd_rresp,
  input                          mem_rd_rlast,
  input                          mem_rd_ruser,
  input                          mem_rd_rvalid,
  output                         mem_rd_rready
);

axi4_if #(
  .DATA_WIDTH   ( 64        ),
  .ADDR_WIDTH   ( 32        ),
  .ID_WIDTH     ( 1         ),
  .AWUSER_WIDTH ( 1         ),
  .WUSER_WIDTH  ( 1         ),
  .BUSER_WIDTH  ( 1         ),
  .ARUSER_WIDTH ( 1         ),
  .RUSER_WIDTH  ( 1         )
) mem_wr (
  .aclk         ( wr_clk_i  ),
  .aresetn      ( !wr_rst_i )
);

assign mem_wr.awid     = mem_wr_awid;
assign mem_wr.awaddr   = mem_wr_awaddr;
assign mem_wr.awlen    = mem_wr_awlen;
assign mem_wr.awsize   = mem_wr_awsize;
assign mem_wr.awburst  = mem_wr_awburst;
assign mem_wr.awlock   = mem_wr_awlock;
assign mem_wr.awcache  = mem_wr_awcache;
assign mem_wr.awprot   = mem_wr_awprot;
assign mem_wr.awqos    = mem_wr_awqos;
assign mem_wr.awregion = mem_wr_awregion;
assign mem_wr.awuser   = mem_wr_awuser;
assign mem_wr.awvalid  = mem_wr_awvalid;
assign mem_wr_awready  = mem_wr.awready;
assign mem_wr.wdata    = mem_wr_wdata;
assign mem_wr.wstrb    = mem_wr_wstrb;
assign mem_wr.wlast    = mem_wr_wlast;
assign mem_wr.wuser    = mem_wr_wuser;
assign mem_wr.wvalid   = mem_wr_wvalid;
assign mem_wr_wready   = mem_wr.wready;
assign mem_wr_bid      = mem_wr.bid;
assign mem_wr_bresp    = mem_wr.bresp;
assign mem_wr_buser    = mem_wr.buser;
assign mem_wr_bvalid   = mem_wr.bvalid;
assign mem_wr.bready   = mem_wr_bready;
assign mem_wr.arid     = mem_wr_arid;
assign mem_wr.araddr   = mem_wr_araddr;
assign mem_wr.arlen    = mem_wr_arlen;
assign mem_wr.arsize   = mem_wr_arsize;
assign mem_wr.arburst  = mem_wr_arburst;
assign mem_wr.arlock   = mem_wr_arlock;
assign mem_wr.arcache  = mem_wr_arcache;
assign mem_wr.arprot   = mem_wr_arprot;
assign mem_wr.arqos    = mem_wr_arqos;
assign mem_wr.arregion = mem_wr_arregion;
assign mem_wr.aruser   = mem_wr_aruser;
assign mem_wr.arvalid  = mem_wr_arvalid;
assign mem_wr_arready  = mem_wr.arready;
assign mem_wr_rid      = mem_wr.rid;
assign mem_wr_rdata    = mem_wr.rdata;
assign mem_wr_rresp    = mem_wr.rresp;
assign mem_wr_rlast    = mem_wr.rlast;
assign mem_wr_ruser    = mem_wr.ruser;
assign mem_wr_rvalid   = mem_wr.rvalid;
assign mem_wr.rready   = mem_wr_rready;

axi4_if #(
  .DATA_WIDTH   ( 64        ),
  .ADDR_WIDTH   ( 32        ),
  .ID_WIDTH     ( 1         ),
  .AWUSER_WIDTH ( 1         ),
  .WUSER_WIDTH  ( 1         ),
  .BUSER_WIDTH  ( 1         ),
  .ARUSER_WIDTH ( 1         ),
  .RUSER_WIDTH  ( 1         )
) mem_rd (
  .aclk         ( rd_clk_i  ),
  .aresetn      ( !rd_rst_i )
);

assign mem_rd.awid     = mem_rd_awid;
assign mem_rd.awaddr   = mem_rd_awaddr;
assign mem_rd.awlen    = mem_rd_awlen;
assign mem_rd.awsize   = mem_rd_awsize;
assign mem_rd.awburst  = mem_rd_awburst;
assign mem_rd.awlock   = mem_rd_awlock;
assign mem_rd.awcache  = mem_rd_awcache;
assign mem_rd.awprot   = mem_rd_awprot;
assign mem_rd.awqos    = mem_rd_awqos;
assign mem_rd.awregion = mem_rd_awregion;
assign mem_rd.awuser   = mem_rd_awuser;
assign mem_rd.awvalid  = mem_rd_awvalid;
assign mem_rd_awready  = mem_rd.awready;
assign mem_rd.wdata    = mem_rd_wdata;
assign mem_rd.wstrb    = mem_rd_wstrb;
assign mem_rd.wlast    = mem_rd_wlast;
assign mem_rd.wuser    = mem_rd_wuser;
assign mem_rd.wvalid   = mem_rd_wvalid;
assign mem_rd_wready   = mem_rd.wready;
assign mem_rd_bid      = mem_rd.bid;
assign mem_rd_bresp    = mem_rd.bresp;
assign mem_rd_buser    = mem_rd.buser;
assign mem_rd_bvalid   = mem_rd.bvalid;
assign mem_rd.bready   = mem_rd_bready;
assign mem_rd.arid     = mem_rd_arid;
assign mem_rd.araddr   = mem_rd_araddr;
assign mem_rd.arlen    = mem_rd_arlen;
assign mem_rd.arsize   = mem_rd_arsize;
assign mem_rd.arburst  = mem_rd_arburst;
assign mem_rd.arlock   = mem_rd_arlock;
assign mem_rd.arcache  = mem_rd_arcache;
assign mem_rd.arprot   = mem_rd_arprot;
assign mem_rd.arqos    = mem_rd_arqos;
assign mem_rd.arregion = mem_rd_arregion;
assign mem_rd.aruser   = mem_rd_aruser;
assign mem_rd.arvalid  = mem_rd_arvalid;
assign mem_rd_arready  = mem_rd.arready;
assign mem_rd_rid      = mem_rd.rid;
assign mem_rd_rdata    = mem_rd.rdata;
assign mem_rd_rresp    = mem_rd.rresp;
assign mem_rd_rlast    = mem_rd.rlast;
assign mem_rd_ruser    = mem_rd.ruser;
assign mem_rd_rvalid   = mem_rd.rvalid;
assign mem_rd.rready   = mem_rd_rready;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_i (
  .aclk        ( wr_clk_i    ),
  .aresetn     ( !wr_rst_i   )
);

assign video_i.tvalid = video_i_tvalid;
assign video_i.tdata  = video_i_tdata;
assign video_i.tstrb  = video_i_tstrb;
assign video_i.tkeep  = video_i_tkeep;
assign video_i.tuser  = video_i_tuser;
assign video_i.tid    = video_i_tid;
assign video_i.tdest  = video_i_tdest;
assign video_i.tlast  = video_i_tlast;
assign video_i_tready = video_i.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_o (
  .aclk        ( rd_clk_i    ),
  .aresetn     ( !rd_rst_i   )
);

assign video_o_tvalid = video_o.tvalid;
assign video_o_tdata  = video_o.tdata;
assign video_o_tstrb  = video_o.tstrb;
assign video_o_tkeep  = video_o.tkeep;
assign video_o_tuser  = video_o.tuser;
assign video_o_tid    = video_o.tid;
assign video_o_tdest  = video_o.tdest;
assign video_o_tlast  = video_o.tlast;
assign video_o.tready = video_o_tready;

frame_buffer #(
  .START_ADDR    ( START_ADDR    ),
  .FRAMES_AMOUNT ( FRAMES_AMOUNT ),
  .FRAME_RES_Y   ( FRAME_RES_Y   ),
  .FRAME_RES_X   ( FRAME_RES_X   ),
  .TDATA_WIDTH   ( TDATA_WIDTH   )
) frame_buffer_inst (
  .wr_clk_i      ( wr_clk_i      ),
  .wr_rst_i      ( wr_rst_i      ),
  .rd_clk_i      ( rd_clk_i      ),
  .rd_rst_i      ( rd_rst_i      ),
  .video_i       ( video_i       ),
  .video_o       ( video_o       ),
  .mem_wr        ( mem_wr        ),
  .mem_rd        ( mem_rd        )
);

endmodule
