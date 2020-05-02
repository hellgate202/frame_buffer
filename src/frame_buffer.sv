module frame_buffer #(
  parameter int START_ADDR    = 0,
  parameter int FRAMES_AMOUNT = 3,
  parameter int FRAME_RES_Y   = 1080,
  parameter int FRAME_RES_X   = 1920,
  parameter int TDATA_WIDTH   = 16
)(
  input                 wr_clk_i,
  input                 wr_rst_i,
  input                 rd_clk_i,
  input                 rd_rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o,
  axi4_if.master        mem_wr,
  axi4_if.master        mem_rd
);

localparam int LINE_SIZE_WIDTH     = $clog2( BYTES_IN_LINE_FIFO );
localparam int LOCAL_TDATA_WIDTH   = TDATA_WIDTH <= 8  ? 8  :
                                     TDATA_WIDTH <= 16 ? 16 :
                                     TDATA_WIDTH <= 32 ? 32 : 64;
localparam int LOCAL_TDATA_WIDTH_B = LOCAL_TDATA_WIDTH / 8;
localparam int TDATA_WIDTH_B       = TDATA_WIDTH / 8;
localparam int WORDS_IN_LINE_FIFO  = FRAME_RES_X / ( 64 / LOCAL_TDATA_WIDTH ) * 4;
localparam int BYTES_IN_LINE_FIFO  = WORDS_IN_LINE_FIFO * 8;

logic                       wr_done_stb_wr_clk;
logic                       wr_done_stb_rd_clk;
logic                       rd_done_stb_wr_clk;
logic                       rd_done_stb_rd_clk;
logic [LINE_SIZE_WIDTH : 0] line_size;

axi4_stream_if #(
  .TDATA_WIDTH ( LOCAL_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                 ),
  .TDEST_WIDTH ( 1                 ),
  .TUSER_WIDTH ( 1                 )
) video_local_i (
  .aclk        ( wr_clk_i          ),
  .aresetn     ( !wr_rst_i         )
);

assign video_local_i.tdata  = LOCAL_TDATA_WIDTH'( video_i.tdata );
assign video_local_i.tvalid = video_i.tvalid;
assign video_local_i.tlast  = video_i.tlast;
assign video_local_i.tuser  = video_i.tuser;
assign video_local_i.tstrb  = LOCAL_TDATA_WIDTH_B'( 2 ** LOCAL_TDATA_WIDTH_B - 1 );
assign video_local_i.tkeep  = LOCAL_TDATA_WIDTH_B'( 2 ** LOCAL_TDATA_WIDTH_B - 1 );
assign video_local_i.tid    = video_i.tid;
assign video_local_i.tdest  = video_i.tdest;
assign video_i.tready       = video_local_i.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) video_64_i (
  .aclk        ( wr_clk_i  ),
  .aresetn     ( !wr_rst_i )
);

axi4_stream_multiple_upsizer #(
  .SLAVE_TDATA_WIDTH  ( LOCAL_TDATA_WIDTH ),
  .MASTER_TDATA_WIDTH ( 64                )
) video_des (
  .clk_i              ( wr_clk_i          ),
  .rst_i              ( wr_rst_i          ),
  .pkt_i              ( video_local_i     ),
  .pkt_o              ( video_64_i        )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) filtered_video (
  .aclk        ( wr_clk_i  ),
  .aresetn     ( !wr_rst_i )
);

axi4_stream_fifo #(
  .TDATA_WIDTH   ( 64                 ),
  .TUSER_WIDTH   ( 1                  ),
  .TDEST_WIDTH   ( 1                  ),
  .TID_WIDTH     ( 1                  ),
  .WORDS_AMOUNT  ( WORDS_IN_LINE_FIFO ),
  .SMART         ( 1                  ),
  .SHOW_PKT_SIZE ( 1                  )
) input_filter_fifo (
  .clk_i         ( wr_clk_i           ),
  .rst_i         ( wr_rst_i           ),
  .full_o        (                    ),
  .empty_o       (                    ),
  .drop_o        (                    ),
  .used_words_o  (                    ),
  .pkts_amount_o (                    ),
  .pkt_size_o    ( line_size          ),
  .pkt_i         ( video_64_i         ),
  .pkt_o         ( filtered_video     )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) filtered_video_d (
  .aclk        ( wr_clk_i  ),
  .aresetn     ( !wr_rst_i )
);

axi4_stream_pipeline #(
  .TDATA_WIDTH ( 64               ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                ),
  .TUSER_WIDTH ( 1                )
) filtered_video_pipe (
  .clk_i       ( wr_clk_i         ),
  .rst_i       ( wr_rst_i         ),
  .pkt_i       ( filtered_video   ),
  .pkt_o       ( filtered_video_d )
);

frame_wr_ctrl #(
  .START_ADDR    ( START_ADDR         ),
  .FRAMES_AMOUNT ( FRAMES_AMOUNT      ),
  .FRAME_RES_Y   ( FRAME_RES_Y        ),
  .FRAME_RES_X   ( FRAME_RES_X        ),
  .ADDR_WIDTH    ( 32                 ),
  .TDATA_WIDTH   ( LOCAL_TDATA_WIDTH  )
) wr_ctrl (
  .clk_i         ( wr_clk_i           ),
  .rst_i         ( wr_rst_i           ),
  .line_size_i   ( line_size          ),
  .video_i       ( filtered_video_d   ),
  .mem_wr        ( mem_wr             ),
  .rd_done_stb_i ( rd_done_stb_wr_clk ),
  .wr_done_stb_o ( wr_done_stb_wr_clk )
);

stb_cdc wr_done_stb_cdc
(
  .stb_i_clk ( wr_clk_i           ),
  .stb_o_clk ( rd_clk_i           ),
  .stb_i     ( wr_done_stb_wr_clk ),
  .stb_o     ( wr_done_stb_rd_clk )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) video_64_o (
  .aclk        ( rd_clk_i  ),
  .aresetn     ( !rd_rst_i )
);

frame_rd_ctrl #(
  .START_ADDR    ( START_ADDR         ),
  .FRAMES_AMOUNT ( FRAMES_AMOUNT      ),
  .FRAME_RES_Y   ( FRAME_RES_Y        ),
  .FRAME_RES_X   ( FRAME_RES_X        ),
  .ADDR_WIDTH    ( 32                 ),
  .TDATA_WIDTH   ( LOCAL_TDATA_WIDTH  )
) rd_ctrl (
  .clk_i         ( rd_clk_i           ),
  .rst_i         ( rd_rst_i           ),
  .video_o       ( video_64_o         ),
  .mem_rd        ( mem_rd             ),
  .rd_done_stb_o ( rd_done_stb_rd_clk ),
  .wr_done_stb_i ( wr_done_stb_rd_clk )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) video_64_o_d (
  .aclk        ( rd_clk_i  ),
  .aresetn     ( !rd_rst_i )
);

axi4_stream_pipeline #(
  .TDATA_WIDTH ( 64               ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                ),
  .TUSER_WIDTH ( 1                )
) video_64_o_pipe (
  .clk_i       ( rd_clk_i         ),
  .rst_i       ( rd_rst_i         ),
  .pkt_i       ( video_64_o       ),
  .pkt_o       ( video_64_o_d     )
);

stb_cdc rd_done_stb_cdc
(
  .stb_i_clk ( rd_clk_i           ),
  .stb_o_clk ( wr_clk_i           ),
  .stb_i     ( rd_done_stb_rd_clk ),
  .stb_o     ( rd_done_stb_wr_clk )
);

axi4_stream_if #(
  .TDATA_WIDTH ( LOCAL_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                 ),
  .TDEST_WIDTH ( 1                 ),
  .TUSER_WIDTH ( 1                 )
) video_local_o (
  .aclk        ( rd_clk_i          ),
  .aresetn     ( !rd_rst_i         )
);

axi4_stream_multiple_downsizer #(
  .SLAVE_TDATA_WIDTH  ( 64                ),
  .MASTER_TDATA_WIDTH ( LOCAL_TDATA_WIDTH )
) video_ser (
  .clk_i              ( rd_clk_i          ),
  .rst_i              ( rd_rst_i          ),
  .pkt_i              ( video_64_o_d      ),
  .pkt_o              ( video_local_o     )
);

assign video_o.tdata        = TDATA_WIDTH'( video_local_o.tdata );
assign video_o.tvalid       = video_local_o.tvalid;
assign video_o.tstrb        = TDATA_WIDTH_B'( video_local_o.tstrb );
assign video_o.tkeep        = TDATA_WIDTH_B'( video_local_o.tkeep );
assign video_o.tlast        = video_local_o.tlast;
assign video_o.tid          = video_local_o.tid;
assign video_o.tdest        = video_local_o.tdest;
assign video_o.tuser        = video_local_o.tuser;
assign video_local_o.tready = video_o.tready;

localparam int LINE_CNT_WIDTH = $clog2( FRAME_RES_Y );

(* MARK_DEBUG = "TRUE" *) logic [LOCAL_TDATA_WIDTH - 1 : 0] video_o_tdata  = video_o.tdata;
(* MARK_DEBUG = "TRUE" *) logic                             video_o_tvalid = video_o.tvalid;
(* MARK_DEBUG = "TRUE" *) logic                             video_o_tready = video_o.tready;
(* MARK_DEBUG = "TRUE" *) logic                             video_o_tlast  = video_o.tlast;
(* MARK_DEBUG = "TRUE" *) logic                             video_o_tuser  = video_o.tuser;
(* MARK_DEBUG = "TRUE" *) logic [LINE_CNT_WIDTH - 1 : 0]    line_cnt;

always_ff @( posedge rd_clk_i, posedge rd_rst_i )
  if( rd_rst_i )
    line_cnt <= LINE_SIZE_WIDTH'( 0 );
  else
    if( video_o.tvalid && video_o.tready )
      if( video_o.tuser )
        line_cnt <= LINE_SIZE_WIDTH'( 0 );
      else
        if( video_o.tlast )
          line_cnt <= line_cnt + 1'b1;

endmodule
