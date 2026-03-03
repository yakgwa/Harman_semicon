`timescale 1ns / 1ps

module sw_w_module_cu (
    input            clk,
    input            rst,
    input            sw0,
    input            sw1,
    input            i_fifo_empty,
    input      [7:0] i_fifo_rd_data,
    input            i_btn_l_pulse,
    input            i_btn_r_pulse,
    input            i_btn_u_pulse,
    input            i_btn_d_pulse,
    output           o_fifo_pop,
    output reg       o_runstop_pulse,
    output reg       o_current_function_mode,  // 재우씨 왜 이건 reg?
    output           o_clear_pulse,
    output           o_left_pulse,
    output           o_right_pulse,
    output           o_up_pulse,
    output           o_down_pulse,
    output           o_sw_runstop,
    output           o_fnd_display_mode

);

    // mode_manager
    wire fnd_toggle_pulse, mode_switch_pulse, runstop_pulse;
    wire current_function_mode, fnd_display_mode, sw_runstop;

    // sw_command_cu
    // wire o_pulse_L,o_pulse_R,o_pulse_U,o_pulse_D;

    assign current_function_mode = o_current_function_mode;

    // wire w_o_up_pulse;


    command_cu U_SW_COMMAND_CU (
        .clk(clk),
        .rst(rst),
        .current_mode_in(current_function_mode),  // Top 모듈의 현재 모드를 입력받음
        .i_btn_l_pulse(i_btn_l_pulse),
        .i_btn_r_pulse(i_btn_r_pulse),
        .i_btn_u_pulse(i_btn_u_pulse),
        .i_btn_d_pulse(i_btn_d_pulse),
        .i_fifo_empty(i_fifo_empty),
        .i_fifo_rd_data(i_fifo_rd_data),
        .o_fifo_pop(o_fifo_pop),

        .o_fnd_toggle_pulse(fnd_toggle_pulse),
        .o_mode_switch_pulse(mode_switch_pulse),
        .o_runstop_pulse(runstop_pulse),
        .o_clear_pulse(o_clear_pulse),
        .o_left_pulse(o_left_pulse),
        .o_right_pulse(o_right_pulse),
        .o_up_pulse(o_up_pulse),
        .o_down_pulse(o_down_pulse)
    );



    mode_manager U_SW_MODE_MANGER (
        .clk(clk),
        .rst(rst),
        .current_function_mode(current_function_mode),
        .sw0(sw0),
        .sw1(sw1),
        .fnd_toggle_pulse(fnd_toggle_pulse),
        .mode_switch_pulse(mode_switch_pulse),
        .runstop_pulse(runstop_pulse),
        .fnd_display_mode(o_fnd_display_mode),
        .sw_runstop(o_sw_runstop)
    );

endmodule
