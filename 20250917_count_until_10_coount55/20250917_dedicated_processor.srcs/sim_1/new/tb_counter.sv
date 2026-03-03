`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/17 15:34:40
// Design Name: 
// Module Name: tb_counter
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


module tb_counter();

    logic clk = 0, reset = 1;
    logic [7:0] out = 0;

    count55 dut(
        .clk(clk),
        .reset(reset),
        .out(out)
        );    

    always #5 clk = ~clk;

    initial begin
        #0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        #1000;
        $stop;
    end


endmodule
