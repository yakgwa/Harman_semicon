`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 11:32:04
// Design Name: 
// Module Name: ImgROM
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


module ImgROM (
    input  logic [$clog2(320*240)-1:0] addr,
    output logic [               15:0] data
);
    logic [15:0] mem[0:320*240-1];

    initial begin
        $readmemh("lenna_320x240.mem", mem);
    end

    assign data = mem[addr];
endmodule
