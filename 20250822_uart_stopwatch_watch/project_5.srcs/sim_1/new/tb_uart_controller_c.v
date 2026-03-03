`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/19 15:27:48
// Design Name: 
// Module Name: tb_uart_controller_c
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


module tb_uart_controller_c();
    reg clk;
    reg reset;
    reg [7:0] rx_fifo_data;
    reg rx_trigger;
    wire o_run;


    always #5  clk = ~clk;

    initial begin
    #0; clk = 0; reset = 1; rx_trigger = 0; rx_fifo_data = 0;
    #10; reset = 0;
    #10; rx_trigger = 1;
    #10; rx_fifo_data = 8'h72;
    #40; rx_fifo_data = 0;
    #10; rx_trigger = 0;
    $stop;
    end




    uart_controller_c dut(
        .clk(clk),
        .reset(reset),
        .rx_fifo_data(rx_fifo_data),
        .rx_trigger(rx_trigger),
        .o_run(o_run)   
        );
endmodule
