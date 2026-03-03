`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 14:18:52
// Design Name: 
// Module Name: VGA_RGB_Switch
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


module VGA_RGB_Switch(
    input  logic [3:0] r_sw,
    input  logic [3:0] g_sw,
    input  logic [3:0] b_sw,
    input  logic DE,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
    );

    assign r_port = DE ? r_sw : 4'b0;
    assign g_port = DE ? g_sw : 4'b0;
    assign b_port = DE ? b_sw : 4'b0;
endmodule
