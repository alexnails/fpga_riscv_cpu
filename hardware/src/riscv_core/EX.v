`include "Opcode.vh"

module EX #(
  parameter DWIDTH = 32,
  parameter INST_WIDTH = 32,
  parameter PC_WIDTH = 32
) (
  input clk,
  input [DWIDTH - 1:0] data_rs1,
  input [DWIDTH - 1:0] data_rs2,
  input [DWIDTH - 1:0] data_imm,
  input [PC_WIDTH - 1:0] data_pc,
  input [DWIDTH - 1:0] forward_data_in,
  input [3:0] ctrl_alu_func,
  input [1:0] ctrl_alu_op,
  input [1:0] ctrl_alu_src_a,
  input [1:0] ctrl_alu_src_b,
  input ctrl_forward_a_sel,
  input ctrl_forward_b_sel,

  input ctrl_csr_we,
  input [11:0] csr_addr,
  output [DWIDTH - 1:0] csr_data_out,
  output [DWIDTH - 1:0] csr_orig_data_out,  // the data written into csr
  output [DWIDTH - 1:0] alu_out
);

  reg [DWIDTH - 1:0] data_rs1_final, data_rs2_final;
  reg [DWIDTH - 1:0] alu_a_final, alu_b_final;

  always @(*) begin
    case (ctrl_alu_src_a)
      2'b00:   alu_a_final = data_rs1_final; 
      2'b10:   alu_a_final = data_pc;
      default: alu_a_final = data_rs1_final;
    endcase
  end

  always @(*) begin
    case (ctrl_alu_src_b)
      2'b00:   alu_b_final = data_rs2_final;
      2'b01:   alu_b_final = data_imm;
      2'b10:   alu_b_final = 32'd4;
      default: alu_b_final = data_rs2_final;
    endcase
  end

  always @(*) begin
    case (ctrl_forward_a_sel)
      1'b1: data_rs1_final = forward_data_in;
      default: data_rs1_final = data_rs1;
    endcase
  end

  always @(*) begin
    case (ctrl_forward_b_sel)
      1'b1: data_rs2_final = forward_data_in;
      default: data_rs2_final = data_rs2;
    endcase
  end

  wire [1:0] ctrl_alu_out_sel, ctrl_bitwise_sel, ctrl_shift_sel;
  wire ctrl_sub_less_sel, ctrl_slt_unsigned_sel;

  ALUCtrl alu_ctrl (
    .func(ctrl_alu_func),
    .alu_op(ctrl_alu_op),
    .ctrl_alu_out_sel(ctrl_alu_out_sel),
    .ctrl_bitwise_sel(ctrl_bitwise_sel),
    .ctrl_sub_less_sel(ctrl_sub_less_sel),
    .ctrl_shift_sel(ctrl_shift_sel),
    .ctrl_slt_unsigned_sel(ctrl_slt_unsigned_sel)
  );

  ALU #(
    .DWIDTH(DWIDTH)
  ) alu (
    .A(alu_a_final),
    .B(alu_b_final),
    .ctrl_alu_out_sel(ctrl_alu_out_sel),
    .ctrl_bitwise_sel(ctrl_bitwise_sel),
    .ctrl_sub_less_sel(ctrl_sub_less_sel),
    .ctrl_shift_sel(ctrl_shift_sel),
    .ctrl_slt_unsigned_sel(ctrl_slt_unsigned_sel),
    .out(alu_out)
  );


wire [DWIDTH-1:0] csr_data_in = (ctrl_alu_func[2])? data_imm:data_rs1_final;

ASYNC_RAM # (
    .DWIDTH(32),
    .AWIDTH(12)
) CSR (
    .clk(clk),
    .we(ctrl_csr_we),
    .addr(csr_addr),
    .d(csr_data_in),
    .q(csr_data_out)
);


  REGISTER_CE #(
    .N(DWIDTH)
  ) csr_orig_data_reg (
    .clk(clk),
    .ce (ctrl_csr_we),
    .d  (csr_data_in),
    .q  (csr_orig_data_out)
  );

endmodule
