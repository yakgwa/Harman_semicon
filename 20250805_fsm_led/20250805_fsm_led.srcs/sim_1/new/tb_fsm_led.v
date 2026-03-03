`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/05 16:43:47
// Design Name: 
// Module Name: tb_fsm_led
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


module tb_fsm_led();
    reg clk;
    reg reset;
    reg sw;
    wire [1:0] led;

    always #5 clk = ~clk;

    initial begin
         #0;
         clk = 0;
         reset = 1;
         #10;
         reset = 0;
         #5;
         sw = 1'b1;
         #10;
         sw = 1'b0;
         #10;
         $stop;

    end


    fsm_led U_FSM_LED(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
        );


endmodule
