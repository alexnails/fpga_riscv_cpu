`timescale 1ns/1ns

module synchronizer #(parameter WIDTH = 1) (
  input [WIDTH-1:0] async_signal,
  input clk,
  output [WIDTH-1:0] sync_signal
);

  wire [WIDTH-1: 0] intermediate;
  
  REGISTER #(
    .N(WIDTH)
    ) i (
    .d(async_signal),
    .q(intermediate),
    .clk(clk)
  );

  REGISTER #(
    .N(WIDTH)
    ) o (
    .d(intermediate),
    .q(sync_signal),
    .clk(clk)
  );

endmodule