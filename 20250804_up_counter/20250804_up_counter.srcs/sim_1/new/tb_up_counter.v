`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 15:18:05
// Design Name: 
// Module Name: tb_up_counter
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


module tb_up_counter();
    reg clk;
    reg reset;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;


always #5 clk = ~clk;

initial begin
    #0;
    clk = 0;
    reset = 1;
    #10;
    reset = 0;

    #200_100_000; 
    $stop;
end


up_counter dut(
    .clk(clk),
    .reset(reset),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
    );



endmodule
