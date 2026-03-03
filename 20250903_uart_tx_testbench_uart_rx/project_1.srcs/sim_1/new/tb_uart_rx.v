`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 16:13:51
// Design Name: 
// Module Name: tb_uart_rx
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


module tb_uart_rx();

    parameter BAUD_RATE = 9600;
    parameter CLOCK_PERIOD_NS = 10; //100mhz
    parameter BIT_PER_CLOCK = 10416; //100_000_000 / BAUD_RATE; = 1 bit per clock 
    parameter BIT_PERIOD = BIT_PER_CLOCK * CLOCK_PERIOD_NS; // number of clock * 10(ns)

    reg clk;
    reg rst;
    reg rx;
    wire [7:0] rx_data;
    wire rx_done;

    // for verification
    reg [7:0] send_data;
    integer bit_cnt = 0;

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .tx_start(),
        .tx_data(),
        .tx_busy(),
        .tx(),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; rx = 1; send_data = 8'h31;
        #10; rst = 0;
        #100;

        // to rx data 8'h31
        // uart send to uart rx
        // uart start bit
        rx = 0;
        #(BIT_PERIOD);
        // Data
        for(bit_cnt = 0; bit_cnt < 8; bit_cnt = bit_cnt + 1) begin
            if(send_data[bit_cnt]) begin
                rx = 1'b1;
            end else begin
                rx = 1'b0;
            end // == rx = send_data[bit_cnt]
            #(BIT_PERIOD);
        end
        // stop
        rx = 1'b1;
        #(BIT_PERIOD);
        #1000;
        $stop;
    end
endmodule



