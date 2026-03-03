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
    // input  logic [3:0] r_sw,
    // input  logic [3:0] g_sw,
    // input  logic [3:0] b_sw,
    input  logic       sel_sw,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
    );

    logic DE;
    logic [9:0] x_pixel;         
    logic [9:0] y_pixel;

    logic [3:0] img_r_port;
    logic [3:0] img_g_port;
    logic [3:0] img_b_port;

    logic [3:0] colorBar_r_port;
    logic [3:0] colorBar_g_port;
    logic [3:0] colorBar_b_port;
    logic [$clog2(640*480)-1 : 0] addr;
    logic [15:0] imgData;

    imageROM U_ROM(
        .addr(addr),
        .data(imgData)
    );

    ImgMemReader U_dut_1(
        .*,
        .addr(addr),
        .imgData(imgData),
        .r_port(img_r_port),
        .g_port(img_g_port),
        .b_port(img_b_port)
    );

    VGA_Decoder U_dut(.*);

    VGA_ColorBar U_dut_2(
    .*,        
    .red_port(colorBar_r_port),
    .green_port(colorBar_g_port),
    .blue_port(colorBar_b_port)
    );

    mux_2x1 U_dut_3(
        .sel(sel_sw),
        .rgb_0({colorBar_r_port, colorBar_g_port, colorBar_b_port}),
        .rgb_1({img_r_port, img_g_port, img_b_port}),
        .rgb({r_port, g_port, b_port})
    );


endmodule

module mux_2x1(
    input  logic        sel,
    input  logic [11:0] rgb_0,
    input  logic [11:0] rgb_1,
    output logic [11:0] rgb
    );

    always_comb begin
        case(sel)
            1'b0 : rgb = rgb_0;
            1'b1 : rgb = rgb_1;
        endcase
    end
endmodule

