`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/13 15:08:50
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input clk,
    input rst,
    input start_trigger,
    input [7:0] tx_data,
    input b_tick,
    output tx,
    output tx_busy
    );

    // fsm state
    localparam [2:0] IDLE = 3'h0, WAIT = 3'h1, START = 3'h2, DATA = 3'h3, STOP = 3'h4;

    // state
    reg [2:0] state, next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg tx_reg, tx_next; //output을 순서에 맞게 내보내기 위함
    reg [7:0] data_reg, data_next; // tx_internal buffer
    reg tx_busy_reg, tx_busy_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // idle output is high
            b_tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            data_reg <= 0;
            tx_busy_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            data_reg <= data_next;
            tx_busy_reg <= tx_busy_next;
        end
    end
    // next CL
    always@(*) begin
        next = state;
        tx_next = tx_reg;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        data_next = data_reg;
        tx_busy_next = tx_busy_reg;
        case(state)
        IDLE : begin
            tx_next = 1'b1;
            tx_busy_next = 1'b0;
            if(start_trigger) begin
                tx_busy_next = 1'b1;
                data_next = tx_data;
                next= WAIT;
            end
        end
        WAIT : begin
            //tx_next = 1'b0;
            if(b_tick) begin
                b_tick_cnt_next = 0;
                next = START;
            end
        end
        START : begin
            tx_next = 1'b0;
            if(b_tick) begin
                if(b_tick_cnt_reg == 15) begin
                    b_tick_cnt_next = 0;
                    bit_cnt_next = 0;
                    // data_next = tx_data;
                    next = DATA;
                end else begin
                    b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
        end
        DATA : begin
            // ouput tx <- tx_data[0]
            tx_next = data_reg[0]; // output 현재값
            if(b_tick) begin
                if(b_tick_cnt_reg == 15) begin
                    b_tick_cnt_next = 0;
                    if(bit_cnt_reg == 7) begin
                        next = STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        data_next = data_reg >> 1;
                    end
                end else begin
                    b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
        end
        STOP : begin
            tx_next = 1'b1;
            if(b_tick) begin
                if(b_tick_cnt_reg == 15) begin
                    tx_busy_next = 1'b0;
                    next = IDLE;
                end else begin
                    b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
        end 
        endcase
    end
endmodule
