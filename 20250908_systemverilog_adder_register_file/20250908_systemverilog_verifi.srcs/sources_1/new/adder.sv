`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 10:38:08
// Design Name: 
// Module Name: adder
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


module adder(
    input logic [7:0] a,
    input logic [7:0] b,
    input logic mode,
    output logic [7:0] sum,
    output logic carry
    );

    always_comb begin 
        case(mode)
            1'b0: {carry, sum} = a + b;
            1'b1: {carry, sum} = a - b;
        endcase    
    end
endmodule
