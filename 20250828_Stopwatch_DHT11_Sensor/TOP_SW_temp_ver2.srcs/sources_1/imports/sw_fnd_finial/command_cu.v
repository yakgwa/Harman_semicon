`timescale 1ns / 1ps

module command_cu (
    input       clk,
    input       rst,
    input       current_mode_in,  // Top 모듈의 현재 모드를 입력받음
    input       i_fifo_empty,
    input [7:0] i_fifo_rd_data,
    input       i_btn_r_pulse,
    input       i_btn_l_pulse,
    input       i_btn_u_pulse,
    input       i_btn_d_pulse,

    output reg o_fifo_pop,
    output reg o_runstop_pulse,
    output reg o_clear_pulse,
    output reg o_up_pulse,
    output reg o_down_pulse,
    output reg o_left_pulse,
    output reg o_right_pulse,
    output reg o_mode_switch_pulse,
    output reg o_fnd_toggle_pulse
);

    wire [7:0] command_from_buttons;
    wire [7:0] final_command;
    wire       final_command_valid;
    wire       is_fifo_command;

    // 현재 모드(current_mode_in)에 따라 버튼의 역할을 다르게 번역
    assign command_from_buttons =
           (current_mode_in == 1'b0) ? // Stopwatch 모드일 때
        ((i_btn_u_pulse && i_btn_d_pulse) ? "m" :  // U+D = Mode Switch
        (i_btn_r_pulse) ? "s" : 
                 (i_btn_l_pulse) ? "c" : 8'h00) :
           (current_mode_in == 1'b1) ? // Watch 모드일 때
        ((i_btn_u_pulse && i_btn_d_pulse) ? "m" :  // U+D = Mode Switch
        (i_btn_r_pulse) ? "r" : 
                 (i_btn_l_pulse) ? "l" :
                 (i_btn_u_pulse) ? "u" : 
                 (i_btn_d_pulse) ? "d" : 8'h00) :
            8'h00;

    // 명령어 병합 (버튼 우선)
    assign is_fifo_command = !i_fifo_empty && (command_from_buttons == 8'h00);
    assign final_command = (command_from_buttons != 8'h00) ? command_from_buttons : i_fifo_rd_data;
    assign final_command_valid = (command_from_buttons != 8'h00) || !i_fifo_empty;

    // 최종 명령어를 표준 펄스로 번역
    always @(*) begin
        // 기본값 초기화
        o_fifo_pop = 1'b0;
        o_runstop_pulse = 1'b0;
        o_clear_pulse = 1'b0;
        o_up_pulse = 1'b0;
        o_down_pulse = 1'b0;
        o_left_pulse = 1'b0;
        o_right_pulse = 1'b0;
        o_mode_switch_pulse = 1'b0;
        o_fnd_toggle_pulse = 1'b0;

        if (final_command_valid) begin
            if (is_fifo_command) o_fifo_pop = 1'b1;

            case (final_command)
                "s": o_runstop_pulse = 1'b1;
                "c": o_clear_pulse = 1'b1;
                "u", "+": o_up_pulse = 1'b1;
                "d", "-": o_down_pulse = 1'b1;
                "l": o_left_pulse = 1'b1;
                "r": o_right_pulse = 1'b1;
                "m": o_mode_switch_pulse = 1'b1;
                "h": o_fnd_toggle_pulse = 1'b1;
            endcase
        end
    end
endmodule

