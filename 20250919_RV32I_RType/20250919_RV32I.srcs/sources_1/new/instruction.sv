`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 11:56:09
// Design Name: 
// Module Name: instruction
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


module instr_mem(
    input logic [31:0] rAddr,
   output logic [31:0] rData
    );

    logic [31:0] rom [0:63];

//     initial begin
//         rom[0] = 32'b0000000_00100_00011_000_00101_0110011;//32'h004182B3;//32'b0000000_00100_00011_000_00101_0110011; // add x5, x3, x4
//         rom[1] = 32'b0100_0000_1001_0100_0000_0011_1011_0011;//32'h409403B3;//32'b0100_0000_1001_0100_0000_0011_1011_0011; // sub x5, x3, x4
//     end

//     assign rData = rom[rAddr[31:2]];

// endmodule

    
    initial begin
        //rom[x] = 32'b func7 _ rs2 _ rs1 _ f3 _ rd _ opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; 
        //add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; 
        // OR x7, x9, x8
        rom[2] = 32'b0000000_01001_01000_110_00111_0110011;
        // sub x5, x2, x1
        rom[3] = 32'b0100000_00001_00010_000_00101_0110011;
        // AND x7, x9, x8
        rom[4] = 32'b0000000_01001_01000_111_00111_0110011;
        // XOR x7, x9, x8
        rom[5] = 32'b0000000_01001_01000_100_00111_0110011;
        // SLT x5, x2, x1
        rom[6] = 32'b0000000_00001_00010_010_00101_0110011;
        // SLL x6, x2, x1
        rom[7] = 32'b0000000_00001_00010_001_00101_0110011;
        // SRL x9, x2, x1
        rom[8] = 32'b0000000_00001_00010_101_00101_0110011;
        // SLTU x5, x2, x1
        rom[9] = 32'b0000000_00001_00010_011_00101_0110011;
    end

    assign rData = rom[rAddr[31:2]]; //rom의 0번 1번을 지움, 4의 배수로 맞추기 위해
endmodule