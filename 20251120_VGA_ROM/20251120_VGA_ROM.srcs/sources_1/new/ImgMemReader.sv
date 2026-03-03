`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 11:37:44
// Design Name: 
// Module Name: ImgMemReader
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


module ImgMemReader(
    input logic DE,
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    output logic [$clog2(640*480)-1 : 0] addr,
    input logic [15:0] imgData,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
    );

    assign addr = DE ? (640*y_pixel + x_pixel) : 'bz;
    assign {r_port, g_port, b_port} = DE ? {imgData[15:12], imgData[10:7], imgData[4:1]} : 0;







endmodule
