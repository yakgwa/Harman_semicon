`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/18 11:30:42
// Design Name: 
// Module Name: tb_Dedicated_processor
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


module tb_Dedicated_processor();

    logic clk = 0;
    logic reseti = 1;
    logic [7:0] out;

    Dedicated_processor_revised dut(
        .clk(clk),
        .reset(reseti),
        .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        #30; reseti = 0;
        #6000;
        $display("Simulation stop");
        $stop;



    end

endmodule
