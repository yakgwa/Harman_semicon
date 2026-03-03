`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/19 15:35:30
// Design Name: 
// Module Name: total_top
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


module total_top(
    input clk,
    input rst,
    input rx,
    output tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [1:0] led,
    input btn_0,
    input btn_1
    );

    wire [7:0] w_rx_fifo_data;
    wire w_rx_trigger;
    wire w_run;
    wire w_clear;
    wire w_sel;
    wire w_sec_inc;
    wire w_min_inc;
    wire w_hour_inc;
    wire w_btn_0;
    wire w_btn_1;

    top U_STOPWATCH_WATCH(
        .clk(clk), 
        .reset(rst),  
        .btn_0(w_btn_0), 
        .btn_1(w_btn_1), 
        .mod_sel(w_sel),  
        .Btn_L(w_clear), 
        .Btn_R(w_run),  
        .Btn_U(w_sec_inc),  
        .Btn_D(w_hour_inc), 
        .fnd_com(fnd_com),  
        .fnd_data(fnd_data), 
        .led(led),
        .Btn_L_2(w_min_inc)
    );

    uart_controller_c U_COMMAND_CTRL(
        .clk(clk), 
        .reset(rst), 
        .rx_fifo_data(w_rx_fifo_data), 
        .rx_trigger(w_rx_trigger), 
        .o_run(w_run),
        .o_clear(w_clear),  
        .o_sel(w_sel),
        .o_sec_inc(w_sec_inc),
        .o_min_inc(w_min_inc),
        .o_hour_inc(w_hour_inc),
        .o_btn_0(w_btn_0),
        .o_btn_1(w_btn_1)
    );

    uart_top U_UART(
        .clk(clk), 
        .rst(rst), 
        //input btn_r,
        .rx(rx), 
        .tx(tx), 
        .rx_fifo_data(w_rx_fifo_data), 
        .rx_trigger(w_rx_trigger)
    );



endmodule


