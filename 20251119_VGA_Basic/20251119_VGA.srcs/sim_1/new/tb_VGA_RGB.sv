`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 14:01:34
// Design Name: 
// Module Name: tb_VGA_RGB
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


module tb_VGA_RGB();
    logic       clk;
    logic       reset;
    logic [3:0] r_sw;
    logic [3:0] g_sw;
    logic [3:0] b_sw;
    logic h_sync;
    logic v_sync;
    logic [3:0] r_port;
    logic [3:0] g_port;
    logic [3:0] b_port;

    VGA_RGB_Controller dut(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10; reset = 0;
        repeat(4) @(posedge clk);
        r_sw = 4'b1111;
        g_sw = 4'b1000;
        b_sw = 4'b1000;
    end
endmodule





//     logic clk;
//     logic reset;
//     logic h_sync;
//     logic v_sync;

//     VGA_Decoder dut(.*);

//     always #5 clk = ~clk;

//     initial begin
//          #00 clk = 0; reset = 1;
//          #10 reset = 0;
//     end

// endmodule
