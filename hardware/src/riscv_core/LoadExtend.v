`include "Opcode.vh"

module LoadExtend #(
    parameter WIDTH = 32
) (
    input [WIDTH - 1:0] data_in,
    input [2:0] func3,
    input [1:0] alu_offset,
    output reg [WIDTH - 1:0] data_out
);
    always@(*) begin
        case(func3)
            `FNC_LB: begin
                case(alu_offset)
                    2'd0:	data_out = {{24{data_in[7]}},data_in[7:0]};
                    2'd1:	data_out = {{24{data_in[15]}},data_in[15:8]};
                    2'd2:	data_out = {{24{data_in[23]}},data_in[23:16]};
                    2'd3:	data_out = {{24{data_in[31]}},data_in[31:24]};
                endcase
            end	
            `FNC_LH: begin
                case(alu_offset)
                    2'd0:	data_out = {{16{data_in[15]}},data_in[15:0]};
                    2'd1:	data_out = {{16{data_in[23]}},data_in[15:0]};
                    2'd2:	data_out = {{16{data_in[31]}},data_in[31:16]};
                    2'd3:	data_out = {{16{data_in[31]}},data_in[31:16]};
                endcase
            end	
            `FNC_LW: begin
                data_out = data_in;
            end	
            `FNC_LBU: begin
                case(alu_offset)
                    2'd0:	data_out = {{24{1'd0}},data_in[7:0]};
                    2'd1:	data_out = {{24{1'd0}},data_in[15:8]};
                    2'd2:	data_out = {{24{1'd0}},data_in[23:16]};
                    2'd3:	data_out = {{24{1'd0}},data_in[31:24]};
                endcase
            end	
            `FNC_LHU: begin
                case(alu_offset)
                    2'd0:	data_out = {{16{1'd0}},data_in[15:0]};
                    2'd1:	data_out = {{16{1'd0}},data_in[15:0]};
                    2'd2:	data_out = {{16{1'd0}},data_in[31:16]};
                    2'd3:	data_out = {{16{1'd0}},data_in[31:16]};
                endcase
            end	
            default: data_out=data_in;
        endcase
    end
endmodule