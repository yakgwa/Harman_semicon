`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/09 13:13:07
// Design Name: 
// Module Name: sram
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


module sram(
    input logic clk,
    input logic rst,
    input logic wr,
    input logic [3:0] address,
    input logic [7:0] wdata,
    output logic [7:0] rdata
    );

    logic [7:0] sram [15:0];

    assign rdata = sram[address];

    always_ff@(posedge clk or posedge rst) begin
        if(rst) begin
            integer i;
            for (i = 0; i < 16; i = i + 1) begin
                sram[i] <= 8'b0;
            end
        end else begin
            if(wr) begin
                sram[address] <= wdata;
            end
        end
    end

endmodule

