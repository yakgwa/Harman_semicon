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
    output logic [2:0] strb,
    output logic buswe,
    output logic [7:0] busAddr,
    output logic [31:0] buswData,
    input logic [31:0] busrData
    );

    logic regFileWe;
    logic [3:0] aluControl;
    logic aluSrcMuxSel;
    logic [2:0] regSrcMuxSel;

    ControlUnit U_ControlUnit(
        .instrCode(instrCode),
        .regFileWe(regFileWe),
        .aluSrcMuxSel(aluSrcMuxSel),
        .regSrcMuxSel(regSrcMuxSel),
        .aluControl(aluControl),
        .strb(strb),
        .buswe(buswe)
    );
    
    DataPath U_DataPath(
        .clk(clk),
        .reset(reset),
        .instrCode(instrCode),
        .regFileWe(regFileWe),
        .aluSrcMuxSel(aluSrcMuxSel),
        .regSrcMuxSel(regSrcMuxSel),
        .aluControl(aluControl),
        .instrMemAddr(instrMemAddr),
        .busAddr(busAddr),
        .buswData(buswData),
        .busrData(busrData)
    );

endmodule
