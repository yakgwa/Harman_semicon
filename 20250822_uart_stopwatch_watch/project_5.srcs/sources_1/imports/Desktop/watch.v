`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/11 09:10:58
// Design Name: 
// Module Name: watch
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


module watch(
    input clk,
    input reset,
    input Btn_U,
    input Btn_L_2,
    input Btn_D,
    // input btn_0,
    input mod_sel,
    // output [3:0] fnd_com,
    // output [7:0] fnd_data
    output [23:0] i_time
    );

    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire [6:0] w_msec;
    wire [5:0] w_sec;

    wire w_inc_min;
    wire w_inc_hour;
    wire w_inc_sec;

    wire w_runstop, w_clear;
    wire w_btn_u, w_btn_l, w_btn_d;
    wire w_btn_0;

    // button_debounce U_BD_BTNU(
    //     .clk(clk), 
    //     .rst(reset),
    //     .i_btn(Btn_U),
    //     .o_btn(w_btn_u)
    //     );

    // button_debounce U_BD_BTNL(
    //     .clk(clk), 
    //     .rst(reset),
    //     .i_btn(Btn_L),
    //     .o_btn(w_btn_l)
    //     );

    // button_debounce U_BTND(
    //     .clk(clk), 
    //     .rst(reset),
    //     .i_btn(Btn_D),
    //     .o_btn(w_btn_d)
    //     );

    watch_dp U_W_DP(
        .clk(clk),
        .reset(reset),
        .i_sec(w_inc_sec),
        .i_min(w_inc_min),
        .i_hour(w_inc_hour),
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

    watch_cu U_W_CU(
        .clk(clk),
        .reset(reset),
        .mod_sel(mod_sel),
        .i_btn_left(Btn_L_2),
        .i_btn_up(Btn_U),
        .i_btn_down(Btn_D),
        .o_sec(w_inc_sec),
        .o_min(w_inc_min),
        .o_hour(w_inc_hour)
        );

endmodule
