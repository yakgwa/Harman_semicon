`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 15:37:23
// Design Name: 
// Module Name: adder
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
module full_adder_4(
    // input a0, b0, a1, b1, a2, b2, a3, b3, cin,
    // output cout, s0, s1, s2, s3
    input [3:0] a,
    input [3:0] b,
    input cin,
    output cout,
    output [3:0] s    
    );

wire w_cout0;
wire w_cout1;
wire w_cout2;

full_adder U_FA0(
    .a(a[0]),
    .b(b[0]),
    .cin(cin),
    .s(s[0]),
    .c(w_cout0)
);

full_adder U_FA1(
    .a(a[1]),
    .b(b[1]),
    .cin(w_cout0),
    .s(s[1]),
    .c(w_cout1)
);

full_adder U_FA2(
    .a(a[2]),
    .b(b[2]),
    .cin(w_cout1),
    .s(s[2]),
    .c(w_cout2)
);

full_adder U_FA3(
    .a(a[3]),
    .b(b[3]),
    .cin(w_cout2),
    .s(s[3]),
    .c(cout)
);

endmodule

module full_adder(
    input a, b, cin,
    output s, c
    );
    wire w_s0;
    wire w_c0;
    wire w_c1;

    assign c = w_c0 | w_c1;

half_adder U_HA0(
    .a(a), //.half_adder port
    .b(b),
    .s(w_s0), 
    .c(w_c0)
    );    

half_adder U_HA1(
    .a(w_s0), 
    .b(cin),
    .s(s), 
    .c(w_c1)
    );   


endmodule

module half_adder(
    input a, b,
    output c, s
    );

    assign s = a ^ b;
    assign c = a & b;

endmodule


