`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 13:24:29
// Design Name: 
// Module Name: APB_Slave
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


module APB_Slave(
    // global signals
    input logic PCLK,
    input logic PRESET,
    // APB Interface Signals
    input logic [3:0] PADDR,
    input logic PWRITE,
    input logic PENABLE,
    input logic [31:0] PWDATA,
    input logic PSEL,
    output logic [31:0] PRDATA,
    output logic PREADY
    );

    logic [31:0] reg0, reg1, reg2, reg3;

    always_ff @( posedge PCLK or posedge PRESET ) begin
        if(PRESET) begin
            reg0 <= 0;
            reg1 <= 0;
            reg2 <= 0;
            reg3 <= 0;
        end else begin
            PREADY <= 1'b0;
            if(PSEL & PENABLE) begin
                PREADY  <= 1'b1;
            end else begin
                if(PWRITE) begin
                    case(PADDR[3:2])
                        2'd0 : reg0 <= PWDATA;
                        2'd1 : reg1 <= PWDATA;
                        2'd2 : reg2 <= PWDATA;
                        2'd3 : reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case(PADDR[3:2])
                        2'd0 : PRDATA <= reg0;
                        2'd1 : PRDATA <= reg1;
                        2'd2 : PRDATA <= reg2;
                        2'd3 : PRDATA <= reg3;
                    endcase
                end
            end
        end
    end
endmodule
