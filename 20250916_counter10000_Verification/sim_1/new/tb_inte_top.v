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

    parameter BAUD_RATE = 9600;
    parameter CLOCK_PERIOD_NS = 10; //100mhz
    parameter BIT_PER_CLOCK = 10416; //100_000_000 / BAUD_RATE; = 1 bit per clock 
    parameter BIT_PERIOD = BIT_PER_CLOCK * CLOCK_PERIOD_NS; // number of clock * 10(ns)

    reg clk;
    reg rst;
    reg rx;
    reg start;
    reg clear;
    reg mode;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire tx;

    // for verification
    reg [7:0] send_data;
    integer bit_cnt = 0;

    inte_top dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .start(start),
        .clear(clear),
        .mode(mode),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; rx = 1; start = 0; clear = 0; mode = 0; send_data = 0; //8'h64;
        #10; rst = 0;
        #100;
        $display("%0t, Reset",$time);
        #100;
        uart_send_byte(8'h64);
        $display("%0t: UART byte sent: 0x%0h ('%s')", $time, 8'h64, "d");
        #(1000*BIT_PERIOD);
        clear = 1;
        #100;
        $display("%0t, Clear On",$time);
        #100;
        clear = 0;
        $display("%0t, Clear Off",$time);
        #(1000*BIT_PERIOD);

        mode = 1;
        #100;
        $display("%0t, Mode On",$time);
        #(1000*BIT_PERIOD);

        start = 1;
        #100;
        $display("%0t, Start On",$time);
        #(1000*BIT_PERIOD);

        start = 0;
        #100;
        $display("%0t, Start Off",$time);
        #(1000*BIT_PERIOD);

        $stop;
    end

    task uart_send_byte(input [7:0] send_data);
        integer bit_cnt;
        begin
            rx = 0;
            #(BIT_PERIOD);
            for (bit_cnt = 0; bit_cnt < 8; bit_cnt = bit_cnt + 1) begin
                rx = send_data[bit_cnt];
                #(BIT_PERIOD);
            end
            rx = 1;
            #(BIT_PERIOD);
            #1000;
        end
    endtask


endmodule
