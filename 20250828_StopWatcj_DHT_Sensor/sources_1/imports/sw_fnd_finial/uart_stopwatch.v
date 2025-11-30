`timescale 1ns / 1ps

module uart_stopwatch (
    // --- Physical I/O Ports ---
    input        clk,
    input        rst,
    input        sw0,      // FND Display Mode
    input        sw1,      // Stopwatch / Watch Mode
    input        Btn_U,
    input        Btn_D,
    input        Btn_L,
    input        Btn_R,
    input        rx,    
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    //==============================================================================
    // 1. 내부 신호 선언부 (Wires & Regs)
    //==============================================================================

    // --- UART & FIFO ---
    wire b_tick;
    wire rx_done;
    wire [7:0] rx_data;
    wire [7:0] fifo_rd_data;
    wire fifo_empty, fifo_pop;

    // --- Button Processing ---
    wire btn_u_debounced, btn_d_debounced, btn_l_debounced, btn_r_debounced;
    wire bp_up_pulse, bp_down_pulse, bp_left_pulse, bp_right_pulse;

    // --- Command CU (번역가) Outputs ---
    wire runstop_pulse, clear_pulse, up_pulse, down_pulse, left_pulse, right_pulse, mode_switch_pulse, fnd_toggle_pulse;

    // --- Mode Manager (상태 관리자) Outputs ---
    wire current_function_mode;
    wire fnd_display_mode;
    wire sw_runstop;

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

    //==============================================================================
    // 2. 모듈 인스턴스화 (Module Instantiation)
    //==============================================================================

    // --- Input Processing Units ---
    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .b_tick(b_tick)
    );
    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(b_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push(rx_done),
        .push_data(rx_data),
        .pop(fifo_pop),
        .pop_data(fifo_rd_data),
        .full(),
        .empty(fifo_empty)
    );

    // Debouncing
    button_debounce U_DB_U (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_U),
        .o_btn(btn_u_debounced)
    );
    button_debounce U_DB_D (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_D),
        .o_btn(btn_d_debounced)
    );
    button_debounce U_DB_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_L),
        .o_btn(btn_l_debounced)
    );
    button_debounce U_DB_R (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_R),
        .o_btn(btn_r_debounced)
    );

    // Edge Detection
    edge_detector U_ED_U (
        .clk(clk),
        .rst(rst),
        .i_level(btn_u_debounced),
        .o_pulse(bp_up_pulse)
    );
    edge_detector U_ED_D (
        .clk(clk),
        .rst(rst),
        .i_level(btn_d_debounced),
        .o_pulse(bp_down_pulse)
    );
    edge_detector U_ED_L (
        .clk(clk),
        .rst(rst),
        .i_level(btn_l_debounced),
        .o_pulse(bp_left_pulse)
    );
    edge_detector U_ED_R (
        .clk(clk),
        .rst(rst),
        .i_level(btn_r_debounced),
        .o_pulse(bp_right_pulse)
    );

    // --- Central Control Units ---
    command_cu U_COMMAND_CU (
        .clk(clk),
        .rst(rst),
        .current_mode_in(current_function_mode),
        .i_fifo_empty(fifo_empty),
        .i_fifo_rd_data(fifo_rd_data),
        .i_btn_r_pulse(bp_right_pulse),
        .i_btn_l_pulse(bp_left_pulse),
        .i_btn_u_pulse(bp_up_pulse),
        .i_btn_d_pulse(bp_down_pulse),
        .o_fifo_pop(fifo_pop),
        .o_runstop_pulse(runstop_pulse),
        .o_clear_pulse(clear_pulse),
        .o_up_pulse(up_pulse),
        .o_down_pulse(down_pulse),
        .o_left_pulse(left_pulse),
        .o_right_pulse(right_pulse),
        .o_mode_switch_pulse(mode_switch_pulse),
        .o_fnd_toggle_pulse(fnd_toggle_pulse)
    );

    mode_manager U_MODE_MANAGER (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .sw1(sw1),
        .runstop_pulse(runstop_pulse),
        .mode_switch_pulse(mode_switch_pulse),
        .fnd_toggle_pulse(fnd_toggle_pulse),
        .current_function_mode(current_function_mode),
        .fnd_display_mode(fnd_display_mode),
        .sw_runstop(sw_runstop)
    );

    command_router U_COMMAND_ROUTER (
        .current_function_mode(current_function_mode),
        .clear_pulse(clear_pulse),
        .up_pulse(up_pulse),
        .down_pulse(down_pulse),
        .left_pulse(left_pulse),
        .right_pulse(right_pulse),
        .sw_clear_en(sw_clear_en),
        .wc_up_en(wc_up_en),
        .wc_down_en(wc_down_en),
        .wc_left_en(wc_left_en),
        .wc_right_en(wc_right_en),
        .wc_clear_en(wc_clear_en)
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
        .i_runstop(sw_runstop),
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
        .mode(fnd_display_mode),
        .sw_mode(current_function_mode),
        .i_sw_time(stopwatch_time),
        .i_w_time(watch_time),
        .i_w_state(w_state),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
