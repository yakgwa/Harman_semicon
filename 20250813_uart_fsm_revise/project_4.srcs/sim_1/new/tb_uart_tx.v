`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/13 16:13:03
// Design Name: 
// Module Name: tb_uart_tx
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


module tb_uart_tx();
    
    parameter UART_TX_DELAY = (100_000_000 / 9600) * 12 * 10;
    reg clk;
    reg rst;
    reg btn_r;
    wire tx;
    
    always #5 clk = ~clk;

    initial begin
         #0; clk = 0; rst = 1; btn_r = 0; // 버튼을 8us 이상은 끌어줘야함
         #10; rst = 0;
         #10; btn_r = 1;
         #10_000; //10Usec
         btn_r = 0;
         // tx = 9600hz * 12정도 봐야함
         // 100_000_000 / 9600 * 10nsec의 시간이 필요
         #(UART_TX_DELAY);
         #1000;
         $stop;
    end

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .btn_r(btn_r),
        .tx(tx)
    );

endmodule
