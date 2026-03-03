`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 14:19:34
// Design Name: 
// Module Name: RV32I_TOP
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


module RV32I_TOP(
    input logic clk,
    input logic reset
    );

    logic [31:0] inst_opcode, instr_rAddr;
    logic [3:0] controls;
    logic wr_en;

    instr_mem U_Instr_Mem(
        .rAddr(instr_rAddr),
        .rData(inst_opcode)
    );    

    datapath U_Data_Path(
        .clk(clk),
        .reset(reset),
        .inst_opcode(inst_opcode),
        .controls(controls),
        .w_en(wr_en),
        .inst_rAddr(instr_rAddr)
    );

    control_unit U_Control_Unit(
        .instr_opcode(inst_opcode),
        .controls(controls),
        .wr_en(wr_en)
    );


endmodule
