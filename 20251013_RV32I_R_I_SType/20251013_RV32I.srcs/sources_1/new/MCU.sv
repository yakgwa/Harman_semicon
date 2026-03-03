`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 14:20:44
// Design Name: 
// Module Name: MCU
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


module MCU(
    input logic clk,
    input logic reset
    );

    logic [31:0] instrCode, instrMemAddr, dWdata;
    logic [7:0] dWaddr;
    logic [1:0] strb;
    logic datamemWe;

    ROM U_ROM(
        .addr(instrMemAddr),
        .data(instrCode)
    );

    CPU_RV32I U_RV32I(
        .clk(clk),
        .reset(reset),
        .instrCode(instrCode),
        .instrMemAddr(instrMemAddr),
        .datamemWe(datamemWe),
        .strb(strb),
        .dWaddr(dWaddr),
        .dWdata(dWdata)        
    );

    RAM U_RAM(
        .clk(clk),
        .strb(strb),
        .we(datamemWe),
        .rAddr(),
        .rData(),
        .wAddr(dWaddr),
        .wData(dWdata)  
    );  

endmodule
