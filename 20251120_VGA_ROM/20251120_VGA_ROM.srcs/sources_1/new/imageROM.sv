`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 11:30:45
// Design Name: 
// Module Name: imageROM
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


module imageROM(
    input  logic [$clog2(640*480)-1 : 0] addr,
    output logic [15:0]                 data
    );

    logic [15:0] mem[0:640*480-1];

    initial begin
        $readmemh("Lenna.mem", mem);
    end

    assign data = mem[addr];

endmodule
