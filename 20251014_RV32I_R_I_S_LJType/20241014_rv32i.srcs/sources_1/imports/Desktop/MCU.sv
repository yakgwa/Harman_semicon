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

    logic [31:0] instrCode, instrMemAddr;
    logic [2:0] strb;
    logic [7:0] busAddr;
    logic [31:0] buswData, busrData;
    logic buswe;

    ROM U_ROM(
        .addr(instrMemAddr),
        .data(instrCode)
    );

    CPU_RV32I U_RV32I(
        .clk(clk),
        .reset(reset),
        .instrCode(instrCode),
        .instrMemAddr(instrMemAddr),
        .strb(strb),
        .buswe(buswe),
        .busAddr(busAddr),
        .buswData(buswData),
        .busrData(busrData)            
    );

    RAM U_RAM(
        .clk(clk),
        .strb(strb),
        .we(buswe),
        .addr(busAddr),
        .rData(busrData),
        .wData(buswData)
    );


endmodule
