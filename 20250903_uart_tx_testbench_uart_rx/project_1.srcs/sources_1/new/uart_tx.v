`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 14:07:33
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
    input b_tick,
    input tx_start,
    input [7:0] tx_data,
    output tx_busy,
    output tx
    // output [7:0] rx_data,
    // output rx_done 
);

    parameter [1:0] IDLE = 2'b00, START = 2'b01 , DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state, state_next;
    reg [7:0] data_reg, data_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [3:0] b_tick_reg, b_tick_next;
    reg tx_busy_reg, tx_busy_next;
    reg tx_reg, tx_next;

    assign tx = tx_reg;
    assign tx_busy  = tx_busy_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            tx_reg  <= 1;
            data_reg   <= 0;
            bit_count_reg   <= 0;
            b_tick_reg <= 0;
            tx_busy_reg <= 0;
        end else begin
            state       <= state_next;
            tx_busy_reg <= tx_busy_next;
            tx_reg  <= tx_next;
            data_reg   <= data_next;
            bit_count_reg   <= bit_count_next;
            b_tick_reg <= b_tick_next;
        end
    end

    always @(*) begin
            state_next = state;
            tx_next  = tx_reg;
            data_next   = data_reg;
            bit_count_next = bit_count_reg;
            b_tick_next = b_tick_reg;
            tx_busy_next = tx_busy_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_busy_next = 1'b0;
                if(tx_start) begin
                    b_tick_next = 0;
                    data_next = tx_data;
                    state_next = START;
                end
            end
            START: begin
                tx_busy_next = 1'b1;
                tx_next = 1'b0;
                if(b_tick) begin
                    if(b_tick_reg == 15) begin
                        b_tick_next = 0;
                        bit_count_next = 0;
                        state_next = DATA;
                    end else begin
                        b_tick_next = b_tick_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = data_reg[0];
                if(b_tick) begin
                    if(b_tick_reg == 15) begin
                        b_tick_next = 0;
                        if(bit_count_reg == 7) begin    
                            bit_count_next = 0;                  
                            state_next = STOP;
                        end else begin
                            b_tick_next = 0;
                            bit_count_next = bit_count_reg + 1;
                            data_next = data_reg >> 1;
                        end
                    end else begin
                        b_tick_next = b_tick_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if(b_tick) begin
                    if(b_tick_reg == 15) begin
                        state_next = IDLE;
                    end else begin
                        b_tick_next = b_tick_reg + 1;
                    end
                end
            end



        endcase
    end
endmodule
