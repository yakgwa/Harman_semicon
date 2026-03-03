`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 15:47:25
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
    parameter BAUD_DELAY = (100_000_000/9600) * 10 * 10; // 10비트에 한 클락 10ns
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    wire  tx_busy;
    wire  tx;

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx)
        );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; tx_start = 0; tx_data = 8'h31;
        #10; rst = 0;
        #10 tx_start = 1;
        #10; tx_start = 0;

        #(BAUD_DELAY);
        #1000;
        $stop;

    end

//     // for verification
//     // vector gen to dut()
//     task sender(input start, input [7:0] tx_data);
//         begin

//         end
//     endtask
//     // receive for verification
//     task rx_verifi(input start, input [7:0] tx_data);
//         begin

//         end
//     endtask

endmodule
