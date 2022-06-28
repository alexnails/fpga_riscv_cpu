module ImmGen #(
    parameter WIDTH = 32
) (
    input [WIDTH - 1:0] inst,
    output reg [WIDTH - 1:0] imm
);

	wire [6:0] opcode = inst[6:0];

	always @(*) begin
		case (opcode)
			`OPC_STORE: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
			`OPC_BRANCH: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
			`OPC_LUI: imm = {inst[31:12], {12{1'b0}}}; // tradeoff ==> immsel condenses lui and auipc but less op w current way since
			`OPC_AUIPC: imm = {inst[31:12], {12{1'b0}}}; // case less (maybe? will test this) 
			`OPC_JAL: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};  
			`OPC_CSR: imm = {{27{1'b0}}, inst[19:15]}; //7'b1110011
			default: imm = {{20{inst[31]}}, inst[31:20]}; //jalr ari load ; possibly unsafe given high ! of bits
		endcase
	end
endmodule