`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 15:24:22
// Design Name: 
// Module Name: register_file
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


module register_file(
    input logic clk,
    input logic rst,
    input logic w_en,
    input logic [7:0] wdata,
    output logic [7:0] rdata
    );

    logic [7:0] register_file;

    assign rdata = register_file;

    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            register_file <= 0;
        end else begin
            if(w_en) begin
                register_file <= wdata;
            end
            // end else begin
            //     rdata <= register_file;
            // end
        end
    end


endmodule
