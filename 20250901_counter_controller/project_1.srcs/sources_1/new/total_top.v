`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/01 08:56:41
// Design Name: 
// Module Name: total_top
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


module total_top(
    input clk,
    input rst,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    input enable,
    input clear,
    input mode
    );

    wire [13:0] w_count;

counter_top U_COUNTER_TOP(
    .clk(clk),
    .rst(rst),
    .o_count(w_count),
    .enable(enable),
    .clear(clear),
    .mode(mode)
    );


fnd_controller U_FND_CONTROLLER(
    .clk(clk),
    .rst(rst),
    .counter(w_count),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
    );

endmodule
