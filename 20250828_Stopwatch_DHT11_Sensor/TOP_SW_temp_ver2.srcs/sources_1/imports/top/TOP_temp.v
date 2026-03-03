`timescale 1ns / 1ps


module TOP_temp (
    input clk,
    input rst,
    // input s_m_h_mode,
    // input sw_w_mode,   //  file :stopwatch > sw_mode , mode_manager > sw 1
    // input btn_L,
    // input btn_R,
    // input btn_U,
    // input btn_D,

    // output [3:0] fnd_com,
    // output [7:0] fnd_data
);

    // wire w_current_function_mode;
    // // reg left_pulse, right_pulse, up_pulse, down_pulse;


    // // btn - sw_w_module_cu
    // wire w_i_btn_l_pulse,w_i_btn_r_pulse,w_i_btn_u_pulse,w_i_btn_d_pulse;

    // // sw_w_module_cu - sw_w_data
    // wire w_o_left_pulse,w_o_right_pulse,w_o_up_pulse,w_o_down_pulse;
    // wire w_o_clear_pulse;

    // // mode manager - sw_dp
    // wire w_i_runstop;

    // // mode_manager - fnd

    // wire w_i_mode;







    btn_sw_top U_BTN_SW_TOP (
        .Btn_L(btn_L),
        .Btn_R(btn_R),
        .Btn_U(btn_U),
        .Btn_D(btn_D),
        .o_pulse_L(w_i_btn_l_pulse),
        .o_pulse_R(w_i_btn_r_pulse),
        .o_pulse_U(w_i_btn_u_pulse),
        .o_pulse_D(w_i_btn_d_pulse)
    );


    sw_w_module_cu U_SW_W_MODULE (
        .clk(clk),
        .rst(rst),
        .sw0(s_m_h_mode),
        .sw1(sw_w_mode),
        .i_fifo_empty(),
        .i_btn_l_pulse(w_i_btn_l_pulse),
        .i_btn_r_pulse(w_i_btn_r_pulse),
        .i_btn_u_pulse(w_i_btn_u_pulse),
        .i_btn_d_pulse(w_i_btn_d_pulse),
        .o_fifo_pop(),
        .o_runstop_pulse(),
        .o_left_pulse(w_o_left_pulse),
        .o_right_pulse(w_o_right_pulse),
        .o_up_pulse(w_o_up_pulse),
        .o_down_pulse(w_o_down_pulse),
        .o_clear_pulse(w_o_clear_pulse),
        .o_current_function_mode(w_current_function_mode),
        .o_sw_runstop(w_i_runstop),
        .o_fnd_display_mode(w_i_mode)

    );


    sw_w_data U_SW_W_DATA (
        .clk(clk),
        .rst(rst),

        .i_current_function_mode(w_current_function_mode),
        .i_mode(w_i_mode),  
        .i_runstop(w_i_runstop),
        .i_left_pulse(w_o_left_pulse),
        .i_right_pulse(w_o_right_pulse),
        .i_up_pulse(w_o_up_pulse),
        .i_down_pulse(w_o_down_pulse),
        .i_clear_pulse(w_o_clear_pulse),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );



endmodule
