`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/01 11:34:21
// Design Name: 
// Module Name: tb_counter
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


module tb_counter();
    reg clk;
    reg rst;
    reg i_tick;
    reg mode;
    wire [13:0] o_count;

    counter dut(
        .clk(clk),
        .rst(rst),
        .i_tick(i_tick),
        .mode(mode),
        .o_count(o_count)
    );

    always #5 clk = ~clk;

    initial begin
    #0; clk = 0; rst = 1; i_tick = 0;
    #10; rst = 0; 
    #10; mode = 1;


    #10; $stop;
    end
endmodule