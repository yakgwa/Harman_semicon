// `timescale 1ns / 1ps

// module ColorDetector_4way(
//     input  logic clk,         // sys_clk(25MHz)
//     input  logic vsync,
//     input  logic DE,
//     input  logic [9:0] x_pixel,
//     input  logic [9:0] y_pixel,
//     input  logic [3:0] r_in,
//     input  logic [3:0] g_in,
//     input  logic [3:0] b_in,

//     output logic detect_LT,
//     output logic detect_RT,
//     output logic detect_LB,
//     output logic detect_RB
// );

//     logic LT_flag, RT_flag, LB_flag, RB_flag;

//     // 초록색 Threshold (조절 가능)
//     logic is_green;
//     assign is_green = (g_in >= 6) && (g_in > r_in + 1) && (g_in > b_in + 1);

//     always_ff @(posedge clk) begin

//         // === 프레임 시작 시 초기화 ===
//         if (vsync == 1) begin
//             LT_flag <= 0;
//             RT_flag <= 0;
//             LB_flag <= 0;
//             RB_flag <= 0;
//         end

//         // === 프레임 중 감지 ===
//         else if (DE && is_green) begin
//             if (x_pixel < 320 && y_pixel < 240)       LT_flag <= 1;
//             else if (x_pixel >= 320 && y_pixel < 240) RT_flag <= 1;
//             else if (x_pixel < 320 && y_pixel >= 240) LB_flag <= 1;
//             else                                      RB_flag <= 1;
//         end
//     end

//     assign detect_LT = LT_flag;
//     assign detect_RT = RT_flag;
//     assign detect_LB = LB_flag;
//     assign detect_RB = RB_flag;

// endmodule





// `timescale 1ns / 1ps

// module ColorDetector_4way(
//     input  logic clk,         // sys_clk(25MHz)
//     input  logic vsync,
//     input  logic DE,
//     input  logic [9:0] x_pixel,
//     input  logic [9:0] y_pixel,
//     input  logic [3:0] r_in,
//     input  logic [3:0] g_in,
//     input  logic [3:0] b_in,

//     output logic detect_LT,
//     output logic detect_RT,
//     output logic detect_LB,
//     output logic detect_RB
// );

//     // ---------------------------------------------------
//     // 1) vsync rising edge 생성
//     // ---------------------------------------------------
//     logic vs_d, vs_rise;

//     always_ff @(posedge clk) begin
//         vs_d    <= vsync;
//         vs_rise <= vsync & ~vs_d;   // rising edge 감지
//     end

//     // ---------------------------------------------------
//     // 2) 구역 플래그
//     // ---------------------------------------------------
//     logic LT_flag, RT_flag, LB_flag, RB_flag;

//     // ---------------------------------------------------
//     // 3) 초록색 판정
//     // ---------------------------------------------------
//     logic is_green;
//     // assign is_green = (g_in >= 6) && (g_in > r_in + 1) && (g_in > b_in + 1);
//     assign is_green = (g_in >= r_in) && (g_in >= b_in);


//     // ---------------------------------------------------
//     // 4) 구역 감지 (프레임 단위)
//     // ---------------------------------------------------
//     always_ff @(posedge clk) begin

//         // === 1 프레임 시작 (vsync rising edge에서 딱 1번 초기화) ===
//         if (vs_rise) begin
//             LT_flag <= 0;
//             RT_flag <= 0;
//             LB_flag <= 0;
//             RB_flag <= 0;
//         end

//         // === 프레임 중 초록 감지 ===
//         else if (DE && is_green) begin
//             if (x_pixel < 320 && y_pixel < 240)       LT_flag <= 1;
//             else if (x_pixel >= 320 && y_pixel < 240) RT_flag <= 1;
//             else if (x_pixel < 320 && y_pixel >= 240) LB_flag <= 1;
//             else                                      RB_flag <= 1;
//         end
//     end

//     assign detect_LT = LT_flag;
//     assign detect_RT = RT_flag;
//     assign detect_LB = LB_flag;
//     assign detect_RB = RB_flag;

// endmodule






















/////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps
module ColorDetector_4way(
    input  logic clk,
    input  logic vsync,
    input  logic DE,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    input  logic [3:0] r_in,
    input  logic [3:0] g_in,
    input  logic [3:0] b_in,

    output logic pass_LT,
    output logic pass_RT,
    output logic pass_LB,
    output logic pass_RB
);

    // vsync rising edge
    logic vs_d, vs_rise;
    always_ff @(posedge clk) begin
        vs_d    <= vsync;
        vs_rise <= vsync & ~vs_d;
    end

    // 초록색 조건 (강화)
    logic is_green;
    // assign is_green = (g_in > r_in + 1) && (g_in > b_in + 1);
    assign is_green = (b_in > r_in + 3) && (b_in > g_in + 3);

    // 프레임별 PASS 리셋 + 감지
    always_ff @(posedge clk) begin
        if(vs_rise) begin
            pass_LT <= 0;
            pass_RT <= 0;
            pass_LB <= 0;
            pass_RB <= 0;
        end
        else if(DE && is_green) begin
            if(x_pixel < 320 && y_pixel < 240)        pass_LT <= 1;
            else if(x_pixel >= 320 && y_pixel < 240)  pass_RT <= 1;
            else if(x_pixel < 320 && y_pixel >= 240)  pass_LB <= 1;
            else                                      pass_RB <= 1;
        end
    end

endmodule

