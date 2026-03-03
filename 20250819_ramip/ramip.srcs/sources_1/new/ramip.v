`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/18 11:51:10
// Design Name: 
// Module Name: ramip
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
module ramip(
    input clk,
    input [9:0] addr,
    input [7:0] wdata,
    input wr,
    output reg [7:0] rdata

);

    reg [7:0] ram[0:1023];

    // output CL
    // assign rdata = ram[addr];

    always@(posedge clk) begin
        if(wr) begin
            // write
            ram[addr] <= wdata;
        end else begin
            // read SL
            rdata <= ram[addr];
        end
    end
endmodule

module register(
    input clk,
    input rst,
    input [31:0] d,
    output [31:0] q
    );

    reg [31:0] q_reg;

    assign q = q_reg;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= d;
        end        
    end



endmodule
