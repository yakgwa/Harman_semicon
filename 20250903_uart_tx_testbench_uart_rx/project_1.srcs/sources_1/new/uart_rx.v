`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 16:32:36
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input clk,
    input rst,
    input b_tick,
    input rx,
    output [7:0] rx_data,
    output rx_done
    );

    parameter IDLE = 2'b00, START = 2'b01 , DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg rx_done_reg, rx_done_next;
    reg [7:0] data_buf_reg, data_buf_next;

    assign rx_data = data_buf_reg;
    assign rx_done = rx_done_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state_reg <= IDLE;
            b_tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            rx_done_reg <= 0;
            data_buf_reg <= 0;
        end else begin
            state_reg <= state_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            rx_done_reg <= rx_done_next;
            data_buf_reg <= data_buf_next;
        end
    end

    always@(*) begin
            state_next = state_reg;
            b_tick_cnt_next = b_tick_cnt_reg;
            bit_cnt_next = bit_cnt_reg;
            rx_done_next = rx_done_reg;
            data_buf_next = data_buf_reg;
            case(state_reg)
            IDLE : begin
            rx_done_next = 0;
                if(b_tick) begin
                    if(rx == 0) begin
                        state_next = START;
                    end
                end
            end
            START : begin
                if(b_tick) begin
                    if(b_tick_cnt_next == 23) begin
                        state_next = DATA;
                        b_tick_cnt_next = 0;
                        bit_cnt_next = 0;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA : begin
                if(b_tick) begin
                    if(b_tick_cnt_reg == 0) begin
                        data_buf_next[7] = rx;
                    end
                    if(b_tick_cnt_next == 15) begin
                        if(bit_cnt_next == 7) begin
                            state_next = STOP;
                        end else begin
                            b_tick_cnt_next = 0;
                            bit_cnt_next = bit_cnt_reg + 1;
                            data_buf_next = data_buf_reg >> 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end 
            end
            STOP : begin
                if(b_tick) begin
                    state_next = IDLE;
                    rx_done_next = 1;
                end
            end
            endcase
    end
endmodule