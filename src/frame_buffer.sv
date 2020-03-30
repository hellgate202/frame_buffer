module frame_buffer #(
  parameter int START_ADDR    = 0,
  parameter int FRAMES_AMOUNT = 3,
  parameter int FRAME_RES_Y   = 1080,
  parameter int FRAME_RES_X   = 1920
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
axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) video_64_i (
  .aclk        ( wr_clk_i  ),
  .aresetn     ( !wr_rst_i )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 64        ),
  .TID_WIDTH   ( 1         ),
  .TDEST_WIDTH ( 1         ),
  .TUSER_WIDTH ( 1         )
) video_64_o (
  .aclk        ( wr_clk_i  ),
  .aresetn     ( !wr_rst_i )
);

axi4_stream_16b_64b_gbx video_des
(
  .clk_i ( wr_clk_i ),
  .rst_i ( wr_rst_i ),
  .pkt_i ( video_i  ),
  .pkt_o ( video_64 )
);

logic [31 : 0] line_size;
logic          rd_done_rd_clk;
logic          rd_done_wr_clk_sync;
logic          rd_done_wr_clk;
logic          wr_done_rd_clk;
logic          wr_done_wr_clk_sync;
logic          wr_done_wr_clk;
logic          rd_done_ack_rd_clk;
logic          rd_done_ack_wr_clk_sync;
logic          rd_done_ack_wr_clk;
logic          wr_done_ack_rd_clk;
logic          wr_done_ack_wr_clk_sync;
logic          wr_done_ack_wr_clk;
logic          rd_done;
logic          rd_done_ack;
logic          wr_done;
logic          wr_done_ack;

always_ff @( posedge rd_clk_i, posedge rd_rst_i )
  if( rd_rst_i )
    rd_done_rd_clk <= 1'b0;
  else
    rd_done_rd_clk <= rd_done;

always_ff @( posedge wr_clk_i, posedge wr_rst_i )
  if( wr_rst_i )
    begin
      rd_done_wr_clk_sync <= 1'b0;
      rd_done_wr_clk      <= 1'b0;
    end
  else
    begin
      rd_done_wr_clk_sync <= rd_done_rd_clk;
      rd_done_wr_clk      <= rd_done_wr_clk_sync;
    end

always_ff @( posedge rd_clk_i, posedge rd_rst_i )
  if( rd_rst_i )
    wr_done_ack_rd_clk <= 1'b0;
  else
    wr_done_ack_rd_clk <= wr_done_ack;

always_ff @( posedge wr_clk_i, posedge wr_rst_i )
  if( wr_rst_i )
    begin
      wr_done_ack_wr_clk_sync <= 1'b0;
      wr_done_ack_wr_clk      <= 1'b0;
    end
  else
    begin
      wr_done_ack_wr_clk_sync <= wr_done_ack_rd_clk;
      wr_done_ack_wr_clk      <= wr_done_ack_wr_clk_sync;
    end

always_ff @( posedge wr_clk_i, posedge wr_rst_i )
  if( wr_rst_i )
    wr_done_wr_clk <= 1'b0;
  else
    wr_done_wr_clk <= wr_done;

always_ff @( posedge rd_clk_i, posedge rd_rst_i )
  if( rd_rst_i )
    begin
      wr_done_rd_clk_sync <= 1'b0;
      wr_done_rd_clk      <= 1'b0;
    end
  else
    begin
      wr_done_rd_clk_sync <= wr_done_wr_clk;
      wr_done_rd_clk      <= wr_done_rd_clk_sync;
    end

always_ff @( posedge wr_clk_i, posedge wr_rst_i )
  if( wr_rst_i )
    rd_done_ack_wr_clk <= 1'b0;
  else
    rd_done_ack_wr_clk <= rd_done_ack;

always_ff @( posedge rd_clk_i, posedge rd_rst_i )
  if( rd_rst_i )
    begin
      rd_done_ack_rd_clk_sync <= 1'b0;
      rd_done_ack_rd_clk      <= 1'b0;
    end
  else
    begin
      rd_done_ack_rd_clk_sync <= rd_done_ack_wr_clk;
      rd_done_ack_rd_clk      <= rd_done_ack_rd_clk_sync;
    end

axi4_stream_fifo #(
  .TDATA_WIDTH   ( 64             ),
  .TUSER_WIDTH   ( 1              ),
  .TDEST_WIDTH   ( 1              ),
  .TID_WIDTH     ( 1              ),
  .WORDS_AMOUNT  ( FRAME_RES_X    ),
  .SMART         ( 1              ),
  .SHOW_PKT_SIZE ( 1              )
) input_filter_fifo (
  .clk_i         ( wr_clk_i       ),
  .rst_i         ( wr_rst_i       ),
  .full_o        (                ),
  .empty_o       (                ),
  .drop_o        (                ),
  .used_words_o  (                ),
  .pkts_amount_o (                ),
  .pkt_size      ( line_size      ),
  .pkt_i         ( video_64_i     ),
  .pkt_o         ( flitered_video )
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

frame_wr_ctrl #(
  .START_ADDR    ( START_ADDR         ),
  .FRAMES_AMOUNT ( FRAMES_AMOUNT      ),
  .FRAME_RES_Y   ( FRAME_RES_Y        ),
  .FRAME_RES_X   ( FRAME_RES_X        ),
  .ADDR_WIDTH    ( 32                 )
) wr_ctrl (
  .clk_i         ( wr_clk_i           ),
  .rsr_i         ( wr_rst_i           ),
  .line_size_i   ( line_size          ),
  .video_i       ( filtered_video     ),
  .mem_wr        ( mem_wr             ),
  .rd_done_i     ( rd_done_wr_clk     ),
  .rd_done_ack_o ( rd_done_ack        ),
  .wr_done_o     ( wr_done            ),
  .wr_done_ack_i ( wr_done_ack_wr_clk )
);

frame_rd_ctrl #(
  .START_ADDR    ( START_ADDR         ),
  .FRAMES_AMOUNT ( FRAMES_AMOUNT      ),
  .FRAME_RES_Y   ( FRAME_RES_Y        ),
  .FRAME_RES_X   ( FRAME_RES_X        ),
  .ADDR_WIDTH    ( 32                 )
) rd_ctrl (
  .clk_i         ( rd_clk_i           ),
  .rst_i         ( rd_rst_i           ),
  .video_o       ( video_64_o         ),
  .mem_rd        ( mem_rd             ),
  .rd_done_o     ( rd_done            ),
  .rd_done_ack_i ( rd_done_ack_rd_clk ),
  .wr_done_i     ( wr_done_rd_clk     ),
  .wr_done_ack_o ( wr_done_ack        )
);

axi4_stream_64b_16b_gbx video_ser
(
  .clk_i ( rd_clk_i   ),
  .rst_i ( rd_rst_i   ),
  .pkt_i ( video_64_o ),
  .pkt_o ( video_o    )
);

endmodule
