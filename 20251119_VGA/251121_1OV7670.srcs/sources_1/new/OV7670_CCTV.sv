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
    output logic [3:0] b_port,
    // SCCB Core
    input  logic       start,
    output logic       scl,
    inout  logic       sda
      
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

    logic [3:0] text_r, text_g, text_b;
    logic text_on;
    
    logic w_blue_detect;
    logic w_red_detect;

    assign xclk = sys_clk;
    
//    assign r_port = gray_r;//filtered_data[11:8];
//    assign g_port = gray_g;//filtered_data[7:4];
//    assign b_port = gray_b;//filtered_data[3:0];    
    
    assign r_port = (text_on) ? text_r : w_r_port;
    assign g_port = (text_on) ? text_g : w_g_port;
    assign b_port = (text_on) ? text_b : w_b_port;

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

//    Laplacian_Filter U_Laplacian_Filter(
//            .clk(sys_clk),
//            .reset(reset),
//            .i_data({gray_r, gray_g, gray_b}),   
//            .x_pixel(x_pixel),
//            .y_pixel(y_pixel),
//            .DE(DE),
//            .o_data(filtered_data)
//        );

    color_detect U_COLOR_DETECT(
        .clk(sys_clk),
        .reset(reset),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .R(w_r_port),
        .G(w_g_port),
        .B(w_b_port),
        .blue_detect(w_blue_detect),
        .red_detect(w_red_detect)
    );
 
     text_display U_TEXT (
        .clk(sys_clk),
        .DE(DE),
        .blue_detect(w_blue_detect),
        .red_detect(w_red_detect),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .red(text_r),
        .green(text_g),
        .blue(text_b),
        .text_on(text_on)
    );   

//    noise_reduction_filter U_noise_reduction_filter(
//        .clk(sys_clk),
//        .reset(reset),
//        .i_data({gray_r, gray_g, gray_b}),   
//        .x_pixel(x_pixel),
//        .y_pixel(y_pixel),
//        .DE(DE),
//        .o_data(filtered_data) 
//    );

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
        .r_port(w_r_port),//.r_port(r_port),
        .g_port(w_g_port),//.g_port(g_port),
        .b_port(w_b_port)//.b_port(b_port)
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

    SCCB_core U_SCCB_Core(
        .clk(clk),
        .reset(reset),
        .initial_start(start),
        .sioc(scl),
        .siod(sda)
    );

endmodule

module Median3x3_Filter #(
    parameter IMG_WIDTH = 640,
    parameter ADDR_WIDTH = 10
)(
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  i_r,
    input  logic [3:0]  i_g,
    input  logic [3:0]  i_b,
    input  logic [9:0]  x_coor,
    input  logic [9:0]  y_coor,
    input  logic        DE,
    output logic [3:0]  o_r,
    output logic [3:0]  o_g,
    output logic [3:0]  o_b
);

    // --- Line buffers (BRAM inferred) ---
    (* ram_style = "block" *) logic [3:0] line1_r [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [3:0] line2_r [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [3:0] line1_g [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [3:0] line2_g [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [3:0] line1_b [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [3:0] line2_b [0:IMG_WIDTH-1];

    // --- Synchronous read outputs ---
    logic [3:0] line1_r_out, line2_r_out;
    logic [3:0] line1_g_out, line2_g_out;
    logic [3:0] line1_b_out, line2_b_out;

    // --- 3x3 window ---
    logic [3:0] w_r[0:8];
    logic [3:0] w_g[0:8];
    logic [3:0] w_b[0:8];

    logic [2:0] valid_pipeline;

    // --- Line buffer logic: BRAM read/write ---
    always_ff @(posedge clk) begin
        if (reset) begin
            valid_pipeline <= 0;
        end else if (DE) begin

            // --- synchronous read first ---
            line1_r_out <= line1_r[x_coor];
            line2_r_out <= line2_r[x_coor];
            line1_g_out <= line1_g[x_coor];
            line2_g_out <= line2_g[x_coor];
            line1_b_out <= line1_b[x_coor];
            line2_b_out <= line2_b[x_coor];

            // --- write after read (BRAM pattern) ---
            line1_r[x_coor] <= i_r;
            line2_r[x_coor] <= line1_r_out;

            line1_g[x_coor] <= i_g;
            line2_g[x_coor] <= line1_g_out;

            line1_b[x_coor] <= i_b;
            line2_b[x_coor] <= line1_b_out;

            // --- 3√ó3 shift window ---
            // R
            w_r[0] <= w_r[1];   w_r[1] <= w_r[2];   w_r[2] <= line2_r_out;
            w_r[3] <= w_r[4];   w_r[4] <= w_r[5];   w_r[5] <= line1_r_out;
            w_r[6] <= w_r[7];   w_r[7] <= w_r[8];   w_r[8] <= i_r;

            // G
            w_g[0] <= w_g[1];   w_g[1] <= w_g[2];   w_g[2] <= line2_g_out;
            w_g[3] <= w_g[4];   w_g[4] <= w_g[5];   w_g[5] <= line1_g_out;
            w_g[6] <= w_g[7];   w_g[7] <= w_g[8];   w_g[8] <= i_g;

            // B
            w_b[0] <= w_b[1];   w_b[1] <= w_b[2];   w_b[2] <= line2_b_out;
            w_b[3] <= w_b[4];   w_b[4] <= w_b[5];   w_b[5] <= line1_b_out;
            w_b[6] <= w_b[7];   w_b[7] <= w_b[8];   w_b[8] <= i_b;

            valid_pipeline <= {valid_pipeline[1:0], (x_coor >= 2 && y_coor >= 2)};
        end else begin
            valid_pipeline <= {valid_pipeline[1:0], 1'b0};
        end
    end

    // --- Median function ---
    function [3:0] median9(input [3:0] a0,a1,a2,a3,a4,a5,a6,a7,a8);
        logic [3:0] arr[0:8];
        logic [3:0] tmp;
        integer i,j;
        begin
            arr[0]=a0; arr[1]=a1; arr[2]=a2;
            arr[3]=a3; arr[4]=a4; arr[5]=a5;
            arr[6]=a6; arr[7]=a7; arr[8]=a8;

            for(i=0; i<8; i++) begin
                for(j=0; j<8-i; j++) begin
                    if(arr[j] > arr[j+1]) begin
                        tmp = arr[j];
                        arr[j] = arr[j+1];
                        arr[j+1] = tmp;
                    end
                end
            end
            median9 = arr[4];
        end
    endfunction

    // --- output stage ---
    always_ff @(posedge clk) begin
        if (reset) begin
            o_r <= 0;
            o_g <= 0;
            o_b <= 0;
        end else if (valid_pipeline[2]) begin
            o_r <= median9(w_r[0],w_r[1],w_r[2],w_r[3],w_r[4],w_r[5],w_r[6],w_r[7],w_r[8]);
            o_g <= median9(w_g[0],w_g[1],w_g[2],w_g[3],w_g[4],w_g[5],w_g[6],w_g[7],w_g[8]);
            o_b <= median9(w_b[0],w_b[1],w_b[2],w_b[3],w_b[4],w_b[5],w_b[6],w_b[7],w_b[8]);
        end
    end

endmodule

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

//module noise_reduction_filter #(
//    parameter IMG_WIDTH = 640
//)(
//    input  logic       clk,
//    input  logic       reset,
    
//    //  »º   ‘∑ 
//    input  logic [3:0] pixel_r_i,
//    input  logic [3:0] pixel_g_i,
//    input  logic [3:0] pixel_b_i,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    input  logic       DE,
    
//    //    Õµ   »º     
//    output logic [3:0] pixel_r_o,
//    output logic [3:0] pixel_g_o,
//    output logic [3:0] pixel_b_o
//);

//    // ===      4 »º       ‰∏? ===
//    logic [3:0] prev_r[0:3];
//    logic [3:0] prev_g[0:3];
//    logic [3:0] prev_b[0:3];

//    always_ff @(posedge clk) begin
//        if (reset) begin
//            prev_r[0] <= 0; prev_r[1] <= 0; prev_r[2] <= 0; prev_r[3] <= 0;
//            prev_g[0] <= 0; prev_g[1] <= 0; prev_g[2] <= 0; prev_g[3] <= 0;
//            prev_b[0] <= 0; prev_b[1] <= 0; prev_b[2] <= 0; prev_b[3] <= 0;
//        end else if (DE) begin
//            prev_r[3] <= prev_r[2]; prev_r[2] <= prev_r[1]; prev_r[1] <= prev_r[0]; prev_r[0] <= pixel_r_i;
//            prev_g[3] <= prev_g[2]; prev_g[2] <= prev_g[1]; prev_g[1] <= prev_g[0]; prev_g[0] <= pixel_g_i;
//            prev_b[3] <= prev_b[2]; prev_b[2] <= prev_b[1]; prev_b[1] <= prev_b[0]; prev_b[0] <= pixel_b_i;
//        end
//    end

//    // ===               ===
//    logic is_step_r, is_step_g, is_step_b;
//    always_comb begin
//        is_step_r = DE && (pixel_r_i == prev_r[0]) && (prev_r[0] == prev_r[1]) && (prev_r[1] == prev_r[2]) && (prev_r[2] == prev_r[3]);
//        is_step_g = DE && (pixel_g_i == prev_g[0]) && (prev_g[0] == prev_g[1]) && (prev_g[1] == prev_g[2]) && (prev_g[2] == prev_g[3]);
//        is_step_b = DE && (pixel_b_i == prev_b[0]) && (prev_b[0] == prev_b[1]) && (prev_b[1] == prev_b[2]) && (prev_b[2] == prev_b[3]);
//    end

//    logic step_end_r, step_end_g, step_end_b;
//    always_comb begin
//        step_end_r = is_step_r && (pixel_r_i != prev_r[0]);
//        step_end_g = is_step_g && (pixel_g_i != prev_g[0]);
//        step_end_b = is_step_b && (pixel_b_i != prev_b[0]);
//    end

//    // ===       »≠      ===
//    logic [3:0] smooth_r, smooth_g, smooth_b;
//    always_comb begin
//        // R √§  
//        if (step_end_r) smooth_r = (prev_r[0] + pixel_r_i) >> 1;
//        else if (is_step_r) smooth_r = prev_r[0];
//        else smooth_r = pixel_r_i;

//        // G √§  
//        if (step_end_g) smooth_g = (prev_g[0] + pixel_g_i) >> 1;
//        else if (is_step_g) smooth_g = prev_g[0];
//        else smooth_g = pixel_g_i;

//        // B √§  
//        if (step_end_b) smooth_b = (prev_b[0] + pixel_b_i) >> 1;
//        else if (is_step_b) smooth_b = prev_b[0];
//        else smooth_b = pixel_b_i;
//    end

//    // ===     ===
//    always_ff @(posedge clk) begin
//        if (reset) begin
//            pixel_r_o <= 0;
//            pixel_g_o <= 0;
//            pixel_b_o <= 0;
//        end else if (DE) begin
//            pixel_r_o <= smooth_r;
//            pixel_g_o <= smooth_g;
//            pixel_b_o <= smooth_b;
//        end
//    end

//endmodule

module noise_reduction_filter #(
    parameter IMG_WIDTH = 640
)(
    input  logic       clk,
    input  logic       reset,
    
    // 12  ∆Æ RGB  »º   ‘∑ 
    input  logic [11:0] i_data,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic        DE,
    
    // 12  ∆Æ RGB  »º     
    output logic [11:0] o_data
);

    // 12  ∆Æ   √§ Œ∑   –∏ 
    logic [3:0] pixel_r_i = i_data[11:8];
    logic [3:0] pixel_g_i = i_data[7:4];
    logic [3:0] pixel_b_i = i_data[3:0];

    // ===      4 »º       ‰∏? ===
    logic [3:0] prev_r[0:3];
    logic [3:0] prev_g[0:3];
    logic [3:0] prev_b[0:3];

    always_ff @(posedge clk) begin
        if (reset) begin
            prev_r[0] <= 0; prev_r[1] <= 0; prev_r[2] <= 0; prev_r[3] <= 0;
            prev_g[0] <= 0; prev_g[1] <= 0; prev_g[2] <= 0; prev_g[3] <= 0;
            prev_b[0] <= 0; prev_b[1] <= 0; prev_b[2] <= 0; prev_b[3] <= 0;
        end else if (DE) begin
            prev_r[3] <= prev_r[2]; prev_r[2] <= prev_r[1]; prev_r[1] <= prev_r[0]; prev_r[0] <= pixel_r_i;
            prev_g[3] <= prev_g[2]; prev_g[2] <= prev_g[1]; prev_g[1] <= prev_g[0]; prev_g[0] <= pixel_g_i;
            prev_b[3] <= prev_b[2]; prev_b[2] <= prev_b[1]; prev_b[1] <= prev_b[0]; prev_b[0] <= pixel_b_i;
        end
    end

    // ===               ===
    logic is_step_r, is_step_g, is_step_b;
    always_comb begin
        is_step_r = DE && (pixel_r_i == prev_r[0]) && (prev_r[0] == prev_r[1]) && (prev_r[1] == prev_r[2]) && (prev_r[2] == prev_r[3]);
        is_step_g = DE && (pixel_g_i == prev_g[0]) && (prev_g[0] == prev_g[1]) && (prev_g[1] == prev_g[2]) && (prev_g[2] == prev_g[3]);
        is_step_b = DE && (pixel_b_i == prev_b[0]) && (prev_b[0] == prev_b[1]) && (prev_b[1] == prev_b[2]) && (prev_b[2] == prev_b[3]);
    end

    logic step_end_r, step_end_g, step_end_b;
    always_comb begin
        step_end_r = is_step_r && (pixel_r_i != prev_r[0]);
        step_end_g = is_step_g && (pixel_g_i != prev_g[0]);
        step_end_b = is_step_b && (pixel_b_i != prev_b[0]);
    end

    // ===       »≠      ===
    logic [3:0] smooth_r, smooth_g, smooth_b;
    always_comb begin
        // R √§  
        if (step_end_r) smooth_r = (prev_r[0] + pixel_r_i) >> 1;
        else if (is_step_r) smooth_r = prev_r[0];
        else smooth_r = pixel_r_i;

        // G √§  
        if (step_end_g) smooth_g = (prev_g[0] + pixel_g_i) >> 1;
        else if (is_step_g) smooth_g = prev_g[0];
        else smooth_g = pixel_g_i;

        // B √§  
        if (step_end_b) smooth_b = (prev_b[0] + pixel_b_i) >> 1;
        else if (is_step_b) smooth_b = prev_b[0];
        else smooth_b = pixel_b_i;
    end

    // ===     12  ∆Æ        ===
    always_ff @(posedge clk) begin
        if (reset) begin
            o_data <= 12'h000;
        end else if (DE) begin
            o_data <= {smooth_r, smooth_g, smooth_b};
        end
    end

endmodule

module median_filter #(
    parameter IMG_WIDTH = 640
)(
    input  logic       clk,
    input  logic       reset,
    
    // 12  ∆Æ RGB  »º   ‘∑ 
    input  logic [11:0] i_data,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic        DE,
    
    // 12  ∆Æ RGB  »º     
    output logic [11:0] o_data
);

    //  ‘∑  RGB  –∏ 
    logic [3:0] pixel_r_i = i_data[11:8];
    logic [3:0] pixel_g_i = i_data[7:4];
    logic [3:0] pixel_b_i = i_data[3:0];

    // === 3  3                   ===
    logic [3:0] linebuf_r0 [0:IMG_WIDTH-1];
    logic [3:0] linebuf_r1 [0:IMG_WIDTH-1];
    logic [3:0] linebuf_g0 [0:IMG_WIDTH-1];
    logic [3:0] linebuf_g1 [0:IMG_WIDTH-1];
    logic [3:0] linebuf_b0 [0:IMG_WIDTH-1];
    logic [3:0] linebuf_b1 [0:IMG_WIDTH-1];

    //       »º  +      2 »º       (     3 »º )
    logic [3:0] win_r[0:2][0:2];
    logic [3:0] win_g[0:2][0:2];
    logic [3:0] win_b[0:2][0:2];

    integer i;

    //               
    always_ff @(posedge clk) begin
        if (DE) begin
            //                 Ãµ 
            if (y_pixel > 0) begin
                linebuf_r1[x_pixel] <= linebuf_r0[x_pixel];
                linebuf_g1[x_pixel] <= linebuf_g0[x_pixel];
                linebuf_b1[x_pixel] <= linebuf_b0[x_pixel];
            end
            linebuf_r0[x_pixel] <= pixel_r_i;
            linebuf_g0[x_pixel] <= pixel_g_i;
            linebuf_b0[x_pixel] <= pixel_b_i;
        end
    end

    // 3  3            
    always_comb begin
        for (i=0; i<3; i=i+1) begin
            //     
            win_r[0][i] = (y_pixel > 1) ? linebuf_r1[(x_pixel+i-1) % IMG_WIDTH] : pixel_r_i;
            win_r[1][i] = (y_pixel > 0) ? linebuf_r0[(x_pixel+i-1) % IMG_WIDTH] : pixel_r_i;
            win_r[2][i] = pixel_r_i;

            win_g[0][i] = (y_pixel > 1) ? linebuf_g1[(x_pixel+i-1) % IMG_WIDTH] : pixel_g_i;
            win_g[1][i] = (y_pixel > 0) ? linebuf_g0[(x_pixel+i-1) % IMG_WIDTH] : pixel_g_i;
            win_g[2][i] = pixel_g_i;

            win_b[0][i] = (y_pixel > 1) ? linebuf_b1[(x_pixel+i-1) % IMG_WIDTH] : pixel_b_i;
            win_b[1][i] = (y_pixel > 0) ? linebuf_b0[(x_pixel+i-1) % IMG_WIDTH] : pixel_b_i;
            win_b[2][i] = pixel_b_i;
        end
    end

    // 9 »º   ﬂ∞     ‘º 
    function [3:0] median9(input [3:0] a0,a1,a2,a3,a4,a5,a6,a7,a8);
        logic [3:0] tmp [0:8];
        integer i,j;
        logic [3:0] t;
        begin
            tmp[0]=a0; tmp[1]=a1; tmp[2]=a2; tmp[3]=a3; tmp[4]=a4; tmp[5]=a5; tmp[6]=a6; tmp[7]=a7; tmp[8]=a8;
            //  ‹º         ∆Æ
            for(i=0;i<8;i=i+1)
                for(j=i+1;j<9;j=j+1)
                    if(tmp[i]>tmp[j]) begin t=tmp[i]; tmp[i]=tmp[j]; tmp[j]=t; end
            median9 = tmp[4]; //  ﬂæ”∞ 
        end
    endfunction

    // Median     
    logic [3:0] smooth_r, smooth_g, smooth_b;
    always_comb begin
        smooth_r = median9(
            win_r[0][0], win_r[0][1], win_r[0][2],
            win_r[1][0], win_r[1][1], win_r[1][2],
            win_r[2][0], win_r[2][1], win_r[2][2]
        );
        smooth_g = median9(
            win_g[0][0], win_g[0][1], win_g[0][2],
            win_g[1][0], win_g[1][1], win_g[1][2],
            win_g[2][0], win_g[2][1], win_g[2][2]
        );
        smooth_b = median9(
            win_b[0][0], win_b[0][1], win_b[0][2],
            win_b[1][0], win_b[1][1], win_b[1][2],
            win_b[2][0], win_b[2][1], win_b[2][2]
        );
    end

    //    
    always_ff @(posedge clk) begin
        if (reset) o_data <= 12'h000;
        else if (DE) o_data <= {smooth_r, smooth_g, smooth_b};
    end

endmodule

module Laplacian_Filter #(
    parameter IMG_WIDTH = 640
)(
    input  logic         clk,
    input  logic         reset,
    input  logic [11:0]  i_data,  // Combined RGB input: {R[11:8], G[7:4], B[3:0]}
    input  logic [9:0]   x_pixel,
    input  logic [9:0]   y_pixel,
    input  logic         DE,
    output logic [11:0]  o_data   // Combined RGB output
);

    // --- Internal Signal Unbundling and Bundling ---
    // 1. Unbundle the 12-bit input into 4-bit channels
    logic [3:0] i_r, i_g, i_b;
    assign i_r = i_data[11:8];
    assign i_g = i_data[7:4];
    assign i_b = i_data[3:0];
    
    // 2. Internal 4-bit outputs
    logic [3:0] o_r, o_g, o_b;
    
    // 3. Bundle the 4-bit outputs into the 12-bit output
    assign o_data = {o_r, o_g, o_b};

    // --- Line Buffers (RAM-based storage for the previous two lines) ---
    // P(x, y-1) and P(x, y-2) for each channel
    logic [3:0] line1_r [0:IMG_WIDTH-1];
    logic [3:0] line2_r [0:IMG_WIDTH-1];
    logic [3:0] line1_g [0:IMG_WIDTH-1];
    logic [3:0] line2_g [0:IMG_WIDTH-1];
    logic [3:0] line1_b [0:IMG_WIDTH-1];
    logic [3:0] line2_b [0:IMG_WIDTH-1];

    // --- 3x3 Window Registers (9-tap shift register) ---
    // w[0] (top-left) to w[8] (bottom-right)
    logic [3:0] w_r[0:8];
    logic [3:0] w_g[0:8];
    logic [3:0] w_b[0:8];

    // Signals holding the newly available column of pixels P(x, y-2), P(x, y-1), P(x, y)
    logic [3:0] new_col_r2, new_col_r1, new_col_r0;
    logic [3:0] new_col_g2, new_col_g1, new_col_g0;
    logic [3:0] new_col_b2, new_col_b1, new_col_b0;
    
    // Pipelining for valid signal (2 cycle delay for full window assembly and output register)
    logic [2:0] valid_pipeline;

    // --- New Column Data Assignment (Combinational) ---
    // Reads old line data P(x, y-1) and P(x, y-2) at the current x_coor.
    // Zero-padding is applied for the first column (x_coor=0).
    assign new_col_r2 = (x_pixel > 0) ? line2_r[x_pixel] : 4'h0; // P(x, y-2)
    assign new_col_r1 = (x_pixel > 0) ? line1_r[x_pixel] : 4'h0; // P(x, y-1)
    assign new_col_r0 = i_r;                                     // P(x, y)

    assign new_col_g2 = (x_pixel > 0) ? line2_g[x_pixel] : 4'h0; 
    assign new_col_g1 = (x_pixel > 0) ? line1_g[x_pixel] : 4'h0; 
    assign new_col_g0 = i_g;                                     

    assign new_col_b2 = (x_pixel > 0) ? line2_b[x_pixel] : 4'h0; 
    assign new_col_b1 = (x_pixel > 0) ? line1_b[x_pixel] : 4'h0; 
    assign new_col_b0 = i_b;                                     


    // --- Line buffer update and 3x3 Window Shift (Sequential) ---
    always_ff @(posedge clk) begin
        if (reset) begin
            valid_pipeline <= 0;
            // ¿©µµøÏ ∑π¡ˆΩ∫≈Õ ∏Æº¬
            for (int i = 0; i < 9; i++) begin
                w_r[i] <= 0; w_g[i] <= 0; w_b[i] <= 0;
            end
        end else if (DE) begin
            // 1. ∂Û¿Œ πˆ∆€ æ˜µ•¿Ã∆Æ (P(x, y-1)∞˙ P(x, y) ¿˙¿Â)
            line2_r[x_pixel] <= line1_r[x_pixel];
            line1_r[x_pixel] <= i_r;
            line2_g[x_pixel] <= line1_g[x_pixel];
            line1_g[x_pixel] <= i_g;
            line2_b[x_pixel] <= line1_b[x_pixel];
            line1_b[x_pixel] <= i_b;

            // 2. ¿©µµøÏ Ω√«¡∆Æ (ø√πŸ∏• 3x3 ΩΩ∂Û¿Ãµ˘ ¿©µµøÏ ∑Œ¡˜)
            // Column 1 <- Column 2
            w_r[0] <= w_r[1]; w_r[3] <= w_r[4]; w_r[6] <= w_r[7];
            w_g[0] <= w_g[1]; w_g[3] <= w_g[4]; w_g[6] <= w_g[7];
            w_b[0] <= w_b[1]; w_b[3] <= w_b[4]; w_b[6] <= w_b[7];

            // Column 2 <- Column 3
            w_r[1] <= w_r[2]; w_r[4] <= w_r[5]; w_r[7] <= w_r[8];
            w_g[1] <= w_g[2]; w_g[4] <= w_g[5]; w_g[7] <= w_g[8];
            w_b[1] <= w_b[2]; w_b[4] <= w_b[5]; w_b[7] <= w_b[8];

            // Column 3 <- New Column Data
            w_r[2] <= new_col_r2; w_r[5] <= new_col_r1; w_r[8] <= new_col_r0;
            w_g[2] <= new_col_g2; w_g[5] <= new_col_g1; w_g[8] <= new_col_g0;
            w_b[2] <= new_col_b2; w_b[5] <= new_col_b1; w_b[8] <= new_col_b0;
            
            // 3. Valid Pipeline æ˜µ•¿Ã∆Æ (x_coor >= 2, y_coor >= 2¿œ ∂ß ¿Ø»ø)
            valid_pipeline <= {valid_pipeline[1:0], (x_pixel>=2 && y_pixel>=2)};
        end
    end

    // --- Laplacian function (Combinational logic) ---
    function signed [7:0] laplace(input [3:0] a0, a1, a2, a3, a4, a5, a6, a7, a8);
        begin
            // 5-Point Laplacian Kernel: [ 0, -1, 0, -1, 4, -1, 0, -1, 0 ]
            laplace = (4*a4) + ((4*a4) >> 1) - a1 - a3 - a5 - a7;//2 *( 4 * a4 ) - a1 - a3 - a5 - a7; 
        end
    endfunction

    // Clamp 8-bit signed result to 4-bit unsigned (0 to 15) (Combinational logic)
    function [3:0] clamp4(input signed [7:0] v);
        begin
            if (v < 0)      clamp4 = 4'd0;
            else if (v > 15) clamp4 = 4'd15;
            else             clamp4 = v[3:0];
        end
    endfunction

    // --- Apply Laplacian and Register Output ---
    // ∞ËªÍ ∞·∞˙∏¶ ∆ƒ¿Ã«¡∂Û¿Œ ∑π¡ˆΩ∫≈Õø° ¿˙¿Â
    always_ff @(posedge clk) begin
        if (reset) begin
            o_r <= 0;
            o_g <= 0;
            o_b <= 0;
        end else if (valid_pipeline[2]) begin
            o_r <= clamp4( laplace(w_r[0],w_r[1],w_r[2], w_r[3],w_r[4],w_r[5], w_r[6],w_r[7],w_r[8]) );
            o_g <= clamp4( laplace(w_g[0],w_g[1],w_g[2], w_g[3],w_g[4],w_g[5], w_g[6],w_g[7],w_g[8]) );
            o_b <= clamp4( laplace(w_b[0],w_b[1],w_b[2], w_b[3],w_b[4],w_b[5], w_b[6],w_b[7],w_b[8]) );
        end else begin
            // ¿Ø»ø«œ¡ˆ æ ¿ª ∂ß √‚∑¬¿ª 0¿∏∑Œ ¿Ø¡ˆ
            o_r <= 0; o_g <= 0; o_b <= 0;
        end
    end

endmodule