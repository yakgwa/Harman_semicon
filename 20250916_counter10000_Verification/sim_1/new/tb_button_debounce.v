`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 11:31:14
// Design Name: 
// Module Name: tb_button_debounce
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


module tb_button_debounce();
    reg clk;
    reg rst;
    reg i_btn;
    wire o_btn;

    reg random_i_btn;
    integer i = 0;

    button_debounce dut(
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;


    initial begin
        #0; clk = 0; rst = 1; i_btn = 0;
        #10; rst = 0; // #10;와 #10은 10ns delay를 주고 바꿀건지 그 전에 바꿀건지의 차이
        #10; i_btn = 1;
        #100; i_btn = 0;

        // input pattern test
        // random
        for ( i = 0; i < 256; i = i + 1) begin
            random_i_btn = $random()%2;// 괄호 사이는 모수의 갯수
            i_btn = random_i_btn;
            #10;
        end
        #10; $stop;
        
    end

endmodule
