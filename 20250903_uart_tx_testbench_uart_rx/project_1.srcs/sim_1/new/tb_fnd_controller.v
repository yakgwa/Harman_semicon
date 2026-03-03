`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 17:16:19
// Design Name: 
// Module Name: tb_fnd_controller
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


module tb_fnd_controller();
    reg clk;
    reg rst;
    reg [13:0] counter;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    fnd_controller dut(
        .clk(clk),
        .rst(rst),
        .counter(counter),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
        );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; counter = 0;
        #10; rst = 0;
        #10; counter = 14'd1234;
        // wait(dut.w_tick_10hz); // wait for w_tick_10hz high
        #100_000_000; $finish;

    end


endmodule
