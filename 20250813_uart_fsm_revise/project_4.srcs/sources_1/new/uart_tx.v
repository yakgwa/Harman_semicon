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
    output tx
    );

    // fsm state
    localparam [3:0] IDLE = 4'h0, WAIT = 4'h1, START = 4'h2, DATA = 4'h3, STOP = 4'h4;
    // localparam [3:0] BIT1 = 4'h4, BIT2 = 4'h5,BIT3 = 4'h6, BIT4 = 4'h7;
    // localparam [3:0] BIT5 = 4'h8, BIT6 = 4'h9, BIT7 = 4'hA, STOP = 4'hB;

    // state
    reg [3:0] state, next;
    reg tx_reg, tx_next; //output을 순서에 맞게 내보내기 위함
    reg [2:0] bit_index, bit_index_next;

    assign tx = tx_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // idle output is high
        end else begin
            state <= next;
            tx_reg <= tx_next;
            bit_index <= bit_index_next;
        end
    end
    // next CL
    always@(*) begin
        next = state;
        tx_next = tx_reg;
        bit_index_next = bit_index;
        case(state)
        IDLE : begin
            tx_next = 1'b1;
            bit_index_next = 0;
            if(start_trigger) begin
                next= WAIT;
            end
        end
        WAIT : begin
            //tx_next = 1'b0;
            if(b_tick) begin
                next = START;
            end
        end
        START : begin
            tx_next = 1'b0;
            if(b_tick) begin
                next = DATA;
            end
        end
        DATA: begin
            tx_next = tx_data[bit_index];
            if(b_tick) begin
                if(bit_index == 3'h7)
                    next = STOP;
                else
                    bit_index_next = bit_index + 1'b1; // b_tick일 때 증가
            end
        end

        STOP : begin
            tx_next = 1'b1;
            if(b_tick) begin
                next = IDLE;
            end
        end 
        endcase
    end
endmodule
