`timescale 1ns / 1ps


module sw_w_data(
    input clk,
    input rst,  
    input i_current_function_mode,
    input i_mode,
    input i_left_pulse,
    input i_right_pulse,
    input i_up_pulse,
    input i_down_pulse,
    input i_clear_pulse,
    input i_runstop,

    output [3:0] fnd_com,
    output [7:0] fnd_data
    );
    

    // --- Command Router (교통 경찰) Outputs ---
    wire sw_clear_en;
    wire wc_up_en, wc_down_en, wc_left_en, wc_right_en, wc_clear_en;

    // --- Sub-module I/O Wires ---
    wire [1:0] w_state;
    wire [4:0] w_hour_value;
    wire [5:0] w_min_value, w_sec_value;
    wire w_hour_set, w_min_set, w_sec_set, w_clear;

    // --- Data Path Wires ---
    wire [23:0] stopwatch_time, watch_time;

    command_router U_COMMAND_ROUTER (
        .current_function_mode(i_current_function_mode),
        .clear_pulse(i_clear_pulse),
        .left_pulse(i_left_pulse),
        .right_pulse(i_right_pulse),
        .up_pulse(i_up_pulse),
        .down_pulse(i_down_pulse),
        .sw_clear_en(sw_clear_en),
        .wc_clear_en(wc_clear_en),
        .wc_left_en(wc_left_en),
        .wc_right_en(wc_right_en),
        .wc_up_en(wc_up_en),
        .wc_down_en(wc_down_en)
    );

    // --- Functional Units ---
    watch_cu U_WATCH_CU (
        .clk(clk),
        .rst(rst),
        .i_btn_l(wc_left_en),
        .i_btn_r(wc_right_en),
        .i_btn_u(wc_up_en),
        .i_btn_d(wc_down_en),
        .i_btn_c(wc_clear_en),
        .o_hour_set(w_hour_set),
        .o_min_set(w_min_set),
        .o_sec_set(w_sec_set),
        .o_hour_value(w_hour_value),
        .o_min_value(w_min_value),
        .o_sec_value(w_sec_value),
        .o_clear(w_clear),
        .o_set_mode_active(),
        .o_state(w_state)
    );
    watch_dp U_WATCH_DP (
        .clk(clk),
        .rst(rst),
        .i_set_mode_active(w_state != 2'b00),
        .i_hour_set(w_hour_set),
        .i_hour_value(w_hour_value),
        .i_min_set(w_min_set),
        .i_min_value(w_min_value),
        .i_sec_set(w_sec_set),
        .i_sec_value(w_sec_value),
        .i_clear(w_clear),
        .msec(watch_time[6:0]),
        .sec(watch_time[12:7]),
        .min(watch_time[18:13]),
        .hour(watch_time[23:19])
    );

    stopwatch_dp U_SW_DP (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .i_clear(sw_clear_en),
        .msec(stopwatch_time[6:0]),
        .sec(stopwatch_time[12:7]),
        .min(stopwatch_time[18:13]),
        .hour(stopwatch_time[23:19])
    );

    // --- Output Unit ---
    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .mode(i_mode),
        .sw_mode(i_current_function_mode),
        .i_sw_time(stopwatch_time),
        .i_w_time(watch_time),
        .i_w_state(w_state),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );






   














endmodule
