`timescale 1ns / 1ps

module btn_sw_top(
    input        Btn_L,
    input        Btn_R,
    input        Btn_U,
    input        Btn_D,

    output      o_pulse_L,
    output      o_pulse_R,
    output      o_pulse_U,
    output      o_pulse_D
    );

    wire btn_u_debounced, btn_d_debounced, btn_l_debounced, btn_r_debounced;
    // wire bp_up_pulse, bp_down_pulse, bp_left_pulse, bp_right_pulse;.
    

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

    // Edge Detection
    edge_detector U_ED_L (
        .clk(clk),
        .rst(rst),
        .i_level(btn_l_debounced),
        .o_pulse(o_pulse_L)
    );
    edge_detector U_ED_R (
        .clk(clk),
        .rst(rst),
        .i_level(btn_r_debounced),
        .o_pulse(o_pulse_R)
    );
    edge_detector U_ED_U (
        .clk(clk),
        .rst(rst),
        .i_level(btn_u_debounced),
        .o_pulse(o_pulse_U)
    );
    edge_detector U_ED_D (
        .clk(clk),
        .rst(rst),
        .i_level(btn_d_debounced),
        .o_pulse(o_pulse_D)
    );
endmodule
