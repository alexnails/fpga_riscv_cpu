
module fifo #(
  parameter WIDTH    = 32, // data width is 32-bit
  parameter LOGDEPTH = 3   // 2^3 = 8 entries
) (
  input clk,
  input rst,

  // Write interface (enqueue)
  input  enq_valid,
  input  [WIDTH-1:0] enq_data,
  output enq_ready,

  // Read interface (dequeue)
  output deq_valid,
  output [WIDTH-1:0] deq_data,
  input deq_ready
);

  wire [WIDTH-1:0] dummy_out; // prevent verilog warning 

  wire [LOGDEPTH-1:0] write_ptr_out;
  wire [LOGDEPTH-1:0] write_ptr_in = write_ptr_out + 1;

  wire write_end_out;
  wire write_end_in = (~(enq_ready && enq_valid && write_ptr_in))? ~write_end_out : write_end_out;

  wire [LOGDEPTH-1:0] read_ptr_out;
  wire [LOGDEPTH-1:0] read_ptr_in = read_ptr_out + 1;

  wire read_end_out;
  wire read_end_in = (~(deq_ready & deq_valid && read_ptr_in))? ~read_end_out : read_end_out;

  assign enq_ready = !(write_ptr_out == read_ptr_out && write_end_out != read_end_out);
  assign deq_valid = !(read_ptr_out == write_ptr_out && write_end_out == read_end_out);

  ASYNC_RAM_DP #(
    .WIDTH(WIDTH),
    .AWIDTH(LOGDEPTH)
  ) rw_fifo_port (
    .clk(clk),

    // Write
    .q0(dummy_out),
    .d0(enq_data),
    .addr0(write_ptr_out),
    .we0((enq_ready && enq_valid)),

    // Read
    .q1(deq_data),
    .d1(8'b0),
    .addr1(read_ptr_out),
    .we1(1'b0)
  );

  REGISTER_R_CE #(
    .N(LOGDEPTH)
    ) read_ptr  (
    .q(read_ptr_out),
    .d(read_ptr_in),
    .ce(deq_ready & deq_valid),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R_CE #(
    .N(LOGDEPTH)
    ) write_ptr (
    .q(write_ptr_out),
    .d(write_ptr_in),
    .ce(enq_ready && enq_valid),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R #(
    .N(1)
  ) write_end (
    .q(write_end_out),
    .d(write_end_in),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R #(
    .N(1)
  ) read_end (
    .q(read_end_out),
    .d(read_end_in),
    .rst(rst),
    .clk(clk)
  );

endmodule