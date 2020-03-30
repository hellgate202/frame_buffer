module frame_rd_ctrl #(
  parameter int START_ADDR    = 0,
  parameter int FRAMES_AMOUNT = 3,
  parameter int FRAME_RES_Y   = 1080,
  parameter int FRAME_RES_X   = 1920,
  parameter int ADDR_WIDTH    = 32
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.master video_o,
  axi4_if.master        mem_rd,
  output                rd_done_o,
  input                 rd_done_ack_i,
  input                 wr_done_i,
  output                wr_done_ack_o
);

localparam int WORDS_PER_LINE         = FRAME_RES_X % 4 ? FRAME_RES_X / 4 + 1 : FRAME_RES_X / 4;
localparam int WORDS_PER_FRAME        = WORDS_PER_LINE * FRAME_RES_Y;
localparam int BYTES_PER_LINE         = WORDS_PER_LINE * 8;
localparam int BYTES_PER_FRAME        = WORDS_PER_FRAME * 8;
localparam int FRAME_CNT_WIDTH        = $clog2( FRAMES_AMOUNT ) + 1;
localparam int LAST_FRAME_START_ADDR  = START_ADDR + BYTES_PER_FRAME * ( FRAMES_AMOUNT - 1 );

logic [FRAME_CNT_WIDTH - 1 : 0] frame_cnt;
logic [ADDR_WIDTH - 1 : 0]      mem_addr;
logic [ADDR_WIDTH - 1 : 0]      cur_frame_addr;
logic [ADDR_WIDTH - 1 : 0]      last_line_addr;
logic [ADDR_WIDTH : 0]          lines_in_fifo;
logic                           rd_req;
logic                           new_addr_req;
logic                           frame_read_finish, frame_read_finish_d1;
logic                           new_frame_avail;
logic                           read_allow;
logic                           make_decision;
logic                           ready_to_read;
logic                           rd_done_ack_d1;
logic                           rd_done_ack_posedge;
logic                           wr_done_d1;
logic                           wr_done_posedge;
logic                           wr_done_negedge;

assign new_addr_req      = video_line.tvalid && video_line.tready && video_line.tlast;
assign frame_read_finish = new_addr_req && mem_addr == last_line_addr;
assign new_frame_avail   = frame_cnt > FRAME_CNT_WIDTH'( 1 );
assign read_allow        = lines_in_fifo < ADDR_WIDTH'( 4 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    last_line_addr <= ADDR_WIDTH'( START_ADDR + BYTES_PER_FRAME - BYTES_PER_LINE );
  else
    if( frame_read_finish && new_frame_avail )
      last_line_addr <= next_frame_addr + ADDR_WIDTH'( BYTES_PER_FRAME - BYTES_PER_LINE );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_frame_addr <= ADDR_WIDTH'( START_ADDR );
  else
    if( frame_read_finish && new_frame_avail )
      if( cur_frame_addr == ADDR_WIDTH'( LAST_FRAME_START_ADDR ) )
        cur_frame_addr <= ADDR_WIDTH'( START_ADDR );
      else
        cur_frame_addr <= cur_frame_addr + ADDR_WIDTH'( BYTES_PER_FRAME );
    
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    make_decision <= 1'b0;
  else
    make_decision <= new_addr_req;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    frame_read_finish_d1 <= 1'b0;
  else
    frame_read_finish_d1 <= frame_read_finish;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mem_addr <= ADDR_WIDTH'( START_ADDR );
  else
    if( make_decision )
      if( frame_read_finish_d1 )
        mem_addr <= cur_frame_addr;
      else
        mem_addr <= mem_addr + ADDR_WIDTH'( BYTES_PER_LINE );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ready_to_read <= 1'b1;
  else
    if( rd_req )
      ready_to_read <= 1'b0;
    else
      if( make_decision )
        ready_to_read <= 1'b1;

assign rd_req = ready_to_read && read_allow;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    frame_cnt <= FRAME_CNT_WIDTH'( 0 );
  else
    if( frame_read_finish && !wr_done_posedge && frame_cnt > FRAME_CNT_WIDTH'( 1 ) )
      frame_cnt <= frame_cnt - 1'b1;
    else
      if( !frame_read_finish && wr_done_posedge )
        frame_cnt <= frame_cnt + 1'b1;

axi4_to_axi4_stream #(
  .DATA_WIDTH     ( 64                            ),
  .ADDR_WIDTH     ( ADDR_WIDTH                    ),
  .MAX_PKT_SIZE_B ( BYTES_PER_LINE                )
) rd_dma (
  .clk_i          ( clk_i                         ),
  .rst_i          ( rst_i                         ),
  .pkt_size_i     ( ADDR_WIDTH'( BYTES_PER_LINE ) ),
  .addr_i         ( mem_addr                      ),
  .rd_stb_i       ( rd_req                        ),
  .pkt_o          ( video_line                    ),
  .mem_o          ( mem_rd                        )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64     ),
  .TID_WIDTH   ( 1      ),
  .TDEST_WIDTH ( 1      ),
  .TUSER_WIDTH ( 1      )
) video_line (
  .aclk        ( clk_i  ),
  .aresetn     ( !rst_i )
);

axi4_stream_fifo #(
  .TDATA_WIDTH   ( 64             ),
  .TID_WIDTH     ( 1              ),
  .TDEST_WIDTH   ( 1              ),
  .TUSER_WIDTH   ( 1              ),
  .WORDS_AMOUNT  ( FRAME_RES_X    ),
  .SMART         ( 1              )
) output_smart_fifo (
  .clk_i         ( clk_i         ),
  .rst_i         ( rst_i         ),
  .full_o        (               ),
  .empty_o       ( fifo_empty    ),
  .drop_o        (               ),
  .used_words_o  (               ),
  .pkts_amount_o ( lines_in_fifo ),
  .pkt_size_o    (               ),
  .pkt_i         ( video_line    ),
  .pkt_o         ( video_n_tuser )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_done_o <= 1'b0;
  else
    if( frame_read_finish )
      rd_done_o <= 1'b1;
    else
      if( rd_done_ack_posedge )
        rd_done_o <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_done_ack_d1 <= 1'b0;
  else
    rd_done_ack_d1 <= rd_done_ack_i;

assign rd_done_ack_posedge = rd_done_ack_i && !rd_done_ack_d1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_done_d1 <= 1'b0;
  else
    wr_done_d1 <= wr_done_i;

assign wr_done_posedge = wr_done_i && !wr_done_d1;
assign wr_done_negedge = !wr_done_i && wr_done_d1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_done_ack_o <= 1'b0;
  else
    if( wr_done_posedge )
      wr_done_ack_o <= 1'b1;
    else
      if( wr_done_negedge )
        wr_done_ack_o <= 1'b0;

axi4_stream_if #(
  .TDATA_WIDTH ( 64     ),
  .TID_WIDTH   ( 1      ),
  .TDEST_WIDTH ( 1      ),
  .TUSER_WIDTH ( 1      )
) video_n_tuser (
  .aclk        ( clk_i  ),
  .aresetn     ( !rst_i )
);

assign video_o.tdata  = video_n_tuser.tdata;
assign video_o.tvalid = video_n_tuser.tvalid;
assign viedo_o.tstrb  = video_n_tuser.tstrb;
assign video_o.tkeep  = video_n_tuser.tkeep;
assign video_o.tlast  = video_n_tuser.tlast;
assign video_o.tdest  = video_n_tuser.tdest;
assign video_o.tid    = video_n_tuser.tid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tuser <= 1'b1;
  else
    if( frame_read_finish )
      video_o.tuser <= 1'b1;
    else
      if( video_n_tuser.tvalid && video_n_tuser.tready )
        video_o.tuser <= 1'b0;

endmodule
