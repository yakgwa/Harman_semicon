`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 15:08:57
// Design Name: 
// Module Name: uart_top
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


// module uart_top(
//     input clk,
//     input rst,
//     input tx_start,
//     input [7:0] tx_data,
//     output tx_busy,
//     output tx,
//     input rx,
//     output [7:0] rx_data,
//     output rx_done
//     );

    // wire w_b_tick;

    // uart_rx U_UART_RX(
    //     .clk(clk),
    //     .rst(rst),
    //     .b_tick(w_b_tick),
    //     .rx(rx),
    //     .rx_data(rx_data),
    //     .rx_done(rx_done)
    // );

    // baud_tick_gen U_BAUD_TICK(
    //     .clk(clk),
    //     .rst(rst),
    //     .o_b_tick(w_b_tick)
    // );    

    // uart_tx U_UART_TX(
    //     .clk(clk),
    //     .rst(rst),
    //     .b_tick(w_b_tick),
    //     .tx_start(tx_start),
    //     .tx_data(tx_data),
    //     .tx_busy(tx_busy),
    //     .tx(tx)

// loopback
module uart_top(
    input clk,
    input rst,
    //input tx_start,
    //input [7:0] tx_data,
    output tx_busy,
    output tx,
    input rx
    //output [7:0] rx_data,
    //output rx_done
    );

    wire w_b_tick;
    wire [7:0] w_rx_data;
    wire w_rx_done;

    uart_rx U_UART_RX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    baud_tick_gen U_BAUD_TICK(
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );    

    uart_tx U_UART_TX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .tx_start(w_rx_done),
        .tx_data(w_rx_data),
        .tx_busy(tx_busy),
        .tx(tx)


    );

endmodule

module baud_tick_gen(
    input clk,
    input rst,
    output o_b_tick
);
    // 100_000_000 / 9600 / 16 = Count num 
    parameter BAUD = 9600;
    parameter BAUD_TICK_COUNT = 100_000_000 / BAUD / 16;

    reg [$clog2(BAUD_TICK_COUNT - 1) : 0] counter_reg;
    reg b_tick_reg;

    assign o_b_tick = b_tick_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            b_tick_reg <= 1'b0;
        end else begin
            if(counter_reg == BAUD_TICK_COUNT) begin
                counter_reg <= 0;
                b_tick_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                b_tick_reg <= 1'b0;
            end
        end
    end



endmodule
