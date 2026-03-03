`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 16:22:44
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
    input logic [3:0] i_red,
    input logic [3:0] i_green,
    input logic [3:0] i_blue,
    input logic [3:0] o_red,
    input logic [3:0] o_green,
    input logic [3:0] o_blue
    );
    
    logic [11:0] gray;
    
    assign gray = 51 * i_red + 179 * i_green + 26 * i_blue;
    
     assign o_red = gray[11:8];
     assign o_green = gray[11:8];
     assign o_blue = gray[11:8];
    
    
    
    
    
endmodule
