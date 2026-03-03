`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/13 14:42:26
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


module uart_top(
    input clk,
    input rst,
    input btn_r,
    output tx
    );

    wire w_start;
    wire w_b_tick;

    button_debounce U_BD_START(
        .clk(clk), 
        .rst(rst),
        .i_btn(btn_r),
        .o_btn(w_start)
    );

    uart_tx U_UART_TX(
        .clk(clk),
        .rst(rst),
        .start_trigger(w_start),
        .tx_data(8'h30),
        .b_tick(w_b_tick),
        .tx(tx)
    );

    baud_tick_gen U_BAUD_TICK_GEN(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );


endmodule

module baud_tick_gen(
    input clk,
    input rst,
    output b_tick
    );

    parameter BAUDRATE = 9600;
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;
    reg [$clog2(BAUD_COUNT - 1) : 0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    // output
    assign b_tick = tick_reg;

    // SL
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end

    // next CL
    always@(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if(counter_reg == BAUD_COUNT - 1) begin   
            counter_next = 0;
            tick_next = 1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 0;
        end
    end

endmodule
