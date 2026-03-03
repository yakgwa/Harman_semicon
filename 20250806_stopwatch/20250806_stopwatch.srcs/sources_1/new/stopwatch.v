`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/06 15:04:26
// Design Name: 
// Module Name: stopwatch
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

module stopwatch(
    input clk,
    input reset,
    input Btn_L,
    input Btn_R,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire w_runstop, w_clear;

    stopwatch_dp U_SW_DP(
        .clk(clk),
        .reset(reset),
        .i_runstop(w_runstop),
        .i_clear(w_clear),
        .msec(w_msec),
        .sec(w_sec)
        );

    fnd_controller U_FND_CTRL(
    .clk(clk),
    .reset(reset),
    .i_time({w_sec, w_msec}),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
    );

    stopwatch_cu U_SW_CU(
        .clk(clk),
        .reset(reset),
        .i_runstop(Btn_R),
        .i_clear(Btn_L),
        .o_runstop(w_runstop),
        .o_clear(w_clear) 
        );

endmodule
