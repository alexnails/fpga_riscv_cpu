`include "Opcode.vh"

module StoreMask #(
    parameter WIDTH = 32
) (
    input [WIDTH - 1:0] data_in,
    input [1:0] alu_offset,
    input [2:0] func3,
    output reg [3:0] wea,
    output reg [WIDTH - 1:0] data_out
);

    always @(*) begin
        // latch prevention and base case two for 1 instead of default statements
        case (func3)
        `FNC_SW: begin 
            wea = 4'b1111;
            data_out = data_in;
        end
        `FNC_SH: begin
            case (alu_offset)
            2'b00: begin
                wea = 4'b0011;
                data_out = {{16{1'b0}}, data_in[15:0]};
            end
            2'b01: begin
                wea = 4'b0011;
                data_out = {{16{1'b0}}, data_in[15:0]};
            end
            2'b10: begin
                wea = 4'b1100;
                data_out = {data_in[15:0], {16{1'b0}}};
            end
            2'b11: begin
                wea = 4'b1100;
                data_out = {data_in[15:0], {16{1'b0}}};
            end
            endcase
        end
        `FNC_SB: begin
            case (alu_offset)
            2'b00: begin
                wea = 4'b0001;
                data_out = {{24{1'b0}}, data_in[7:0]};
            end
            2'b01: begin
                wea = 4'b0010;
                data_out = {{16{1'b0}}, data_in[7:0], {8{1'b0}}};
            end
            2'b10: begin
                wea = 4'b0100;
                data_out = {{8{1'b0}}, data_in[7:0], {16{1'b0}}};
            end
            2'b11: begin
                wea = 4'b1000;
                data_out = {data_in[7:0], {24{1'b0}}};
            end
            endcase
        end
        endcase
    end
endmodule
 