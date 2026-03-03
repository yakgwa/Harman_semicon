`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/01 09:02:58
// Design Name: 
// Module Name: tb_top
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


module tb_top();
    // parameter MS = 10_000_000*10;
    // parameter ms = 10_000;
    // reg clk;
    // reg rst;
    // wire [3:0] fnd_com;
    // wire [7:0] fnd_data;   
    // integer i;


    // total_top dut(
    //     .clk(clk),
    //     .rst(rst),
    //     .fnd_com(fnd_com),
    //     .fnd_data (fnd_data)
    // );   

    // always #5 clk = ~clk;

    // initial begin
    //     #0; clk = 0; rst = 1;
    //     #10; rst = 0;
    //     #1000;
    //     //#(100*MS); // 1sec
    //     for (i = 0; i < 100; i = i + 1) begin
    //         wait(dut.U_FND_CONTROLLER.w_clk_1khz);
    //     end
    //     $stop;

    // end

    parameter MS = 100_000 *10;
    reg clk;
    reg rst;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    reg enable;
    reg clear;
    reg mode;
    integer i = 0;

    total_top dut(
        .clk(clk),
        .rst(rst),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .enable(enable),
        .clear(clear),
        .mode(mode)
        );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        enable = 0;
        clear = 0;
        mode = 0;
        #10;
        #10;
        rst = 0;
        #10;
        enable = 1;
        #(500*MS);
        clear = 1;
        #100;
        clear = 0;
        #(500*MS);
        mode = 1;
        #(500*MS);
        enable = 0;
        for( i = 0; i < 10; i = i + 1) begin
            wait(dut.U_FND_CONTROLLER.w_clk_1khz);
        end
        $stop;
    end

endmodule
