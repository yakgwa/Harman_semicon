`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 16:33:05
// Design Name: 
// Module Name: RAM
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


module RAM(
    input logic clk,
    input logic [2:0] strb,
    input logic we,
    input logic [7:0] addr,
    output logic [31:0] rData,
    input logic [31:0] wData
    );

    logic [7:0] mem[0:2**8-1];

    always_ff @( posedge clk ) begin 
        if(we) begin
            mem[addr]<= mem[addr];
            case(strb)
                3'b000 : begin
                        mem[addr+0] <= wData[7:0];
                end
                3'b001 : begin
                        mem[addr+0] <= wData[7:0]; 
                        mem[addr+1] <= wData[15:8];
                end
                3'b010 : begin
                        mem[addr+0] <= wData[7:0]; 
                        mem[addr+1] <= wData[15:8];
                        mem[addr+2] <= wData[23:16];
                        mem[addr+3] <= wData[31:24];
                end
            endcase
        end
    end   
        
    //assign rData = mem[rAddr];

    always_comb begin 
        rData = 0;
        case(strb)
            3'b000 : begin 
                    rData[7:0] = mem[addr+0];
                    rData[15:8] = 0;
                    rData[23:16] = 0;
                    rData[31:24] = 0;
            end
            3'b001 : begin 
                    rData[7:0] = mem[addr+0];
                    rData[15:8] = mem[addr+1];
                    rData[23:16] = 0;
                    rData[31:24] = 0;
            end
            3'b010 : begin 
                    rData[7:0] = mem[addr+0];
                    rData[15:8] = mem[addr+1];
                    rData[23:16] = mem[addr+2];
                    rData[31:24] = mem[addr+3];
            end
            endcase            
        end
endmodule
