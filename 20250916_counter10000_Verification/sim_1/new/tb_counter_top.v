`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 14:38:36
// Design Name: 
// Module Name: tb_counter_top
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


module tb_counter_top();
    reg clk;
    reg rst;
    wire o_count;
    reg enable;
    reg clear;
    reg mode;
    // reg clk;
    // reg rst;
    // wire [7:0] fnd_data;
    // wire [3:0] fnd_com;

    // counter_top dut(
    //     .clk(clk),
    //     .rst(rst),
    //     .fnd_data(fnd_data),
    //     .fnd_com(fnd_com)
    // );
    counter_top dut(
        .clk(clk),
        .rst(rst),
        .o_count(o_count),
        .enable(enable),
        .clear(clear),
        .mode(mode)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; enable = 0; clear = 0; mode = 0;
        #10; rst = 0; enable = 1;
        wait(dut.w_tick_10hz); // wait for w_tick_10hz high
        #100_000_000; $finish;

    end
endmodule
