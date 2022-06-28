
module uart_transmitter #(
  parameter CLOCK_FREQ = 125_000_000,
  parameter BAUD_RATE = 115_200
) (
  input clk,
  input rst,

  input [7:0] data_in,
  input data_in_valid,
  output data_in_ready,

  output serial_out
);

  localparam integer SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
  localparam CLK_COUNTER_WIDTH      = $clog2(SYMBOL_EDGE_TIME);

  wire symbol_edge = (clk_counter_out == SYMBOL_EDGE_TIME - 1);

  wire [9:0] table_out;
  wire [9:0] table_in = {1'b1, data_in, 1'b0};
    
  wire [3:0] bit_counter_out;
  wire [3:0] bit_counter_in = (bit_counter_out == 4'd9) ? 4'd9 : bit_counter_out + 1;

  wire [CLK_COUNTER_WIDTH-1:0] clk_counter_out;
  wire [CLK_COUNTER_WIDTH-1:0] clk_counter_in = clk_counter_out + 1;

  wire uart_status_out;
  reg uart_status_in;

  REGISTER_CE #(
    .N(10)
  ) tx_reg (
    .q(table_out),
    .d(table_in),
    .ce((data_in_valid & data_in_ready)),
    .clk(clk)
  );

  REGISTER_R_CE #(
    .N(4)
    ) bit_counter (
    .q(bit_counter_out),
    .d(bit_counter_in),
    .ce(symbol_edge),
    .rst(rst | (data_in_valid & data_in_ready)),
    .clk(clk)
  );

  REGISTER_R #(
    .N(CLK_COUNTER_WIDTH)
    ) clk_counter (
    .q(clk_counter_out),
    .d(clk_counter_in),
    .rst(rst | symbol_edge | (data_in_valid & data_in_ready)),
    .clk(clk)
  );

  REGISTER_R #(
    .N(1)
    ) uart_status (
    .d(uart_status_in),
    .q(uart_status_out),
    .clk(clk),
    .rst(rst)
  );

  always @(*) begin
    uart_status_in = uart_status_out;
    case (uart_status_out)
      1'b0: begin
        if ((data_in_valid & data_in_ready)) begin
          uart_status_in = 1'b1;
        end
      end
      1'b1: begin
        if (bit_counter_out == 4'd9 && symbol_edge) begin
          uart_status_in = 1'b0;
        end 
      end
    endcase
  end
    
  assign data_in_ready = (~uart_status_out) ? 1'b1 : 1'b0;
  assign serial_out = (~uart_status_out) ? 1'b1 : table_out[bit_counter_out];

endmodule