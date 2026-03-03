`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/18 11:56:03
// Design Name: 
// Module Name: tb_memory
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


module tb_memory();
    reg clk;
    reg [9:0] addr;
    reg [31:0] wdata;
    reg wr;
    wire [7:0] rdata;
    // reg rst;
    // reg [31:0] d;
    // wire [31:0] q;

    always #5 clk = ~clk;

    integer i = 0;

    initial begin
        #0;
        clk = 0;
        wr = 0;
        addr = 0;
        wdata = 0;

        #10;
        wr = 1;
        // write
        addr = 10;
        wdata = 8'h0a;
        #10; // 1 clock delay

        addr = 11;
        wdata = 8'h0b;
        #10; // 1 clock delay

        addr = 31;
        wdata = 8'h0c;
        #10; // 1 clock delay

        addr = 32;
        wdata = 8'h0d;
        #10; // 1 clock delay

        wr = 0;
        //read
        addr = 10;
        #10;

        addr = 11;
        #10;

        addr = 31;
        #10;        

        addr = 32;
        #10;

        #10;
        $stop;

    end


    ramip dut(
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
        );

endmodule
