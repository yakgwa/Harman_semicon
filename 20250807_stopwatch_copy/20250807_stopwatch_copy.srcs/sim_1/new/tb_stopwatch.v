`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/07 14:32:30
// Design Name: 
// Module Name: tb_stopwatch
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


module tb_stopwatch();
    reg clk;
    reg reset;
    reg Btn_L;
    reg Btn_R;
    wire [3:0] fnd_com;
    wire  [7:0] fnd_data;

    always #5 clk = ~clk;

    initial begin
    #0;
    clk = 0;
    reset = 1;
    #20;
    reset = 0;

    #1100_000_000; // 10_000_000ns = 10ms
    $stop;
    end

    stopwatch dut(
        .clk(clk),
        .reset(reset),
        .Btn_L(Btn_L),
        .Btn_R(Btn_R),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );
endmodule
