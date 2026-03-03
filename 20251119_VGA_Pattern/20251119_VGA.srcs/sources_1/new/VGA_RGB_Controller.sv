`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 14:26:49
// Design Name: 
// Module Name: VGA_RGB_Controller
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


module VGA_RGB_Controller(
    input  logic       clk,
    input  logic       reset,
    //input  logic [3:0] r_sw,
    //input  logic [3:0] g_sw,
    //input  logic [3:0] b_sw,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
    );

    logic DE;
    logic [$clog2(639)-1:0] x_pixel;
    logic [$clog2(479)-1:0] y_pixel;

    VGA_Decoder U_dut(.*);
    //VGA_RGB_Switch U_dut_1(.*);
    vgaPattern U_dut_1(.*, .red(r_port), .green(g_port), .blue(b_port));

endmodule
