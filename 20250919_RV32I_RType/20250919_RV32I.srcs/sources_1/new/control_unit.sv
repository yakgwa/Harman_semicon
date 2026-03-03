`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 13:49:33
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control_unit(
    input logic [31:0] instr_opcode,
    output logic [3:0] controls,
    output logic wr_en
    );

    wire [3:0] operator = {instr_opcode[30], instr_opcode[14:12]};
    wire [6:0] opcode = instr_opcode[6:0];

    always_comb begin
        case(opcode)
            7'b0110011 : wr_en = 1'b1; // R-type에서 opcode가 0110011이면 다 나감
            default : wr_en = 1'b0;
        endcase
    
    end

    always_comb begin
        case(opcode)
            7'b0110011 : begin // R-type
                case({operator})
                    4'b0000 : controls = 4'b0000; // +
                    4'b1000 : controls = 4'b0001; // -
                    4'b0110 : controls = 4'b0010; // OR
                    4'b0111 : controls = 4'b0011; // AND
                    4'b0001 : controls = 4'b0100; // SLL
                    4'b0101 : controls = 4'b0101; // SRL
                    4'b1101 : controls = 4'b0110; // SRA
                    4'b0010 : controls = 4'b0111; // SLT
                    4'b0011 : controls = 4'b1000; // SLTU
                    4'b0100 : controls = 4'b1001; // XOR
                    default : controls = 4'bx;
                endcase
            end
            default : controls = 4'bx;
        endcase
    end
endmodule