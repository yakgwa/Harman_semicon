`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/22 15:21:47
// Design Name: 
// Module Name: Data_Mem
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


module Data_Mem(
    input logic clk,
    input logic d_wr_en,
    input logic [31:0] dAddr,
    input logic [31:0] dWdata,
    output logic [31:0] dRdata
    );

    logic [31:0] data_mem [0:15];

    initial begin
        for (int i = 0; i < 16; i++) begin
            data_mem[i] = i+32'h8765_4321;
        end
    end

    always_ff@(posedge clk) begin
        if(d_wr_en) data_mem[dAddr] <= dWdata;
    end

    assign dRdata = data_mem[dAddr];

endmodule
