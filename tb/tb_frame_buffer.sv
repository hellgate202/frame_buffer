`include "../lib/axi4_lib/src/class/AXI4StreamMaster.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../lib/axi4_lib/src/class/AXI4MultiportMemory.sv"

module tb_frame_buffer;

parameter int ADDR_WIDTH    = 32;
parameter int DATA_WIDTH    = 64;
parameter int RANDOM_TVALID = 1;
parameter int RANDOM_TREADY = 1;
parameter int VERBOSE       = 0;
parameter int CLK_T         = 16000;

typedef bit [7 : 0] pkt_q [$];

bit          clk;
bit          rst;
bit [31 : 0] addr;
bit [13 : 0] pkt_size;
bit          rd_stb;

pkt_q tx_pkt;

mailbox rx_data_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( DATA_WIDTH ),
  .TID_WIDTH   ( 1          ),
  .TDEST_WIDTH ( 1          ),
  .TUSER_WIDTH ( 1          )
) pkt_i (
  .aclk        ( clk        ),
  .aresetn     ( !rst       )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DATA_WIDTH ),
  .TID_WIDTH   ( 1          ),
  .TDEST_WIDTH ( 1          ),
  .TUSER_WIDTH ( 1          )
) pkt_o (
  .aclk        ( clk        ),
  .aresetn     ( !rst       )
);

AXI4StreamMaster #(
  .TDATA_WIDTH    ( DATA_WIDTH     ),
  .TID_WIDTH      ( 1              ),
  .TDEST_WIDTH    ( 1              ),
  .TUSER_WIDTH    ( 1              ),
  .RANDOM_TVALID  ( RANDOM_TVALID  ),
  .VERBOSE        ( VERBOSE        ),
  .WATCHDOG_EN    ( 1'b1           ),
  .WATCHDOG_LIMIT ( 200            )
) pkt_sender;

AXI4StreamSlave #(
  .TDATA_WIDTH    ( DATA_WIDTH     ),
  .TID_WIDTH      ( 1              ),
  .TDEST_WIDTH    ( 1              ),
  .TUSER_WIDTH    ( 1              ),
  .RANDOM_TREADY  ( RANDOM_TREADY  ),
  .VERBOSE        ( VERBOSE        ),
  .WATCHDOG_EN    ( 1'b1           ),
  .WATCHDOG_LIMIT ( 200            )
) pkt_receiver;

axi4_if #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .ADDR_WIDTH ( ADDR_WIDTH )
) mem[1 : 0] (
  .aclk       ( clk        ),
  .aresetn    ( !rst       )
);

AXI4MultiportMemory #(
  .DATA_WIDTH    ( DATA_WIDTH ),
  .ADDR_WIDTH    ( ADDR_WIDTH ),
  .ID_WIDTH      ( 1          ),
  .RANDOM_WREADY ( 1          ),
  .RANDOM_RVALID ( 1          )
) memory;

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

axi4_stream_to_axi4 #(
  .DATA_WIDTH     ( DATA_WIDTH ),
  .ADDR_WIDTH     ( ADDR_WIDTH ),
  .MAX_PKT_SIZE_B ( 9600       )
) DUT_0 (
  .clk_i          ( clk        ),
  .rst_i          ( rst        ),
  .pkt_size_i     ( pkt_size   ),
  .addr_i         ( addr       ),
  .pkt_i          ( pkt_i      ),
  .mem_o          ( mem[0]     )
);

axi4_to_axi4_stream #(
  .DATA_WIDTH     ( DATA_WIDTH ),
  .ADDR_WIDTH     ( ADDR_WIDTH ),
  .MAX_PKT_SIZE_B ( 9600       )
) DUT_1 (
  .clk_i          ( clk        ),
  .rst_i          ( rst        ),
  .pkt_size_i     ( pkt_size   ),
  .addr_i         ( addr       ),
  .rd_stb         ( rd_stb     ),
  .pkt_o          ( pkt_o      ),
  .mem_o          ( mem[1]     )
);

initial
  begin
    pkt_sender   = new( .axi4_stream_if_v ( pkt_i ) );
    pkt_receiver = new( .axi4_stream_if_v ( pkt_o ),
                        .rx_data_mbx      ( rx_data_mbx ) );
    memory       = new( .axi4_if_v ( mem ) );
    fork
      clk_gen();
    join_none
    apply_rst();
    @( posedge clk );
    send_pkt( 2050, 32'h00fb100 );
    rd_stb = 1'b1;
    @( posedge clk );
    rd_stb = 1'b0;
    while( !pkt_o.tvalid || !pkt_o.tready || !pkt_o.tlast )
      @( posedge clk );
    repeat( 100 )
      @( posedge clk );
    $display( "Everything is fine." );
    $stop();
  end

endmodule
