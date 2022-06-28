
module debouncer #(
  parameter WIDTH              = 1,
  parameter SAMPLE_CNT_MAX     = 25000,
  parameter PULSE_CNT_MAX      = 150,
  parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX) + 1,
  parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
  input clk,
  input [WIDTH-1:0] glitchy_signal,
  output [WIDTH-1:0] debounced_signal
);

  reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0]; 
  wire [WRAPPING_CNT_WIDTH-1:0] wrapping_counter_out; 
  wire [WRAPPING_CNT_WIDTH-1:0] wrapping_counter_in = wrapping_counter_out + 1;
  wire sample_pulse_out;
  
  genvar i;
  generate
      for (i = 0; i < WIDTH; i = i + 1) begin
          initial begin
              saturating_counter[i] = 0;
          end
          assign debounced_signal[i] = saturating_counter[i] == PULSE_CNT_MAX;
          always @(posedge clk) begin //TODO :(
              if (!glitchy_signal[i]) begin
                  saturating_counter[i] <= 0;
              end
              else if (sample_pulse_out && glitchy_signal[i] && saturating_counter[i] < PULSE_CNT_MAX) begin
                  saturating_counter[i] <= saturating_counter[i] + 1;
              end
          end
      end
  endgenerate   

  REGISTER_R #(
    .N(1)
  ) wrap_counter (
    .q(wrapping_counter_out),
    .d(wrapping_counter_in),
    .rst(~(wrapping_counter_in < SAMPLE_CNT_MAX)),
    .clk(clk)
  );

  REGISTER_R #(
    .N(1)
  ) pulsar (
    .q(sample_pulse_out),
    .d(1),
    .rst((wrapping_counter_in < SAMPLE_CNT_MAX)),
    .clk(clk)
  );

  // wire sat_counter_in;
  // wire sat_counter_out;

  // assign sat_counter_in = sat_counter_out + 1;

  // REGISTER_R_CE #(
  //   .N(1)
  // ) sat_counter (
  //   .q(saturating_counter[i]),
  //   .d(wrapping_counter_in),
  //   .ce((sample_pulse_out && glitchy_signal[i] && saturating_counter[i] < PULSE_CNT_MAX))
  //   .rst(~(glitchy_signal[i])),
  //   .clk(clk)
  // );

endmodule