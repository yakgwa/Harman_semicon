`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 10:47:57
// Design Name: 
// Module Name: tb_BMP_IMG
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
`include "CBMP.sv"

module tb_BMP_IMG();

    CBMP src;
    CBMP target;
    
    int size;
    byte imgData[640*480*3];
    
    initial begin
        src = new("suzy_640x480x3.bmp", "rb");
        target = new("target_640x480x3.bmp", "wb");
        
        src.read();
        imgData = src.bmpImgData;
        // Img sinal processing
        // ...
        // ..
        
        target.write(src.bmpHeader, $size(src.bmpHeader));
        target.write(imgData, $size(imgData));
        
        src.close();
        target.close();
        
        $finish;
        
    end

endmodule
