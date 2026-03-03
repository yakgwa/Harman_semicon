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

    logic [$clog2(320*240)-1 : 0] addr;
    logic [                 15:0] imgData;
    logic [                  3:0] r_port;
    logic [                  3:0] g_port;
    logic [                  3:0] b_port;

    logic [3:0] i_r;
    logic [3:0] i_g;
    logic [3:0] i_b;
    logic [3:0] o_r;
    logic [3:0] o_g;
    logic [3:0] o_b;


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
        .r_port(i_r),
        .g_port(i_g),
        .b_port(i_b)
    );

    Gray_filter U_Gray_filter(
        .i_r(i_r),
        .i_g(i_g),
        .i_b(i_b),
        .o_r(o_r),
        .o_g(o_g),
        .o_b(o_b)
    );


    monitor_bmp U_Monitor(
        .clk(clk),
        .reset(reset),
        .DE(DE),
        .v_sync(v_sync),
        .h_sync(h_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .r_port(o_r),
        .g_port(o_g),   
        .b_port(o_b)
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
    input  logic [$clog2(320*240)-1 : 0] waddr,
    //input  logic                           re,
    //input  logic [$clog2(640*480*3)-1 : 0] raddr,
    output logic                   [15 : 0] wdata
    //output logic [$clog2(640*480*3)-1 : 0] rdata
    );
    
    byte mem[320*240*3];
    
    CBMP src;
    
    initial begin
        src = new("suzy_640x480x4.bmp", "rb");
        src.read();
        mem = src.bmpImgData;
        src.close();
     end
       
     always_ff@(posedge clk) begin
        wdata[15:12] <= mem[waddr*3+2][7:4]; // R 상위 4비트
        wdata[11:8]  <= mem[waddr*3+1][7:4]; // G 상위 4비트
        wdata[7:4]   <= mem[waddr*3+0][7:4]; // B 상위 4비트
        wdata[3:0]   <= 0;                    // 남는 4비트는 0
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
    input  logic                   [3 : 0] r_port,
    input  logic                   [3 : 0] g_port,   
    input  logic                   [3 : 0] b_port
    );
    
    byte mem[320*240*3];

     always_ff@(posedge clk) begin
        if(DE) begin
            mem[(320*y_pixel + x_pixel)*3+2] <= {r_port,r_port}; // R
            mem[(320*y_pixel + x_pixel)*3+1] <= {g_port,g_port}; // G
            mem[(320*y_pixel + x_pixel)*3+0] <= {b_port,b_port}; // B
         end
     end    
     
     CBMP headerSrc;
     CBMP target;
     
     initial begin
        #10;
        headerSrc = new("suzy_640x480x4.bmp", "rb");
        target = new("target.bmp", "wb");
        headerSrc.read();
        @(negedge v_sync);
        target.write(headerSrc.bmpHeader, $size(headerSrc.bmpHeader));
        target.write(mem, $size(mem));        
        
        headerSrc.close();
        target.close();
     end
    
endmodule