`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 11:14:19
// Design Name: 
// Module Name: gates
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


// module gates(
//     input a,
//     input b,
//     output z0,
//     output z1,
//     output z2,
//     output z3,
//     output z4,
//     output z5
//     );

//     assign z0 = a & b; 
//     assign z1 = ~(a & b); 
//     assign z2 = a | b; 
//     assign z3 = ~(a | b); 
//     assign z4 = a | b; 
//     assign z5 = ~b; 

// endmodule

module counter(
    input clk,
    input rst,
    output [3:0] o_count
    );

    reg [3:0] r_counter;

    assign o_count = r_counter;


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            r_counter <= 0;
        end else begin
            if(r_counter == 9) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule