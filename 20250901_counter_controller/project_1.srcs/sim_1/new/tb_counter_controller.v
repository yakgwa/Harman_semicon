`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/01 17:46:40
// Design Name: 
// Module Name: tb_counter_controller
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


module tb_counter_controller();
    parameter MS = 100_000 *10;
    reg clk;
    reg rst;
    wire o_enable;
    wire o_clear;
    wire o_mode;
    reg enable;
    reg clear;
    reg mode;
    integer i = 0;

    counter_controller dut(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear(clear),
        .mode(mode),
        .o_enable(o_enable),
        .o_clear(o_clear),
        .o_mode(o_mode)
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
        #(10*MS);
        enable = 1;
        #(10*MS);        
        clear = 1;
        #(10*MS);
        clear = 0;
        #(10*MS);
        mode = 1;
        #(10*MS);
        enable = 0;
        #(10*MS);
        // for( i = 0; i < 10; i = i + 1) begin
        //     wait(dut.U_FND_CONTROLLER.w_clk_1khz);
        // end
        $stop;
    end

endmodule