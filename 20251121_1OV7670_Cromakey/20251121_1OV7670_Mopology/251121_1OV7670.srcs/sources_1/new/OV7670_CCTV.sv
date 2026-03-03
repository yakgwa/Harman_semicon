`timescale 1ns / 1ps
module OV7670_CCTV (
    input  logic       clk,
    input  logic       reset,
    // OV7670 side
    output logic       xclk,
    input  logic       pclk,
    input  logic       href,
    input  logic       vsync,
    input  logic [7:0] data,
    // VGA Side
    output logic       v_sync,
    output logic       h_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
);

    logic        sys_clk;
    logic        DE;
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic [16:0] rAddr;
    logic [15:0] rData;
    logic        we;
    logic [16:0] wAddr;
    logic [15:0] wData;
    logic [3:0] w_r_port, w_g_port, w_b_port;
    logic [11:0] filtered_data;
    logic [3:0] gray_r, gray_g, gray_b;

    assign xclk = sys_clk;
    
    assign r_port = w_r_port;//filtered_data[11:8];
    assign g_port = w_g_port;//filtered_data[7:4];
    assign b_port = w_b_port;//filtered_data[3:0];    

//    assign r_port = filtered_data[11:8];
//    assign g_port = filtered_data[7:4];
//    assign b_port = filtered_data[3:0];    

    pixel_clk_gen U_PXL_CLK_GEN (
        .clk  (clk),
        .reset(reset),
        .pclk (sys_clk)
    );

    VGA_Sycher U_VGA_Syncher (
        .clk(sys_clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    ChromaKey U_ChromaKey(
        .clk(sys_clk),
        .reset(reset), 
        .i_red(gray_r),
        .i_green(gray_g),
        .i_blue(gray_b),      
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE),
        .red_port(w_r_port),
        .green_port(w_g_port),
        .blue_port(w_b_port)
    );


//    Mopology_Filter U_MOPOLOGY_FILTER(
//        .clk(sys_clk),
//        .reset(reset),
//        .i_data({gray_r, gray_g, gray_b}),   
//        .x_coor(x_pixel),
//        .y_coor(y_pixel),
//        .DE(DE),
//        .o_data(filtered_data) 
//    );

//    Gray_filter U_GRAY (
//        .i_red(w_r_port),     // ImgMemReader            
//        .i_green(w_g_port),
//        .i_blue(w_b_port),
//        .o_red(gray_r),
//        .o_green(gray_g),
//        .o_blue(gray_b)
//    );
        
    ImgMemReader U_IMG_Reader (
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr(rAddr),
        .imgData(rData),
        .r_port(gray_r),//.r_port(r_port),
        .g_port(gray_g),//.g_port(g_port),
        .b_port(gray_b)//.b_port(b_port)
    );
    frame_buffer U_Frame_Buffer (
        // write side
        .wclk(pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        // read side
        .rclk(sys_clk),
        .oe(1'b1),
        .rAddr(rAddr),
        .rData(rData)
    );

    OV7670_Mem_Controller U_OV7670_Mem_Controller (
        .pclk(pclk),
        .reset(reset),
        // OV7670 Side
        .href(href),
        .vsync(vsync),
        .data(data),
        // Memory Side
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );

endmodule

//module Median3x3_Filter #(
//    parameter IMG_WIDTH = 640,
//    parameter ADDR_WIDTH = 10 // log2(IMG_WIDTH)
//)(
//    input  logic        clk,
//    input  logic        reset,
//    input  logic [3:0]  i_r,
//    input  logic [3:0]  i_g,
//    input  logic [3:0]  i_b,
//    input  logic [9:0]  x_coor,
//    input  logic [9:0]  y_coor,
//    input  logic        DE,
//    output logic [3:0]  o_r,
//    output logic [3:0]  o_g,
//    output logic [3:0]  o_b
//);

//    // === Line buffers (RGB      2  ) ===
//    logic [3:0] line1_r [0:IMG_WIDTH-1];
//    logic [3:0] line2_r [0:IMG_WIDTH-1];
//    logic [3:0] line1_g [0:IMG_WIDTH-1];
//    logic [3:0] line2_g [0:IMG_WIDTH-1];
//    logic [3:0] line1_b [0:IMG_WIDTH-1];
//    logic [3:0] line2_b [0:IMG_WIDTH-1];

//    // === 3x3        ===
//    logic [3:0] w_r[0:8];
//    logic [3:0] w_g[0:8];
//    logic [3:0] w_b[0:8];

//    logic [2:0] valid_pipeline;

//    // === Line buffer shift ===
//    always_ff @(posedge clk) begin
//        if (reset) begin
//            valid_pipeline <= 3'b0;
//        end else if (DE) begin
//            // Shift line buffers
//            line2_r[x_coor] <= line1_r[x_coor];
//            line1_r[x_coor] <= i_r;
//            line2_g[x_coor] <= line1_g[x_coor];
//            line1_g[x_coor] <= i_g;
//            line2_b[x_coor] <= line1_b[x_coor];
//            line1_b[x_coor] <= i_b;

//            // 3x3 window shift (    )
//            w_r[0] <= w_r[1]; w_r[1] <= w_r[2]; w_r[2] <= line2_r[x_coor];
//            w_r[3] <= w_r[4]; w_r[4] <= w_r[5]; w_r[5] <= line1_r[x_coor];
//            w_r[6] <= w_r[7]; w_r[7] <= w_r[8]; w_r[8] <= i_r;

//            w_g[0] <= w_g[1]; w_g[1] <= w_g[2]; w_g[2] <= line2_g[x_coor];
//            w_g[3] <= w_g[4]; w_g[4] <= w_g[5]; w_g[5] <= line1_g[x_coor];
//            w_g[6] <= w_g[7]; w_g[7] <= w_g[8]; w_g[8] <= i_g;

//            w_b[0] <= w_b[1]; w_b[1] <= w_b[2]; w_b[2] <= line2_b[x_coor];
//            w_b[3] <= w_b[4]; w_b[4] <= w_b[5]; w_b[5] <= line1_b[x_coor];
//            w_b[6] <= w_b[7]; w_b[7] <= w_b[8]; w_b[8] <= i_b;

//            valid_pipeline <= {valid_pipeline[1:0], (x_coor>=2 && y_coor>=2)};
//        end else begin
//            valid_pipeline <= {valid_pipeline[1:0], 1'b0};
//        end
//    end

//    // === Median      Լ  ===
//    function [3:0] median9(input [3:0] a0,a1,a2,a3,a4,a5,a6,a7,a8);
//        logic [3:0] arr[0:8];
//        logic [3:0] tmp;
//        integer i,j;
//        begin
//            arr[0]=a0; arr[1]=a1; arr[2]=a2;
//            arr[3]=a3; arr[4]=a4; arr[5]=a5;
//            arr[6]=a6; arr[7]=a7; arr[8]=a8;
//            // simple bubble sort
//            for(i=0;i<8;i=i+1) begin
//                for(j=0;j<8-i;j=j+1) begin
//                    if(arr[j]>arr[j+1]) begin
//                        tmp = arr[j]; arr[j]=arr[j+1]; arr[j+1]=tmp;
//                    end
//                end
//            end
//            median9 = arr[4]; // 9       ߾Ӱ 
//        end
//    endfunction

//    // === Median      ===
//    always_ff @(posedge clk) begin
//        if (reset) begin
//            o_r <= 0;
//            o_g <= 0;
//            o_b <= 0;
//        end else if (valid_pipeline[2]) begin
//            o_r <= median9(w_r[0],w_r[1],w_r[2],w_r[3],w_r[4],w_r[5],w_r[6],w_r[7],w_r[8]);
//            o_g <= median9(w_g[0],w_g[1],w_g[2],w_g[3],w_g[4],w_g[5],w_g[6],w_g[7],w_g[8]);
//            o_b <= median9(w_b[0],w_b[1],w_b[2],w_b[3],w_b[4],w_b[5],w_b[6],w_b[7],w_b[8]);
//        end
//    end

//endmodule

module Mopology_Filter #(
    parameter IMG_WIDTH = 640,
    parameter ADDR_WIDTH = 10  // log2(640) ? 10
)(
    input logic clk,
    input logic reset,
    input logic [11:0] i_data,   
    input logic [9:0] x_coor,
    input logic [9:0] y_coor,
    input logic DE,
    output logic [11:0] o_data  
);

    // Line buffers using inferred block RAM
    logic [0:0] erode_line1_ram [0:IMG_WIDTH-1];
    logic [0:0] erode_line2_ram [0:IMG_WIDTH-1];

    logic erode_read1, erode_read2;
    logic [0:0] erode_line1_pixel, erode_line2_pixel;

    // 3x3 windows
    logic erode_p11, erode_p12, erode_p13;
    logic erode_p21, erode_p22, erode_p23;
    logic erode_p31, erode_p32, erode_p33;

    logic [2:0] erode_valid_pipeline;
    logic [11:0] erode_o_data_internal;
    logic erode_oe_internal;

    logic [0:0] dilate_line1_ram [0:IMG_WIDTH-1];
    logic [0:0] dilate_line2_ram [0:IMG_WIDTH-1];
    logic [0:0] dilate_line1_pixel, dilate_line2_pixel;

    logic dilate_p11, dilate_p12, dilate_p13;
    logic dilate_p21, dilate_p22, dilate_p23;
    logic dilate_p31, dilate_p32, dilate_p33;

    logic [2:0] dilate_valid_pipeline;

    // === Erode ===
    always_ff @(posedge clk) begin
        if (reset) begin
            erode_valid_pipeline <= 3'b0;
        end else if (DE) begin
            // shift 2 lines: line2 <= line1, line1 <= new
            erode_line2_ram[x_coor] <= erode_line1_ram[x_coor];
            erode_line1_ram[x_coor] <= i_data[11]; // use MSB as binarized

            // read for 3x3 window
            erode_line2_pixel <= erode_line2_ram[x_coor];
            erode_line1_pixel <= erode_line1_ram[x_coor];

            erode_p13 <= erode_line2_pixel;
            erode_p12 <= erode_p13;
            erode_p11 <= erode_p12;

            erode_p23 <= erode_line1_pixel;
            erode_p22 <= erode_p23;
            erode_p21 <= erode_p22;

            erode_p33 <= i_data[11];
            erode_p32 <= erode_p33;
            erode_p31 <= erode_p32;

            erode_valid_pipeline <= {erode_valid_pipeline[1:0], (x_coor >= 2 && y_coor >= 2)};
        end else begin
            erode_valid_pipeline <= {erode_valid_pipeline[1:0], 1'b0};
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            erode_o_data_internal <= 12'h000;
            erode_oe_internal <= 1'b0;
        end else if (erode_valid_pipeline[2]) begin
            erode_oe_internal <= 1'b1;
            if (&{erode_p11, erode_p12, erode_p13, erode_p21, erode_p22, erode_p23, erode_p31, erode_p32, erode_p33})
                erode_o_data_internal <= 12'hFFF;
            else
                erode_o_data_internal <= 12'h000;
        end else begin
            erode_oe_internal <= 1'b0;
            erode_o_data_internal <= 12'h000;
        end
    end

    // === Dilate ===
    always_ff @(posedge clk) begin
        if (reset) begin
            dilate_valid_pipeline <= 3'b0;
        end else if (erode_oe_internal) begin
            dilate_line2_ram[x_coor] <= dilate_line1_ram[x_coor];
            dilate_line1_ram[x_coor] <= erode_o_data_internal[11];

            dilate_line2_pixel <= dilate_line2_ram[x_coor];
            dilate_line1_pixel <= dilate_line1_ram[x_coor];

            dilate_p13 <= dilate_line2_pixel;
            dilate_p12 <= dilate_p13;
            dilate_p11 <= dilate_p12;

            dilate_p23 <= dilate_line1_pixel;
            dilate_p22 <= dilate_p23;
            dilate_p21 <= dilate_p22;

            dilate_p33 <= erode_o_data_internal[11];
            dilate_p32 <= dilate_p33;
            dilate_p31 <= dilate_p32;

            dilate_valid_pipeline <= {dilate_valid_pipeline[1:0], (x_coor >= 2 && y_coor >= 2)};
        end else begin
            dilate_valid_pipeline <= {dilate_valid_pipeline[1:0], 1'b0};
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            o_data <= 12'h000;
        end else if (dilate_valid_pipeline[2]) begin
            if (|{dilate_p11, dilate_p12, dilate_p13, dilate_p21, dilate_p22, dilate_p23, dilate_p31, dilate_p32, dilate_p33})
                o_data <= 12'hFFF;
            else
                o_data <= 12'h000;
        end else begin
            o_data <= 12'h000;
        end
    end

endmodule

module Gray_filter(
    input logic        mode_sel,
    input logic [3:0] i_red,
    input logic [3:0] i_green,
    input logic [3:0] i_blue,
    output logic [3:0] o_red,
    output logic [3:0] o_green,
    output logic [3:0] o_blue
    );
    
    logic [11:0] gray;
    


    assign gray = 51 * i_red + 179 * i_green + 26 * i_blue;
    
     assign o_red = gray[11:8];
     assign o_green = gray[11:8];
     assign o_blue = gray[11:8];
    

endmodule
