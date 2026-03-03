
// `timescale 1ns / 1ps

// module OV7670_CCTV (
//     input logic clk,
//     input logic reset,

//     input  logic I2C_start,
//     output logic scl,
//     inout  tri   sda,

//     output logic xclk,
//     input logic pclk,
//     input logic href,
//     input logic vsync,
//     input logic [7:0] data,

//     output logic h_sync,
//     output logic v_sync,
//     output logic [3:0] r_port,
//     output logic [3:0] g_port,
//     output logic [3:0] b_port,

//     input logic season_sel,
//     input logic mini_sw,
//     input logic gamestr,

//     output logic [2:0] fsm_state
// );

//     logic sys_clk;
//     logic DE;
//     logic [9:0] x_pixel, y_pixel;

//     logic [16:0] rAddr;
//     logic [15:0] rData;

//     logic we;
//     logic [16:0] wAddr;
//     logic [15:0] wData;

//     logic [3:0] r_raw, g_raw, b_raw;
//     logic [3:0] r_season, g_season, b_season;
//     logic [3:0] r_final, g_final, b_final;

//     logic [3:0] game_r, game_g, game_b;

//     logic start_sync1, start_sync;



//     always_ff @(posedge sys_clk) begin
//         start_sync1 <= gamestr;
//         start_sync  <= start_sync1;
//     end

//     ov7670_I2C_Top U_I2C (
//         .clk  (clk),
//         .reset(reset),
//         .start(I2C_start),
//         .scl  (scl),
//         .sda  (sda)
//     );

//     pclk_gen U_PCLK (
//         .clk  (clk),
//         .reset(reset),
//         .pclk (sys_clk)
//     );
//     assign xclk = sys_clk;

//     VGA_Syncher U_SYNC (
//         .clk(sys_clk),
//         .reset(reset),
//         .h_sync(h_sync),
//         .v_sync(v_sync),
//         .DE(DE),
//         .x_pixel(x_pixel),
//         .y_pixel(y_pixel)
//     );


//     // RAW Reader
//     ImgMemReader U_READER (
//         .DE(DE),
//         .x_pixel(x_pixel),
//         .y_pixel(y_pixel),
//         .addr(rAddr),
//         .imgData(rData),
//         .r_port(r_raw),
//         .g_port(g_raw),
//         .b_port(b_raw)
//     );




//     //======================================================
//     // PixelWindow3×3 → Filter 입력
//     //======================================================
//     logic [15:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
//     logic [16:0] rAddr_win;  // 3x3 필터용(윈도우)

//     PixelWindow3x3 U_WIN (
//         .clk(sys_clk),
//         .reset(reset),
//         .DE(DE),
//         .x_pixel(x_pixel),
//         .y_pixel(y_pixel),

//         .rAddr(rAddr_win),
//         .rData(rData),

//         .pix00(p00),
//         .pix01(p01),
//         .pix02(p02),
//         .pix10(p10),
//         .pix11(p11),
//         .pix12(p12),
//         .pix20(p20),
//         .pix21(p21),
//         .pix22(p22)
//     );

//     // 중심 + 오른쪽 + 아래 픽셀 추출
//     wire [3:0] r_center = p11[15:12];
//     wire [3:0] g_center = p11[11:8];
//     wire [3:0] b_center = p11[7:4];

//     wire [3:0] r_right = p12[15:12];
//     wire [3:0] g_right = p12[11:8];
//     wire [3:0] b_right = p12[7:4];

//     wire [3:0] r_down = p21[15:12];
//     wire [3:0] g_down = p21[11:8];
//     wire [3:0] b_down = p21[7:4];

//     //======================================================
//     // Cartoon Filter
//     //======================================================
//     Autumn_Cartoon_Filter U_FILTER (
//         .DE(DE),
//         .season(season_sel),

//         .r_in(r_center),
//         .g_in(g_center),
//         .b_in(b_center),

//         .r_right(r_right),
//         .g_right(g_right),
//         .b_right(b_right),

//         .r_down(r_down),
//         .g_down(g_down),
//         .b_down(b_down),

//         .r_out(r_season),
//         .g_out(g_season),
//         .b_out(b_season)
//     );


//     //======================================================
//     // MiniGame (RAW)
//     //======================================================
//     MiniGame_Top_4way U_GAME (
//         .sys_clk(sys_clk),
//         .reset(reset | ~mini_sw),
//         .start(start_sync),
//         .vsync(vsync),
//         .DE(DE),
//         .x_pixel(x_pixel),
//         .y_pixel(y_pixel),
//         .cam_r(r_raw),
//         .cam_g(g_raw),
//         .cam_b(b_raw),
//         .r_out(game_r),
//         .g_out(game_g),
//         .b_out(game_b),
//         .fsm_state_deug(fsm_state)
//     );

//     //======================================================
//     // Final MUX
//     //======================================================
//     Mux U_MUX (
//         .mini_sw(mini_sw),
//         .season_sel(season_sel),
//         .r_raw(r_raw),
//         .g_raw(g_raw),
//         .b_raw(b_raw),
//         .r_season(r_season),
//         .g_season(g_season),
//         .b_season(b_season),
//         .r_game(game_r),
//         .g_game(game_g),
//         .b_game(game_b),
//         .r_out(r_final),
//         .g_out(g_final),
//         .b_out(b_final)
//     );

//     assign r_port = r_final;
//     assign g_port = g_final;
//     assign b_port = b_final;

//     frame_buffer FB (
//         .wclk(pclk),
//         .we(we),
//         .wAddr(wAddr),
//         .wData(wData),
//         .rclk(sys_clk),
//         .oe(1'b1),
//         .rAddr(rAddr),
//         .rData(rData)
//     );

//     OV7670_Mem_Controller MEM (
//         .pclk(pclk),
//         .reset(reset),
//         .href(href),
//         .vsync(vsync),
//         .data(data),
//         .we(we),
//         .wAddr(wAddr),
//         .wData(wData)
//     );

// endmodule




// module Mux (
//     input logic mini_sw,    // 1 = MiniGame mode
//     input logic season_sel, // 1 = cartoon, 0 = raw

//     // RAW
//     input logic [3:0] r_raw,
//     input logic [3:0] g_raw,
//     input logic [3:0] b_raw,

//     // Cartoon Filter
//     input logic [3:0] r_season,
//     input logic [3:0] g_season,
//     input logic [3:0] b_season,

//     // MiniGame
//     input logic [3:0] r_game,
//     input logic [3:0] g_game,
//     input logic [3:0] b_game,

//     // Final Output
//     output logic [3:0] r_out,
//     output logic [3:0] g_out,
//     output logic [3:0] b_out
// );

//     always_comb begin
//         if (mini_sw == 1'b1) begin

//             r_out = r_game;
//             g_out = g_game;
//             b_out = b_game;
//         end else if (season_sel == 1'b1) begin

//             r_out = r_season;
//             g_out = g_season;
//             b_out = b_season;
//         end else begin

//             r_out = r_raw;
//             g_out = g_raw;
//             b_out = b_raw;
//         end
//     end

// endmodule















`timescale 1ns / 1ps

module OV7670_CCTV (
    input logic clk,
    input logic reset,

    input  logic I2C_start,
    output logic scl,
    inout  tri   sda,

    output logic xclk,
    input logic pclk,
    input logic href,
    input logic vsync,
    input logic [7:0] data,

    output logic h_sync,
    output logic v_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port,

    input logic season_sel,   // ★ Dot3D Filter ON/OFF
    input logic mini_sw,      // ★ MiniGame 모드 ON/OFF
    input logic gamestr,      // 게임 시작 버튼

    output logic [2:0] fsm_state
);

    //======================================================================
    // 기본 신호
    //======================================================================
    logic sys_clk;
    logic DE;
    logic [9:0] x_pixel, y_pixel;

    logic [16:0] rAddr;
    logic [15:0] rData;

    logic we;
    logic [16:0] wAddr;
    logic [15:0] wData;

    logic [3:0] r_raw, g_raw, b_raw;
    logic [3:0] r_dot, g_dot, b_dot;
    logic [3:0] r_final, g_final, b_final;
    logic [3:0] game_r, game_g, game_b;
    logic start_sync1, start_sync;
    //======================================================================
    // xclk 생성 (카메라 클록)
    //======================================================================
    pclk_gen U_PCLK (
        .clk  (clk),
        .reset(reset),
        .pclk (sys_clk)
    );
    assign xclk = sys_clk;

    //======================================================================
    // OV7670 I2C 초기화
    //======================================================================
    ov7670_I2C_Top U_I2C (
        .clk(clk),
        .reset(reset),
        .start(I2C_start),
        .scl(scl),
        .sda(sda)
    );

    //======================================================================
    // VGA Sync
    //======================================================================
    VGA_Syncher U_SYNC (
        .clk(sys_clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    //======================================================================
    // FrameBuffer → RAW RGB 읽기
    //======================================================================
    ImgMemReader U_READER (
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr(rAddr),
        .imgData(rData),
        .r_port(r_raw),
        .g_port(g_raw),
        .b_port(b_raw)
    );

  //==============================================================
    // Minecraft Dot Filter (16×16)
    //==============================================================
    Season_Filter_Autumn U_FILTER (
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .r_in(r_raw),
        .g_in(g_raw),
        .b_in(b_raw),
        .r_out(r_dot),
        .g_out(g_dot),
        .b_out(b_dot)
    );

    //======================================================================
    // MiniGame
    //======================================================================


    always_ff @(posedge sys_clk) begin
        start_sync1 <= gamestr;
        start_sync  <= start_sync1;
    end

    MiniGame_Top_4way U_GAME (
        .sys_clk(sys_clk),
        .reset(reset | ~mini_sw),
        .start(start_sync),
        .vsync(vsync),
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .cam_r(r_raw),     // RAW로 Detect
        .cam_g(g_raw),
        .cam_b(b_raw),
        .r_out(game_r),
        .g_out(game_g),
        .b_out(game_b),
        .fsm_state_deug(fsm_state)
    );

    //======================================================================
    // 최종 MUX 모듈
    //======================================================================
    mux_filter_minigame U_MUX (
        .mini_sw(mini_sw),
        .season_sel(season_sel),

        .r_raw(r_raw),
        .g_raw(g_raw),
        .b_raw(b_raw),

        .r_filter(r_dot),     // Dot3D Filter 출력
        .g_filter(g_dot),
        .b_filter(b_dot),

        .r_game(game_r),      // MiniGame 출력
        .g_game(game_g),
        .b_game(game_b),

        .r_out(r_final),
        .g_out(g_final),
        .b_out(b_final)
    );


    assign r_port = r_final;
    assign g_port = g_final;
    assign b_port = b_final;


    //======================================================================
    // FrameBuffer + MemController
    //======================================================================
    frame_buffer FB (
        .wclk(pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(sys_clk),
        .oe(1'b1),
        .rAddr(rAddr),
        .rData(rData)
    );

    OV7670_Mem_Controller MEM (
        .pclk(pclk),
        .reset(reset),
        .href(href),
        .vsync(vsync),
        .data(data),
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );

endmodule


//======================================================================
// Filter / MiniGame 선택 MUX
//======================================================================
module mux_filter_minigame(
    input  logic mini_sw,       // MINIGAME ON?
    input  logic season_sel,    // FILTER ON?

    // RAW RGB
    input  logic [3:0] r_raw,
    input  logic [3:0] g_raw,
    input  logic [3:0] b_raw,

    // Filter RGB (Dot3D 등)
    input  logic [3:0] r_filter,
    input  logic [3:0] g_filter,
    input  logic [3:0] b_filter,

    // MiniGame RGB
    input  logic [3:0] r_game,
    input  logic [3:0] g_game,
    input  logic [3:0] b_game,

    // 최종 선택 결과
    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out
);

    always_comb begin
        if (mini_sw) begin
            // ★ MINIGAME 최우선
            r_out = r_game;
            g_out = g_game;
            b_out = b_game;
        end
        else if (season_sel) begin
            // Dot3D 또는 Season Filter 출력
            r_out = r_filter;
            g_out = g_filter;
            b_out = b_filter;
        end
        else begin
            // RAW
            r_out = r_raw;
            g_out = g_raw;
            b_out = b_raw;
        end
    end

endmodule






