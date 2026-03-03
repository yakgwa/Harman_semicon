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

/*
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
*/

module tb_bmp_filter();

    logic       clk;
    logic       reset;
    logic       h_sync;
    logic       v_sync;
    logic       DE;
    logic [9:0] x_pixel;
    logic [9:0] y_pixel;

    logic [$clog2(640*480)-1 : 0] addr;
    logic [                 23:0] imgData;
    logic [                  7:0] r_port;
    logic [                  7:0] g_port;
    logic [                  7:0] b_port;

    always #5 clk =~clk;
    
     VGA_Sycher U_Syncher(
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );    
    
    ImgMemReader U_Reader(
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr(addr),
        .imgData(imgData),
        .r_port(r_port),
        .g_port(g_port),
        .b_port(b_port)
    );

    monitor_bmp U_Monitor(
        .clk(clk),
        .reset(reset),
        .DE(DE),
        .v_sync(v_sync),
        .h_sync(h_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .r_port(r_port),
        .g_port(g_port),   
        .b_port(b_port)
        );

    imgRom U_IMGROM(
        .clk(clk),
        .waddr(addr),
        .wdata(imgData)
        );

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        @(posedge v_sync);
        $finish;
     end

endmodule

module imgRom(
    input  logic                           clk,
    //input  logic                           we,
    input  logic [$clog2(640*480)-1 : 0] waddr,
    //input  logic                           re,
    //input  logic [$clog2(640*480*3)-1 : 0] raddr,
    output logic                   [23 : 0] wdata
    //output logic [$clog2(640*480*3)-1 : 0] rdata
    );
    
    byte mem[640*480*3];
    
    CBMP src;
    
    initial begin
        src = new("suzy_640x480x3.bmp", "rb");
        src.read();
        mem = src.bmpImgData;
        src.close();
     end
       
     always_ff@(posedge clk) begin
         wdata[7:0] <= mem[waddr*3+0];
         wdata[15:8] <= mem[waddr*3+1];
         wdata[23:16] <= mem[waddr*3+2];
     end

endmodule

module monitor_bmp(
    input  logic                           clk,
    input  logic                           reset,
    input  logic                           DE,
    input  logic                           v_sync,
    input  logic                           h_sync,
    input  logic                   [9 : 0] x_pixel,
    input  logic                   [9 : 0] y_pixel,
    input  logic                   [7 : 0] r_port,
    input  logic                   [7 : 0] g_port,   
    input  logic                   [7 : 0] b_port
    );
    
    byte mem[640*480*3];

     always_ff@(posedge clk) begin
        if(DE) begin
             mem[(640*y_pixel + x_pixel)*3+2] <= r_port;
             mem[(640*y_pixel + x_pixel)*3+1] <= g_port;
             mem[(640*y_pixel + x_pixel)*3+0] <= b_port;
         end
     end    
     
     CBMP headerSrc;
     CBMP target;
     
     initial begin
        #10;
        headerSrc = new("suzy_640x480x3.bmp", "rb");
        target = new("target.bmp", "wb");
        headerSrc.read();
        @(negedge v_sync);
        target.write(headerSrc.bmpHeader, $size(headerSrc.bmpHeader));
        target.write(mem, $size(mem));        
        
        headerSrc.close();
        target.close();
     end
    
endmodule