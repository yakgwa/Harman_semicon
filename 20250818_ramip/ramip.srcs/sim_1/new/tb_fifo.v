`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/18 16:40:22
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo();
    reg clk;
    reg rst;
    reg [7:0] push_data;
    reg push;
    reg pop;
    wire [7:0] pop_data;
    wire full;
    wire empty;

    always #5 clk = ~clk;

    initial begin
    #0; clk = 0; rst = 1; push = 0; pop = 0;
    #10; rst = 0;
    #10; push_data = 8'h30;  push = 1'b1;
    #10; push = 0;
    #10; push_data = 8'h31;  push = 1'b1;
    #10; push = 0;
    #10; push_data = 8'h32;  push = 1'b1;
    #10; push = 0;
    #10; push_data = 8'h33;  push = 1'b1;
    #10; push = 0;
    // #10; push = 0;
    #10;

    #10; pop = 1'b1;
    #10; pop = 1'b0;  
    #10; pop = 1'b1;
    #10; pop = 1'b0;     
    #10; pop = 1'b1;
    #10; pop = 1'b0;    
    #10; pop = 1'b1;
    #10; pop = 1'b0;  
    #10;  
        
    end



    fifo dut(
        .clk(clk),
        .rst(rst),
        .push_data(push_data),
        .push(push),
        .pop(pop),
        .pop_data(pop_data),
        .full(full),
        .empty(empty)
        );

endmodule
