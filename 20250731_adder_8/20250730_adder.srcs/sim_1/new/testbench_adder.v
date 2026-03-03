`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/31 11:31:40
// Design Name: 
// Module Name: testbench_adder
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


module testbench_adder();
    reg [7:0] a;
    reg [7:0] b;
    //reg cin;
    wire cout;
    wire [7:0] s;

full_adder_8 dut(
    .a(a),
    .b(b),
    //.cin(cin),
    .cout(cout),
    .s(s)
);   


    integer i = 0, j = 0;

    initial begin
        #0; // start, delay 0 ns
        a = 8'b00000000; b = 8'b00000000; //cin = 1'b0;
        #1 a = 8'h01; b = 8'h00;
        #1 a = 8'h01; b = 8'h01;
        #1;

        // a = 8'b00000000; b = 8'b00000000; cin = 1'b0; #10;
        // a = 8'b00000001; b = 8'b00000001; cin = 1'b0; #10;
        // a = 8'b11111111; b = 8'b00000001; cin = 1'b0; #10;
        // a = 8'b10101010; b = 8'b01010101; cin = 1'b1; #10;
        // $finish;

         for ( i = 0; i < 256; i = i + 1) begin
            for ( j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;
                #1;
            end
        end
        $stop;
    end



// full_adder_8 dut(
//     .a(a),
//     .b(b),
//     .cin(cin),
//     .cout(cout),
//     .s(s)
// );   


endmodule
