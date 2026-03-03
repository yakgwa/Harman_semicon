`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/01 16:06:25
// Design Name: 
// Module Name: tb_adder
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


module tb_adder();
    reg clk, reset;
    reg [7:0] bcd;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    fnd_controller dut(
    
        .clk(clk),
        .reset(reset),
        .bcd(bcd),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );
    // period 10nsec, 100Mhz
    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        reset = 1;
        bcd = 8'h7f;
        #10;
        reset = 0;

        #1_000_000;
        $stop;

    end


endmodule
