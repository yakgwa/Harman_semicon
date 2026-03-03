`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 14:07:17
// Design Name: 
// Module Name: CPU_RV32I
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


module CPU_RV32I(
    input logic clk,
    input logic reset,
    input logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    output logic datamemWe,
    output logic [1:0] strb,
    output logic [7:0] dWaddr,
    output logic [31:0] dWdata  
    );

    logic regFileWe;
    logic [3:0] aluControl;
    logic aluSrcMuxSel;

    ControlUnit U_ControlUnit(
        .instrCode(instrCode),
        .regFileWe(regFileWe),
        .aluSrcMuxSel(aluSrcMuxSel),
        .aluControl(aluControl),
        .datamemWe(datamemWe),
        .strb(strb)
    );
    DataPath U_DataPath(
        .clk(clk),
        .reset(reset),
        .instrCode(instrCode),
        .regFileWe(regFileWe),
        .aluSrcMuxSel(aluSrcMuxSel),
        .aluControl(aluControl),
        .instrMemAddr(instrMemAddr),
        .dWaddr(dWaddr),
        .dWdata(dWdata)        
    );

    // ControlUnit U_ControlUnit(
    //     .instrCode(instrCode),
    //     .regFileWe(regFileWe),
    //     .aluControl(aluControl)
    // );

    // DataPath U_DataPath(
    //     .clk(clk),
    //     .reset(reset),
    //     .instrCode(instrCode),
    //     .regFileWe(regFileWe),
    //     .aluControl(aluControl),
    //     .instrMemAddr(instrMemAddr)
    // );

endmodule
