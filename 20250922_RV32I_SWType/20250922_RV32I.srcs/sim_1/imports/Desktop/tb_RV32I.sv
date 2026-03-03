`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 14:32:56
// Design Name: 
// Module Name: tb_RV32I
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


module tb_RV32I();
    logic clk = 0, reset = 1;

    RV32I_TOP dut(.*);

    always #5 clk = ~clk;

    initial begin
        #30; reset = 0;
        #100; $stop;
    end



endmodule
