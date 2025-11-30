`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 19:08:55
// Design Name: 
// Module Name: Grayfilter
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
    input  logic [3:0] i_r,
    input  logic [3:0] i_g,
    input  logic [3:0] i_b,
    output logic [3:0] o_r,
    output logic [3:0] o_g,
    output logic [3:0] o_b
    );
    
    logic [11:0] gray;
    
    assign gray = 51 * i_r + 179 * i_g + 26 * i_b;
    
     assign o_r = gray[11:8];
     assign o_g = gray[11:8];
     assign o_b = gray[11:8];
    
    
    
    
    
endmodule
