module axi4_to_axi4_stream #(
  parameter int DATA_WIDTH         = 64,
  parameter int ADDR_WIDTH         = 32,
  parameter int ID_WIDTH           = 1,
  parameter int AWUSER_WIDTH       = 1,
  parameter int WUSER_WIDTH        = 1,
  parameter int ARUSER_WIDTH       = 1,
  parameter int TUSER_WIDTH        = 1,
  parameter int TDEST_WIDTH        = 1,
  parameter int MAX_PKT_SIZE_B     = 2048,
  parameter int MAX_PKT_SIZE_WIDTH = $clog2( MAX_PKT_SIZE_B * 4 )
)(
  input                           clk_i,
  input                           rst_i,
  input [MAX_PKT_SIZE_WIDTH : 0]  pkt_size_i,
  input [ADDR_WIDTH - 1 : 0]      addr_i,
  input                           rd_stb_i,
  axi4_stream_if.master           pkt_o,
  axi4_if.master                  mem_o
);

localparam int DATA_WIDTH_B   = DATA_WIDTH / 8;
localparam int ADDR_WORD_BITS = $clog2( DATA_WIDTH_B );

logic                          r_handshake;
logic                          ar_handshake;
logic [MAX_PKT_SIZE_WIDTH : 0] pkt_words_left;
logic [7 : 0]                  burst_words_left;
logic [ADDR_WIDTH - 1 : 0]     cur_addr;
logic                          was_ar_handshake;
logic [DATA_WIDTH_B - 1 : 0]   tlast_tstrb;

enum logic [1 : 0] { IDLE_S,
                     CALC_BURST_S,
                     BURST_IN_PROGRESS_S,
                     WAIT_ADDR_HANDSHAKE_S } state, next_state;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( rd_stb_i )
            next_state = CALC_BURST_S;
        end
      CALC_BURST_S:
        begin
          next_state = BURST_IN_PROGRESS_S;
        end
      BURST_IN_PROGRESS_S:
        begin
          if( burst_words_left == 8'd0 && r_handshake )
            if( ar_handshake || was_ar_handshake )
              if( pkt_words_left == MAX_PKT_SIZE_WIDTH'( 1 ) )
                next_state = IDLE_S;
              else
                next_state = CALC_BURST_S;
            else
              next_state = WAIT_ADDR_HANDSHAKE_S;
        end
      WAIT_ADDR_HANDSHAKE_S:
        begin
          if( ar_handshake )
            if( pkt_words_left == MAX_PKT_SIZE_WIDTH'( 1 ) )
              next_state = IDLE_S;
            else
              next_state = CALC_BURST_S;
        end
    endcase
  end

assign r_handshake  = mem_o.rvalid && mem_o.rready;
assign ar_handshake = mem_o.arvalid && mem_o.arready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    was_ar_handshake <= 1'b0;
  else
    if( state != BURST_IN_PROGRESS_S )
      was_ar_handshake <= 1'b0;
    else
      if( state == BURST_IN_PROGRESS_S && ar_handshake )
        was_ar_handshake <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    pkt_words_left <= MAX_PKT_SIZE_WIDTH'( 0 );
  else
    if( state == IDLE_S && rd_stb_i )
      if( pkt_size_i[ADDR_WORD_BITS - 1 : 0] )
        pkt_words_left <= pkt_size_i[MAX_PKT_SIZE_WIDTH - 1 : ADDR_WORD_BITS] + 1'b1;
      else
        pkt_words_left <= pkt_size_i[MAX_PKT_SIZE_WIDTH - 1 : ADDR_WORD_BITS];
    else
      if( r_handshake )
        pkt_words_left <= pkt_words_left - 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tlast_tstrb <= DATA_WIDTH_B'( 0 );
  else
    if( state == IDLE_S && rd_stb_i )
      if( pkt_size_i[ADDR_WORD_BITS - 1 : 0] == ADDR_WORD_BITS'( 0 ) )
        tlast_tstrb <= DATA_WIDTH_B'( 2 ** DATA_WIDTH_B - 1 );
      else
        for( int i = 0; i < DATA_WIDTH_B; i++ )
          if( ADDR_WORD_BITS'( i ) < pkt_size_i[ADDR_WORD_BITS - 1 : 0] )
            tlast_tstrb[i] <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    burst_words_left <= 8'd0;
  else
    if( state == CALC_BURST_S )
      if( pkt_words_left > MAX_PKT_SIZE_WIDTH'( 256 ) )
        burst_words_left <= 8'd255;
      else
        burst_words_left <= pkt_words_left[7 : 0] - 1'b1;
    else
      if( r_handshake )
        burst_words_left <= burst_words_left - 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_addr <= ADDR_WIDTH'( 0 );
  else
    if( state == IDLE_S && rd_stb_i )
      cur_addr <= { addr_i[ADDR_WIDTH - 1 : ADDR_WORD_BITS], ADDR_WORD_BITS'( 0 ) };
    else
      if( r_handshake )
        cur_addr <= cur_addr + ADDR_WIDTH'( DATA_WIDTH_B );

always_ff @( posedge clk_i, posedge rst_i )
  if ( rst_i )
    mem_o.araddr <= ADDR_WIDTH'( 0 );
  else
    if( state == CALC_BURST_S )
      mem_o.araddr <= cur_addr;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mem_o.arlen <= 8'd0;
  else
    if( state == CALC_BURST_S )
      if( pkt_words_left > MAX_PKT_SIZE_WIDTH'( 256 ) )
        mem_o.arlen <= 8'd255;
      else
        mem_o.arlen <= pkt_words_left[7 : 0] - 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mem_o.arvalid <= 1'b0;
  else
    if( state == CALC_BURST_S )
      mem_o.arvalid <= 1'b1;
    else
      if( mem_o.arready )
        mem_o.arvalid <= 1'b0;

assign mem_o.awid     = ID_WIDTH'( 0 );
assign mem_o.awaddr   = ADDR_WIDTH'( 0 );
assign mem_o.awlen    = 8'd0;
assign mem_o.awsize   = 3'( $clog2( DATA_WIDTH_B ) );
assign mem_o.awburst  = 2'b01;
assign mem_o.awlock   = 1'b0;
assign mem_o.awcache  = 4'd0;
assign mem_o.awprot   = 3'd0;
assign mem_o.awqos    = 4'd0;
assign mem_o.awregion = 4'd0;
assign mem_o.awuser   = AWUSER_WIDTH'( 0 );
assign mem_o.awvalid  = 1'b0;
assign mem_o.wdata    = DATA_WIDTH'( 0 );
assign mem_o.wstrb    = DATA_WIDTH_B'( 0 );
assign mem_o.wlast    = 1'b0;
assign mem_o.wuser    = WUSER_WIDTH'( 0 );
assign mem_o.wvalid   = 1'b0;
assign mem_o.bready   = 1'b1;
assign mem_o.arid     = ID_WIDTH'( 0 );
assign mem_o.arsize   = 3'( $clog2( DATA_WIDTH_B ) );
assign mem_o.arburst  = 2'b01;
assign mem_o.arlock   = 1'b0;
assign mem_o.arcache  = 4'd0;
assign mem_o.arprot   = 3'd0;
assign mem_o.arqos    = 4'd0;
assign mem_o.arregion = 4'd0;
assign mem_o.aruser   = ARUSER_WIDTH'( 0 );
assign mem_o.rready   = pkt_o.tready;

assign pkt_o.tdata  = mem_o.rdata;
assign pkt_o.tstrb  = pkt_o.tlast ? tlast_tstrb : DATA_WIDTH_B'( 2 ** DATA_WIDTH_B - 1 );
assign pkt_o.tkeep  = pkt_o.tlast ? tlast_tstrb : DATA_WIDTH_B'( 2 ** DATA_WIDTH_B - 1 );
assign pkt_o.tvalid = mem_o.rvalid;
assign pkt_o.tlast  = pkt_words_left == MAX_PKT_SIZE_WIDTH'( 1 );
assign pkt_o.tid    = ID_WIDTH'( 0 );
assign pkt_o.tdest  = TDEST_WIDTH'( 0 );
assign pkt_o.tuser  = TUSER_WIDTH'( 0 );

endmodule
