
`timescale 1ns/1ns

module edge_detector #(
  parameter WIDTH = 1
)(
  input clk,
  input [WIDTH-1:0] signal_in,
  output [WIDTH-1:0] edge_detect_pulse
);
  wire [WIDTH - 1: 0] prev;
  wire [WIDTH - 1: 0] out;

  genvar i;
  generate for(i = 0; i < WIDTH; i = i + 1) begin
    REGISTER i (
      .d(signal_in[i]),
      .q(prev[i]),
      .clk(clk)
    );

    REGISTER o (
      .d(prev[i]),
      .q(out[i]),
      .clk(clk)
    );
    assign edge_detect_pulse[i] = prev[i] & ~out[i];
  end
  endgenerate
endmodule