`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 13:41:10
// Design Name: 
// Module Name: ControlUnit
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
`include "defines.sv"

module ControlUnit(
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic aluSrcMuxSel,
    output logic [3:0] aluControl,
    output logic [2:0] strb,
    output logic buswe
    );

    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};

    logic [2:0] signals;
    
    assign {regFileWe, aluSrcMuxSel, buswe} = signals;
    assign strb = instrCode[14:12];

    always_comb begin
        signals = 3'b0_0_0;
        case(opcode)
            `OP_TYPE_R : signals = 3'b1_0_0;
            `OP_TYPE_I : signals = 3'b1_1_0;
            `OP_TYPE_S : signals = 3'b0_1_1;
        endcase
    end

    always_comb begin
        aluControl = `ADD;
        case(opcode)
            `OP_TYPE_R : aluControl = operator;
            `OP_TYPE_I : begin
                if(operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
            end
            `OP_TYPE_S : aluControl = `ADD;
        endcase
    end


endmodule

// module ControlUnit(
//     input logic [31:0] instrCode,
//     output logic regFileWe,
//     output logic aluSrcMuxSel,
//     output logic [3:0] aluControl
//     );

//     wire [6:0] opcode = instrCode[6:0];
//     wire [3:0] operator = {instrCode[30], instrCode[14:12]};

//     logic [1:0] signals;
    
//     assign {regFileWe, aluSrcMuxSel} = signals;

//     always_comb begin
//         signals = 2'b0_0;
//         case(opcode)
//             `OP_TYPE_R : signals = 2'b1_0;
//             `OP_TYPE_I : signals = 2'b1_1;
//         endcase
//     end

//     always_comb begin
//         aluControl = `ADD;
//         case(opcode)
//             `OP_TYPE_R : aluControl = operator;
//             `OP_TYPE_I : begin
//                 if(operator == 4'b1101) aluControl = operator;
//                 else aluControl = {1'b0, operator[2:0]};
//             end
//         endcase
//     end

// endmodule
