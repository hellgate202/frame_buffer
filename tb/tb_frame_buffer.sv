module tb_frame_buffer;

parameter int RANDOM_TVALID = 1;
parameter int RANDOM_TREADY = 1;
parameter int VERBOSE       = 0;
parameter int CLK_T         = 16000;

typedef bit [7 : 0] pkt_q [$];

bit clk;
bit rst;

pkt_q tx_pkt;

mailbox rx_data_mbx  = new();
mailbox ref_data_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( 16   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) pkt_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 16   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) pkt_i_64 (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

AXI4StreamMaster #(
  .TDATA_WIDTH    ( 16             ),
  .TID_WIDTH      ( 1              ),
  .TDEST_WIDTH    ( 1              ),
  .TUSER_WIDTH    ( 1              ),
  .RANDOM_TVALID  ( RANDOM_TVALID  ),
  .VERBOSE        ( VERBOSE        ),
  .WATCHDOG_EN    ( 1'b1           ),
  .WATCHDOG_LIMIT ( 200            )
) pkt_sender;

AXI4StreamSlave #(
  .TDATA_WIDTH    ( 64            ),
  .TID_WIDTH      ( 1             ),
  .TDEST_WIDTH    ( 1             ),
  .TUSER_WIDTH    ( 1             ),
  .RANDOM_TREADY  ( RANDOM_TREADY ),
  .VERBOSE        ( VERBOSE       ),
  .WATCHDOG_EN    ( 1'b1          ),
  .WATCHDOG_LIMIT ( 200           )
) pkt_receiver;

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

function automatic pkt_q generate_pkt( int size ); 

  pkt_q pkt;

  for( int i = 0; i < size; i++ )
    pkt.push_back( $urandom_range( 255, 0 ) );

  return pkt;

endfunction

task automatic compare_mbx();

  pkt_q rx_pkt;
  pkt_q ref_pkt;

  fork
    forever
      begin
        if( rx_data_mbx.num() > 0 && ref_data_mbx.num() > 0 )
          begin
            rx_data_mbx.get( rx_pkt );
            ref_data_mbx.get( ref_pkt );
            if( rx_pkt != ref_pkt )
              begin
                $display( "Packet missmatch!" );
                $display( "Received packet:" );
                for( int i = 0; i < rx_pkt.size(); i++ )
                  $write( "%0h ", rx_pkt[i] );
                $write( "\n" );
                $display( "Reference packet:" );
                for( int i = 0; i < ref_pkt.size(); i++ )
                  $write( "%0h ", ref_pkt[i] );
                $write( "\n" );
                $stop();
              end
          end
        else
          @( posedge clk );
      end
  join_none

endtask

axi4_stream_16b_64b_gbx DUT
(
  .clk_i ( clk      ),
  .rst_i ( rst      ),
  .pkt_i ( pkt_i    ),
  .pkt_o ( pkt_i_64 )
);

initial
  begin
    pkt_sender   = new( .axi4_stream_if_v ( pkt_i ) );
    pkt_receiver = new( .axi4_stream_if_v ( pkt_i_64    ),
                        .rx_data_mbx      ( rx_data_mbx ) );
    fork
      clk_gen();
    join_none
    compare_mbx();
    apply_rst();
    @( posedge clk );
    repeat( 1000 )
      begin
        tx_pkt = generate_pkt( $urandom_range( 24, 1 ) );
        ref_data_mbx.put( tx_pkt );
        pkt_sender.tx_data( tx_pkt );
      end
    repeat( 10 )
      @( posedge clk );
    $dispaly( "Everything is fine." );
    $stop();
  end

endmodule
