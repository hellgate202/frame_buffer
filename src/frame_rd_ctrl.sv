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
  output                rd_done_stb_o,
  input                 wr_done_stb_o
);

localparam int WORDS_PER_LINE        = FRAME_RES_X % 4 ? FRAME_RES_X / 4 + 1 : FRAME_RES_X / 4;
localparam int WORDS_PER_FRAME       = WORDS_PER_LINE * FRAME_RES_Y;
localparam int BYTES_PER_LINE        = WORDS_PER_LINE * 8;
localparam int BYTES_PER_FRAME       = WORDS_PER_FRAME * 8;
localparam int LAST_FRAME_START_ADDR = START_ADDR + BYTES_PER_FRAME * ( FRAMES_AMOUNT - 1 );

localparam int FRAME_CNT_WIDTH       = $clog2( FRAMES_AMOUNT ) + 1;
localparam int LINE_CNT_WIDTH        = $clog2( FRAME_RES_Y ) + 1;

axi4_to_axi4_stream #(
  .DATA_WIDTH     ( DATA_WIDTH     ),
  .ADDR_WIDTH     ( ADDR_WIDTH     ),
  .MAX_PKT_SIZE_B ( BYTES_PER_LINE )
) rd_dma (
  .clk_i          ( clk_i          ),
  .rst_i          ( rst_i          ),
  .pkt_size_i     ( BYTES_PER_LINE ),
  .addr_i         ( mem_addr       ),
  .rd_stb_i       ( rd_req         ),
  .pkt_o          ( video_line     ),
  .mem_o          ( mem_rd         )
);

endmodule
