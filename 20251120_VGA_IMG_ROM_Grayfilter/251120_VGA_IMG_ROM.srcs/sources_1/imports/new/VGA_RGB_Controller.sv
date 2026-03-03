`timescale 1ns / 1ps

module VGA_RGB_Controller (
    input  logic       clk,
    input  logic       reset,
    // input  logic       sel_sw,
    input logic mode_sel,
    input logic scale_sel,
    input logic gray_sel,
    // input  logic [3:0] r_sw,
    // input  logic [3:0] g_sw,
    // input  logic [3:0] b_sw,
    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
);

    logic DE;
    logic [9:0] x_pixel, y_pixel;
    // logic [3:0] sw_r_port, sw_g_port, sw_b_port;
    logic [3:0] img_r_vga, img_g_vga, img_b_vga;
    logic [3:0] img_r_qvga, img_g_qvga, img_b_qvga;
    logic [3:0] img_r, img_g, img_b;
    // logic [3:0] colorBar_r_port, colorBar_g_port, colorBar_b_port;
    logic [3:0] colorBar_r, colorBar_g, colorBar_b;
    logic [$clog2(320*240)-1:0] addr;
    logic [$clog2(320*240)-1:0] addr_qvga;
    logic [$clog2(320*240)-1:0] addr_vga;
    logic [               15:0] imgData;
    logic [               15:0] imgData_qvga;
    logic [               15:0] imgData_vga;
    logic [                3:0] mux_r_port;
    logic [                3:0] mux_g_port;
    logic [                3:0] mux_b_port;
    logic [                3:0] gray_r;
    logic [                3:0] gray_g;
    logic [                3:0] gray_b;
    logic [                3:0] mux_o_r_port;
    logic [                3:0] mux_o_g_port;
    logic [                3:0] mux_o_b_port;   


    VGA_Decoder U_VGA_Decoder (.*);

    ImgROM U_ROM (
        .addr(addr),
        .data(imgData)
    );


    demux2x1 U_Demux (
        .sel(scale_sel),
        .data(imgData),
        .data_0(imgData_qvga),
        .data_1(imgData_vga)
    );

    mux2x1 #(
        .BIT_SIZE(17)
    ) U_MUX_Addr (
        .sel (scale_sel),
        .rgb0(addr_qvga),
        .rgb1(addr_vga),
        .rgb (addr)
    );


    ImgMemReader U_ImgMemReader (
        .*,
        .addr(addr_qvga),
        .imgData(imgData_qvga),
        .r_port(img_r_qvga),
        .g_port(img_g_qvga),
        .b_port(img_b_qvga)
    );
    ImgMemReader_upscaler U_ImgMemReader_upscaler (
        .*,
        .addr(addr_vga),
        .imgData(imgData_vga),
        .r_port(img_r_vga),
        .g_port(img_g_vga),
        .b_port(img_b_vga)
    );
    mux2x1 #(
        .BIT_SIZE(12)
    ) U_MUX_Scale (
        .sel (scale_sel),
        .rgb0({img_r_qvga, img_g_qvga, img_b_qvga}),
        .rgb1({img_r_vga, img_g_vga, img_b_vga}),
        .rgb ({img_r, img_g, img_b})
    );

    VGA_ColorBar U_VGA_ColorBar (
        .*,
        .red_port  (colorBar_r),
        .green_port(colorBar_g),
        .blue_port (colorBar_b)
    );


    mux2x1 #(
        .BIT_SIZE(12)
    ) U_MUX_Mode (
        .sel (mode_sel),
        .rgb0({colorBar_r, colorBar_g, colorBar_b}),
        .rgb1({img_r, img_g, img_b}),
        .rgb ({mux_r_port, mux_g_port, mux_b_port})
    );

//    Gray_filter U_Gray_filter(
//        .i_red(mux_r_port),
//        .i_green(mux_g_port),
//        .i_blue(mux_b_port),
//        .o_red(gray_r),
//        .o_green(gray_g),
//        .o_blue(gray_b)
//    );

    Horizontal_Filter U_Horizontal_Filter(
        .clk(clk),
        .reset(reset),
        .i_data({mux_r_port, mux_g_port, mux_b_port}),   // RGB444 입력
        .x_coor(x_pixel),
        .y_coor(y_pixel),
        .DE(DE),
        o_data({mux_o_r_port, mux_o_g_port, mux_o_b_port}),
       );   // RGB444 출력

    mux2x1 #(
        .BIT_SIZE(12)
    ) U_MUX_Mode_2 (
        .sel (gray_sel),
        .rgb0({mux_o_r_port, mux_o_g_port, mux_o_b_port}),
        .rgb1({gray_r, gray_g, gray_b}),
        .rgb ({r_port, g_port, b_port})
    );

endmodule

module Horizontal_Filter #(
    parameter IMG_WIDTH = 640,  // 테스트벤치 BMP 해상도에 맞춰 320으로 설정
    parameter ADDR_WIDTH = 10  
)(
    input logic clk,
    input logic reset,
    input logic [11:0] i_data,   // RGB444 입력
    input logic [9:0] x_coor,
    input logic [9:0] y_coor,
    input logic DE,
    output logic [11:0] o_data   // RGB444 출력
);

    // BRAM 추론을 위한 개별 뱅크 선언
    (* ram_style = "block" *) logic [11:0] line_buffer0 [0:IMG_WIDTH-1];
    (* ram_style = "block" *) logic [11:0] line_buffer1 [0:IMG_WIDTH-1];
    
    logic bank_sel;
    logic [9:0] rev_x;

    // 1. 뱅크 전환: 라인의 마지막 픽셀에서 전환
    always_ff @(posedge clk) begin
        if (reset) begin
            bank_sel <= 1'b0;
        end else if (DE && (x_coor == IMG_WIDTH - 1)) begin
            bank_sel <= ~bank_sel;
        end
    end

    // 2. 역방향 주소 계산 (조합 논리)
    assign rev_x = (IMG_WIDTH - 1) - x_coor;

    // 3. 읽기/쓰기 동작 (o_DE 관련 로직 제거)
    always_ff @(posedge clk) begin
        if (reset) begin
            o_data <= 12'h000;
        end else if (DE) begin
            if (bank_sel == 1'b0) begin
                line_buffer0[x_coor] <= i_data;
                o_data <= line_buffer1[rev_x]; // 이전 라인의 반전 데이터
            end else begin
                line_buffer1[x_coor] <= i_data;
                o_data <= line_buffer0[rev_x]; // 이전 라인의 반전 데이터
            end
        end else begin
            o_data <= 12'h000;
        end
    end

endmodule



module mux2x1 #(
    parameter BIT_SIZE = 12
) (
    input  logic                sel,
    input  logic [BIT_SIZE-1:0] rgb0,
    input  logic [BIT_SIZE-1:0] rgb1,
    output logic [BIT_SIZE-1:0] rgb
);

    // assign rgb = sel ? rgb1 : rgb0;
    always_comb begin
        rgb = 0;
        case (sel)
            1'b0: rgb = rgb0;
            1'b1: rgb = rgb1;
        endcase
    end

endmodule




module demux2x1 (
    input  logic        sel,
    input  logic [15:0] data,
    output logic [15:0] data_0,
    output logic [15:0] data_1
);

    // assign rgb = sel ? rgb1 : rgb0;
    always_comb begin
        data_0 = 0;
        data_1 = 0;
        case (sel)
            1'b0: data_0 = data;
            1'b1: data_1 = data;
        endcase
    end

endmodule



