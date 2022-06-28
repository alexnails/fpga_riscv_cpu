`include "Opcode.vh"
`timescale 1ns/1ns

module BranchComp #(
	parameter WIDTH = 32
) (
	input [WIDTH-1:0] rs1, 
	input [WIDTH-1:0] rs2, 
	input [2:0] func3,
	output reg taken
	);


	wire beq, blt, bltu;
	assign beq = $signed(rs1) == $signed(rs2);
	assign blt = $signed(rs1) < $signed(rs2);
	assign bltu = rs1 < rs2;

	always@(*) begin
		case(func3)
			`FNC_BEQ: 	taken = beq;
			`FNC_BNE: 	taken = ~(beq);
			`FNC_BLT: 	taken = blt;
			`FNC_BGE: 	taken = ~(blt);
			`FNC_BLTU: 	taken = bltu;
			`FNC_BGEU: 	taken = ~(bltu);
			default:	taken = 1'b0;
		endcase
	end

endmodule
