`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 10:48:51
// Design Name: 
// Module Name: gates
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


module gates(
    input a, b,
    output z0, z1, z2, z3, z4, z5, z6
);

assign z0 = a & b; // AND
assign z1 = ~(a & b); // NAND
assign z2 = a | b; // OR
assign z3 = ~(a | b); // NOR
assign z4 = a ^ b; // XOR
assign z5 = ~(a ^ b); // XNOR
assign z6 = ~a;

endmodule 
