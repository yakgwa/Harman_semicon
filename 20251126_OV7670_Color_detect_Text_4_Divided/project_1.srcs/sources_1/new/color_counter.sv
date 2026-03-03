`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 17:02:29
// Design Name: 
// Module Name: color_counter
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


module color_counter(
    input clk,
    input reset,
    input logic i_blue_detect, 
    input logic i_red_detect,  
    input logic i_frame_end,   
    output logic [7:0] o_blue_count, 
    output logic [7:0] o_red_count   
);

    reg [7:0] blue_count_reg;
    reg [7:0] red_count_reg; 

    assign o_blue_count = blue_count_reg;
    assign o_red_count  = red_count_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            blue_count_reg <= 0;
            red_count_reg  <= 0; // 초기화
        end 
        else if (i_frame_end) begin
            if (i_blue_detect) begin
                blue_count_reg <= blue_count_reg + 1;
            end
            if (i_red_detect) begin 
                red_count_reg <= red_count_reg + 1;
            end
        end
    end
endmodule