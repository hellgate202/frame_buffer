module frame_wr_ctrl #(
  parameter int START_ADDR     = 0,
  parameter int FRAMES_AMOUNT  = 3,
  parameter int FRAME_RES_Y    = 1080,
  parameter int FRAME_RES_X    = 1920,
  parameter int ADDR_WIDTH     = 32,
  parameter int PKT_SIZE_WIDTH = $clog2( FRAME_RES_X ) + 3
)(
  input                       clk_i,
  input                       rst_i,
  input  [PKT_SIZE_WIDTH : 0] line_size_i,
  axi4_stream_if.slave        video_i,
  axi4_if.master              mem_wr,
  input                       rd_done_stb_i,
  output logic                wr_done_stb_o
);

localparam int WORDS_PER_LINE        = FRAME_RES_X % 4 ? FRAME_RES_X / 4 + 1 : FRAME_RES_X / 4;
localparam int WORDS_PER_FRAME       = WORDS_PER_LINE * FRAME_RES_Y;
localparam int BYTES_PER_LINE        = WORDS_PER_LINE * 8;
localparam int BYTES_PER_FRAME       = WORDS_PER_FRAME * 8;
localparam int LAST_FRAME_START_ADDR = START_ADDR + BYTES_PER_FRAME * ( FRAMES_AMOUNT - 1 );

localparam int FRAME_CNT_WIDTH       = $clog2( FRAMES_AMOUNT ) + 1;
localparam int LINE_CNT_WIDTH        = $clog2( FRAME_RES_Y ) + 1;

logic                           tvalid_lock;
logic [ADDR_WIDTH - 1 : 0]      mem_addr;
logic [ADDR_WIDTH - 1 : 0]      next_line_addr;
logic [ADDR_WIDTH - 1 : 0]      next_frame_addr;
logic [PKT_SIZE_WIDTH : 0]      line_size_lock;
logic                           rx_handshake;
logic                           ignore_frame;
logic [FRAME_CNT_WIDTH - 1 : 0] frame_cnt;
logic [LINE_CNT_WIDTH - 1 : 0]  line_cnt;
logic                           frame_end;

assign rx_handshake = video_i.tvalid && video_i.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( 64     ),
  .TID_WIDTH   ( 1      ),
  .TDEST_WIDTH ( 1      ),
  .TUSER_WIDTH ( 1      )
) pkt_i_d1 (
  .aclk        ( clk_i  ),
  .aresetn     ( !rst_i )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tvalid_lock <= 1'b0;
  else
    tvalid_lock <= video_i.tvalid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      pkt_i_d1.tdata  <= 64'd0;
      pkt_i_d1.tstrb  <= 8'd0;
      pkt_i_d1.tkeep  <= 8'd0;
      pkt_i_d1.tlast  <= 1'b0;
      pkt_i_d1.tuser  <= 1'b0;
      pkt_i_d1.tdest  <= 1'b0;
      pkt_i_d1.tid    <= 1'b0;
      line_size_lock  <= ( PKT_SIZE_WIDTH + 1 )'( 0 );
    end
  else
    if( video_i.tready )
      begin
        pkt_i_d1.tdata  <= video_i.tdata; 
        pkt_i_d1.tstrb  <= video_i.tstrb; 
        pkt_i_d1.tkeep  <= video_i.tkeep; 
        pkt_i_d1.tlast  <= video_i.tlast; 
        pkt_i_d1.tuser  <= video_i.tuser; 
        pkt_i_d1.tdest  <= video_i.tdest; 
        pkt_i_d1.tid    <= video_i.tid; 
        line_size_lock  <= line_size_i;
      end

assign pkt_i_d1.tvalid = tvalid_lock && !ignore_frame;

assign video_i.tready = pkt_i_d1.tready || !pkt_i_d1.tvalid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mem_addr <= ADDR_WIDTH'( START_ADDR );
  else
    if( rx_handshake )
      if( video_i.tuser )
        mem_addr <= next_frame_addr;
      else
        if( video_i.tlast )
          mem_addr <= next_line_addr;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    next_frame_addr <= ADDR_WIDTH'( START_ADDR );
  else
    if( rx_handshake && video_i.tuser )
      if( next_line_addr == ADDR_WIDTH'( LAST_FRAME_START_ADDR ) )
        next_frame_addr <= ADDR_WIDTH'( START_ADDR );
      else
        next_frame_addr <= next_frame_addr + ADDR_WIDTH'( BYTES_PER_FRAME );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    next_line_addr <= ADDR_WIDTH'( START_ADDR );
  else
    if( rx_handshake )
      if( video_i.tuser )
        next_line_addr <= next_frame_addr + ADDR_WIDTH'( BYTES_PER_LINE );
      else
        if( video_i.tlast )
          next_line_addr <= next_line_addr + ADDR_WIDTH'( BYTES_PER_LINE );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    line_cnt <= LINE_CNT_WIDTH'( 0 );
  else
    if( rx_handshake )
      if( video_i.tuser )
        line_cnt <= LINE_CNT_WIDTH'( 0 );
      else
        if( video_i.tlast && line_cnt < LINE_CNT_WIDTH'( FRAME_RES_Y ) )
          line_cnt <= line_cnt + 1'b1;

assign frame_end = rx_handshake && video_i.tuser && line_cnt > LINE_CNT_WIDTH'( 0 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    frame_cnt <= FRAME_CNT_WIDTH'( 0 );
  else
    if( frame_end && !rd_done_stb_i && frame_cnt != FRAME_CNT_WIDTH'( FRAMES_AMOUNT ) )
      frame_cnt <= frame_cnt + 1'b1;
    else
      if( !frame_end && rd_done_stb_i && frame_cnt > FRAME_CNT_WIDTH'( 1 ) )
        frame_cnt <= frame_cnt - 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ignore_frame <= 1'b0;
  else
    if( frame_end && frame_cnt == FRAME_CNT_WIDTH'( FRAMES_AMOUNT - 1 ) || line_cnt == LINE_CNT_WIDTH'( FRAME_RES_Y ) && !frame_end )
      ignore_frame <= 1'b1;
    else
      if( frame_end && frame_cnt != FRAME_CNT_WIDTH'( FRAMES_AMOUNT ) )
        ignore_frame <= 1'b0;

axi4_stream_to_axi4 #(
  .DATA_WIDTH     ( 64             ),
  .ADDR_WIDTH     ( ADDR_WIDTH     ),
  .MAX_PKT_SIZE_B ( BYTES_PER_LINE )
) wr_dma (
  .clk_i          ( clk_i          ),
  .rst_i          ( rst_i          ),
  .pkt_size_i     ( line_size_lock ),
  .addr_i         ( mem_addr       ),
  .pkt_i          ( pkt_i_d1       ),
  .mem_o          ( mem_wr         )
);

assign wr_done_stb_o = frame_end && frame_cnt != FRAME_CNT_WIDTH'( FRAMES_AMOUNT );

endmodule
