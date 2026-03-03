`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 14:34:48
// Design Name: 
// Module Name: counter_top
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


module counter_top(
    input clk,
    input rst,
    output [13:0] o_count,
    input enable,
    input clear,
    input mode
    );

    //wire [3:0] w_bcd;
    wire w_tick_10hz;

    tick_gen U_TICK_GEN(
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick_10hz),
        .i_enable(enable),
        .i_clear(clear)
    );

    counter U_COUNTER(
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_10hz),
        .o_count(o_count),
        .i_mode(mode),
        .i_clear(clear)
    );



endmodule
