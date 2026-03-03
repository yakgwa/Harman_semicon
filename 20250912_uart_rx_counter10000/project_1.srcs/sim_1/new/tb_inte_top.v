`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/05 13:01:38
// Design Name: 
// Module Name: tb_inte_top
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


module tb_inte_top();
    parameter RX_DELAY = (100_000_000/9600) * 10 * 10; // 10비트에 한 클락 10ns

    parameter BAUD_RATE = 9600;
    parameter CLOCK_PERIOD_NS = 10; //100mhz
    parameter BIT_PER_CLOCK = 10416; //100_000_000 / BAUD_RATE; = 1 bit per clock 
    parameter BIT_PERIOD = BIT_PER_CLOCK * CLOCK_PERIOD_NS; // number of clock * 10(ns)

    reg clk;
    reg rst;
    reg rx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    // reg clk;
    // reg rst;
    // wire enable;
    // wire clear;
    // wire mode;
    // reg rx;

    // wire w_b_tick;
    // wire w_enable;
    // wire w_clear;
    // wire w_mode;
    // wire w_rx_done;
    // wire [7:0] w_rx_data;
    // wire [13:0] w_count;

    reg [7:0] send_data;  // for input 1st data   
    integer bit_count = 0; 

    inte_top dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
        );


    // baud_tick_gen_1 dut0(
    //     .clk(clk),
    //     .rst(rst),
    //     .o_b_tick(w_b_tick)
    // );

    // command_controller_1 dut1(
    //     .clk(clk),
    //     .reset(rst),
    //     .rx_fifo_data(w_rx_data),
    //     .rx_trigger(w_rx_done),
    //     //.o_pop,
    //     .o_start_1(enable),
    //     .o_start_2(clear),
    //     .o_start_3(mode)
    // );

    // uart_top_1 dut2(
    //     .clk(clk),
    //     .rst(rst),
    //     .tx_start(),
    //     .tx_data(),
    //     .tx_busy(),
    //     .tx(),
    //     .rx(rx),
    //     .rx_data(w_rx_data),
    //     .rx_done(w_rx_done)
    //     );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; rx = 1; send_data = 8'h64;
        #10; rst = 0;
        #100;
        rx = 0;
        #(BIT_PERIOD);
        // Data
        for(bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
            rx = send_data[bit_count];
            #(BIT_PERIOD);
        end
        // stop
        rx = 1'b1;
        #(BIT_PERIOD);
        #1000;
        $stop;   

        $display("Finished");
        $stop;

    end


endmodule