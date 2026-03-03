`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 17:04:47
// Design Name: 
// Module Name: tb_adder_val
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


module tb_adder_val();
    reg clk;
    reg reset;
    reg [7:0] a;
    reg [7:0] b;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire led;
    
    
    adder dut(
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        reset = 1;
        a = 8'h1f; // 31
        b = 8'h30; // 48 
        #10;
        reset = 0;

        #2000000;
        $stop;        
    end
endmodule
