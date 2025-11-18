`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 11:44:50
// Design Name: 
// Module Name: tb_gates
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


// module tb_gates();
//     reg a;
//     reg b;
//     wire z0;
//     wire z1;
//     wire z2;
//     wire z3;
//     wire z4;
//     wire z5;

//     integer i, j;

//     gates dut(
//         .a(a),
//         .b(b),
//         .z0(z0),
//         .z1(z1),
//         .z2(z2),
//         .z3(z3),
//         .z4(z4),
//         .z5(z5)
//     );

//     // initial begin
//     //     #0 a = 0; b = 0;
//     //     #10 a= 1; b = 0;
//     //     #10 a= 0; b = 1;
//     //     #10 a= 1; b = 1;
//     // end

//     initial begin
//         for (i = 0; i < 2; i = i + 1) begin
//             for (j = 0; j < 2; j = j + 1) begin
//                 a = i;
//                 b = j;
//                 #10;
//             end
//         end

//         $finish;
//     end
// endmodule

module tb_counter();
    reg clk;
    reg rst;
    wire [3:0] o_count;

    counter dut(
        .clk(clk),
        .rst(rst),
        .o_count(o_count)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1;
        #10; rst = 0;
        #100; $finish;
    end

endmodule
