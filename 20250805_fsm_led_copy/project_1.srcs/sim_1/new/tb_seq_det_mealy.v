`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/06 11:37:14
// Design Name: 
// Module Name: tb_seq_det_mealy
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


module tb_seq_det_mealy();
    reg clk;
    reg rst;
    reg din_bit;
    wire dout_bit;


    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        din_bit = 0;

        #15 rst = 0;

        #5 din_bit = 1;
        #30 din_bit = 0;
        #10 din_bit = 1;
        #20 din_bit = 0;
        #40 din_bit = 1;
        #10 din_bit = 0;
        #30 din_bit = 1;
        #40 din_bit = 0;
        #10 din_bit = 1;
        #10 din_bit = 0;
        #30 din_bit = 1;
        #20 din_bit = 0;
        #100 $finish;
    end


seq_det_mealy U_SEQ_DET_MEALY(
    .clk(clk),
    .rst(rst),
    .din_bit(din_bit),
    .dout_bit(dout_bit)
    );
endmodule
