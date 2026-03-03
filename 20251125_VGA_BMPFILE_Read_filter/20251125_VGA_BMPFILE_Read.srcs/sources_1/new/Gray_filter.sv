`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 15:03:52
// Design Name: 
// Module Name: Gray_filter
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


module Gray_filter(
    input  logic [7:0] i_r,
    input  logic [7:0] i_g,
    input  logic [7:0] i_b,
    output logic [7:0] o_r,
    output logic [7:0] o_g,
    output logic [7:0] o_b
    );
    
    logic [15:0] gray;
    
    assign gray = 77 * i_r + 154 * i_g + 25 * i_b;
    
     assign o_r = gray[15:8];
     assign o_g = gray[15:8];
     assign o_b = gray[15:8];
    
    
    
    
    
endmodule

