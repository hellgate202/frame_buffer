`include "../lib/axi4_lib/src/class/AXI4StreamMaster.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../lib/axi4_lib/src/class/AXI4Slave.sv"

module tb_frame_buffer;

parameter int RANDOM_TVALID = 1;
parameter int RANDOM_TREADY = 1;
parameter int VERBOSE       = 0;
parameter int CLK_T         = 16000;

typedef bit [7 : 0] pkt_q [$];

bit clk;
bit rst;
bit [31 : 0] addr;
bit [13 : 0] pkt_size;

pkt_q tx_pkt;

axi4_stream_if #(
  .TDATA_WIDTH ( 64   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) pkt_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

AXI4StreamMaster #(
  .TDATA_WIDTH    ( 64             ),
  .TID_WIDTH      ( 1              ),
  .TDEST_WIDTH    ( 1              ),
  .TUSER_WIDTH    ( 1              ),
  .RANDOM_TVALID  ( RANDOM_TVALID  ),
  .VERBOSE        ( VERBOSE        ),
  .WATCHDOG_EN    ( 1'b1           ),
  .WATCHDOG_LIMIT ( 200            )
) pkt_sender;

axi4_if #(
  .DATA_WIDTH ( 64   ),
  .ADDR_WIDTH ( 32   )
) burst_o (
  .aclk       ( clk  ),
  .aresetn    ( !rst )
);

AXI4Slave #(
  .DATA_WIDTH    ( 64 ),
  .ADDR_WIDTH    ( 32 ),
  .ID_WIDTH      ( 1  ),
  .RANDOM_WREADY ( 1  )
) mem;

task automatic clk_gen();

  forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end

endtask

task automatic apply_rst();

  @( posedge clk );
  rst = 1'b1;
  @( posedge clk );
  rst = 1'b0;

endtask

task automatic send_pkt( int size, int start_addr );
  
  bit [7 : 0] pkt [$];
  for( int i = 0; i < size; i++ )
    pkt.push_back( i % 256 );
  addr     = start_addr;
  pkt_size = size;
  pkt_sender.tx_data( pkt );

endtask

axi4_stream_to_axi4_burst #(
  .DATA_WIDTH     ( 64       ),
  .ADDR_WIDTH     ( 32       ),
  .MAX_PKT_SIZE_B ( 9600     )
) DUT (
  .clk_i          ( clk      ),
  .rst_i          ( rst      ),
  .pkt_size_i     ( pkt_size ),
  .addr_i         ( addr     ),
  .pkt_i          ( pkt_i    ),
  .burst_o        ( burst_o  )
);

initial
  begin
    pkt_sender = new( .axi4_stream_if_v ( pkt_i ) );
    mem        = new( .axi4_if_v ( burst_o ) );
    fork
      clk_gen();
    join_none
    apply_rst();
    @( posedge clk );
    send_pkt( 2049, 32'h00fb100 );
    repeat( 100 )
      @( posedge clk );
    $display( "Everything is fine." );
    $stop();
  end

endmodule
