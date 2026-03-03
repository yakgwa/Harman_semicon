`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 14:13:27
// Design Name: 
// Module Name: ROM
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


module ROM(
    input logic [31:0] addr,
    output logic [31:0] data
    );

    logic [31:0] rom [0:2**8-1];

    initial begin
        // R - funct7, rs2, rs1, funct3, rd, opcode
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1
        rom[2] = 32'b0000000_00000_00011_111_00110_0110011; // and x6, x3, x0
        rom[3] = 32'b0000000_00000_00011_110_00111_0110011; // or x7, x3, x0
        // I - imm, rs1, funct3, rd, opcode
        rom[4] = 32'b000000000001_00001_000_01001_0010011; // addi x9, x1, 1
        rom[5] = 32'b000000000100_00010_111_01010_0010011; // andi x10, x2, 4
        rom[6] = 32'b000000000011_00001_001_01011_0010011; // slli x11, x1, 3
        // S - imm7, rs2, rs1, funct3, imm5, opcode
        rom[7] = 32'b0000000_00001_01100_000_00000_0100011; // sb x1, x12, 0
        rom[8] = 32'b0000000_00001_01101_001_00000_0100011; // sh x1, x13, 0
        rom[9] = 32'b0000000_00001_01110_010_00000_0100011; // sw x1, x14, 0
        rom[10] = 32'b0000000_00010_01111_010_00000_0100011; // sw x3, x15, 0
        rom[11] = 32'b0000000_00010_01111_010_00011_0100011; // sw x2, x15, 3
    end

    assign data = rom[addr[31:2]];

endmodule
