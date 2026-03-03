`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 15:24:47
// Design Name: 
// Module Name: tb_register_file
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

interface reg_interface;
    logic clk;
    logic rst;
    logic w_en;
    logic[7:0] wdata;
    logic [7:0] rdata;
endinterface

module tb_register_file();

    reg_interface reg_interface_tb;

    logic clk = 0;

    register_file dut(
        .clk(reg_interface_tb.clk),
        .rst(),
        .w_en(),
        .wdata(),
        .rdata()
        );

        always #5 clk = ~clk;
endmodule
