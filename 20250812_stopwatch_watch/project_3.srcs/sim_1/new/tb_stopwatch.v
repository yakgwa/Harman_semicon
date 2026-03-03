`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/07 14:32:30
// Design Name: 
// Module Name: tb_stopwatch
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


module tb_stopwatch();
        reg clk; 
        reg reset; 
        reg btn_0;
        reg btn_1;
        reg [1:0] mod_sel; 
        reg Btn_L;
        reg Btn_R;
        reg Btn_U;
        reg Btn_D;
        wire [3:0] fnd_com;
        wire [7:0] fnd_data;
        wire [1:0] led;

    always #5 clk = ~clk;

    initial begin
    #0;
    clk = 0;
    reset = 1;
    Btn_L = 0;
    Btn_U = 0;
    Btn_D = 0;
    Btn_R = 0;
    mod_sel = 0;
    btn_0 = 0;
    btn_1 = 0;
    #10;
    reset = 0;
    #10; Btn_R = 1;
    #10_000; //10Usec
    Btn_R = 0; 
    #500_000_010;
    #10; Btn_R = 1;
    #100_000; //10Usec
//    Btn_R = 0;
//    #100_000_010;

    #10; btn_1 = 1;
    #100_000; //10Usec
    // btn_1 = 0;
    #500_000_010;

    // #10; Btn_L = 1;
    // #100_000; //10Usec
    // Btn_L = 0;
    // #500_000_010;
    $stop;
    end

    top dut(
        .clk(clk), 
        .reset(reset), 
        .btn_0(btn_0),
        .btn_1(btn_1),
        .mod_sel(mod_sel), 
        .Btn_L(Btn_L), 
        .Btn_R(Btn_R), 
        .Btn_U(Btn_U), 
        .Btn_D(Btn_D),
        .fnd_com(fnd_com), 
        .fnd_data(fnd_data),
        .led(led)
        );
endmodule
