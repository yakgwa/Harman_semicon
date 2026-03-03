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
    input mod_sel,
    input Btn_L,
    input Btn_R,
    input btn_0,
    // output [3:0] fnd_com,
    // output [7:0] fnd_data
    output [23:0] i_time
    );

    // wire [5:0] w_min;
    // wire [4:0] w_hour;
    // wire [6:0] w_msec;
    // wire [5:0] w_sec;
    wire w_runstop, w_clear;
    wire w_btn_l, w_btn_r;
    wire w_btn_0;

    // button_debounce U_BD_CLEAR(
    //     .clk(clk), 
    //     .rst(reset),
    //     .i_btn(Btn_L),
    //     .o_btn(w_btn_l)
    //     );

    // button_debounce U_BD_RUNSTOP(
    //     .clk(clk), 
    //     .rst(reset),
    //     .i_btn(Btn_R),
    //     .o_btn(w_btn_r)
    //     );

    stopwatch_dp U_SW_DP(
        .clk(clk),
        .reset(reset),
        .i_runstop(w_runstop),
        .i_clear(w_clear),
        .i_time(i_time)
        // .msec(w_msec),
        // .sec(w_sec),
        // .min(w_min),
        // .hour(w_hour)
        );

    // fnd_controller U_FND_CTRL(
    // .clk(clk),
    // .reset(reset),
    // .i_time({w_hour, w_min, w_sec, w_msec}),
    // .btn_0(btn_0),
    // .fnd_com(fnd_com),
    // .fnd_data(fnd_data)
    // );

    stopwatch_cu U_SW_CU(
        .clk(clk),
        .reset(reset),
        .mod_sel(mod_sel),
        .i_runstop(Btn_R),
        .i_clear(Btn_L),
        .o_runstop(w_runstop),
        .o_clear(w_clear) 
        );

endmodule
