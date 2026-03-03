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
    localparam [3:0] IDLE = 4'h0, WAIT = 4'h1, START = 4'h2, BIT0 = 4'h3;
    localparam [3:0] BIT1 = 4'h4, BIT2 = 4'h5,BIT3 = 4'h6, BIT4 = 4'h7;
    localparam [3:0] BIT5 = 4'h8, BIT6 = 4'h9, BIT7 = 4'hA, STOP = 4'hB;

    // state
    reg [3:0] state, next;
    reg tx_reg, tx_next; //output을 순서에 맞게 내보내기 위함

    assign tx = tx_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // idle output is high
        end else begin
            state <= next;
            tx_reg <= tx_next;
        end
    end
    // next CL
    always@(*) begin
        next = state;
        tx_next = tx_reg;
        case(state)
        IDLE : begin
            tx_next = 1'b1;
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
                next = BIT0;
            end
        end
        BIT0 : begin
            // ouput tx <- tx_data[0]
            tx_next = tx_data[0];
            if(b_tick) begin
                next = BIT1;
            end
        end
        BIT1 : begin
            tx_next = tx_data[1];
            if(b_tick) begin
                next = BIT2;
            end
        end
        BIT2 : begin
            tx_next = tx_data[2];
            if(b_tick) begin
                next = BIT3;
            end
        end
        BIT3 : begin
            tx_next = tx_data[3];
            if(b_tick) begin
                next = BIT4;
            end
        end
        BIT4 : begin
            tx_next = tx_data[4];
            if(b_tick) begin
                next = BIT5;
            end
        end
        BIT5 : begin
            tx_next = tx_data[5];
            if(b_tick) begin
                next = BIT6;
            end
        end
        BIT6 : begin
            tx_next = tx_data[6];
            if(b_tick) begin
                next = BIT7;
            end
        end
        BIT7 : begin
            tx_next = tx_data[7];
            if(b_tick) begin
                next = STOP;
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
