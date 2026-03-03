`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/05 09:20:08
// Design Name: 
// Module Name: inte_top
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


module inte_top(
    input clk,
    input rst,
    input rx,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

    wire w_enable;
    wire w_clear;
    wire w_mode;
    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [13:0] w_count;


    uart_top_1 U_UART_TOP_1(
        .clk(clk),
        .rst(rst),
        .tx_start(),
        .tx_data(),
        .tx_busy(),
        .tx(),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    command_controller_1 U_COMMAND_CONTROLLER_1(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_data),
        .rx_trigger(w_rx_done),
        //.o_pop(),
        .o_start_1(w_enable),
        .o_start_2(w_clear),
        .o_start_3(w_mode)
    );

    counter_top U_COUNTER_TOP_1(
        .clk(clk),
        .rst(rst),
        .o_count(w_count),
        .enable(w_enable),
        .clear(w_clear),
        .mode(w_mode)
    );


    fnd_controller U_FND_CONTROLLER_1(
        .clk(clk),
        .rst(rst),
        .counter(w_count),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule

module command_controller_1(
    input        clk,
    input        reset,
    input  [7:0] rx_fifo_data,
    input        rx_trigger,
    //output       o_pop,
    output       o_start_1,
    output       o_start_2,
    output       o_start_3
);

    //assign o_pop = rx_trigger;
    assign o_start_1 = (rx_trigger && (rx_fifo_data == 8'h64)); // d 
    assign o_start_2 = (rx_trigger && (rx_fifo_data == 8'h63)); // c
    assign o_start_3 = (rx_trigger && (rx_fifo_data == 8'h6d)); // m

endmodule

module uart_top_1(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output tx_busy,
    output tx,
    input rx,
    output [7:0] rx_data,
    output rx_done
    );

    wire w_b_tick;
    wire [7:0] w_rx_data;
    wire w_rx_done;

    uart_rx U_UART_RX_1(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    baud_tick_gen U_BAUD_TICK_1(
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );    

    uart_tx U_UART_TX_1(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx)


    );
endmodule