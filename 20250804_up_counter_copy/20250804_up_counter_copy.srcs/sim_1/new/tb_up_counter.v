`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/05 12:18:52
// Design Name: 
// Module Name: tb_up_counter
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


module tb_up_counter();
    parameter MS = 1_000_000;
    reg clk;
    reg reset;
    reg [2:0] sw;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    always #5 clk = ~clk;

    initial begin
         #0;
         clk = 0;
         reset = 1;
         sw = 3'b000;
         #(100 * MS);
         #10;
         reset = 0;
         // run
         sw = 3'b001;
         #(400 * MS);
         // stop
         sw = 3'b000;
         #(400 * MS);     
         // clear    
         sw = 3'b010;
         #(400 * MS);    
         // up count run    
         sw = 3'b101;
         #(400 * MS);


         $stop;
    end

    up_counter dut(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
