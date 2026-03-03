`timescale 1ns / 1ps
// module ImgMemReader (
//     input  logic                         DE,
//     input  logic [                  9:0] x_pixel,
//     input  logic [                  9:0] y_pixel,
//     output logic [$clog2(320*240)-1 : 0] addr,
//     input  logic [                 15:0] imgData,
//     output logic [                  3:0] r_port,
//     output logic [                  3:0] g_port,
//     output logic [                  3:0] b_port
// );

//     // Ï£ºÏÜå Í≥ÑÏÇ∞?? Í±¥Îì§Ïß? ÎßêÍ≥† Í∑∏Î?Î°? ?ú†Ïß?
//     assign addr = DE ? (320 * y_pixel[9:1] + x_pixel[9:1]) : '0;

//     // RGB565 Î∂ÑÌï¥
//     wire [4:0] R5 = imgData[15:11];
//     wire [5:0] G6 = imgData[10:5];
//     wire [4:0] B5 = imgData[4:0];

//     // 4bit ?ã§?ö¥?Éò?îå
//     wire [3:0] r4     = R5[4:1];
//     wire [3:0] g4_raw = G6[5:2];
//     wire [3:0] b4     = B5[4:1];

//     // ?òÖ Î∞©Î≤ï A: GÎ•? ?ïÑÏ£? ?Ç¥ÏßùÎßå Ï§ÑÏù¥Í∏? (Ï§ëÍ∞ÑÎπÑÌä∏ ?Ç¨?ö©)
//     wire [3:0] g4 = G6[4:1];

//     // ÏµúÏ¢Ö Ï∂úÎ†• 
//     assign r_port = DE ? r4 : 4'd0;
//     assign g_port = DE ? g4_raw : 4'd0;
//     assign b_port = DE ? b4 : 4'd0;

// endmodule


module ImgMemReader (
    input  logic                         DE,
    input  logic [                  9:0] x_pixel,
    input  logic [                  9:0] y_pixel,
    output logic [$clog2(640*480)-1 : 0] addr,
    input  logic [                 15:0] imgData,
    output logic [                  3:0] r_port,
    output logic [                  3:0] g_port,
    output logic [                  3:0] b_port
);
    //logic img_display_en;

    //assign img_display_en = DE && (x_pixel < 320) && (y_pixel < 240);
    assign addr = DE ? (320 * y_pixel + x_pixel) : 'bz;
    //assign {r_port, g_port, b_port} = DE ? {imgData[15:12], imgData[10:7], imgData[4:1]} : 0;
    assign {r_port, g_port, b_port} = DE ? {imgData[15:12], imgData[11:8], imgData[7:4]} : 0;

endmodule

module ImgMemReader_upscaler (
    input  logic                         DE,
    input  logic [                  9:0] x_pixel,
    input  logic [                  9:0] y_pixel,
    output logic [$clog2(320*240)-1 : 0] addr,
    input  logic [                 15:0] imgData,
    output logic [                  3:0] r_port,
    output logic [                  3:0] g_port,
    output logic [                  3:0] b_port
);

    assign addr = DE ? (320 * y_pixel[9:1] + x_pixel[9:1]) : 'bz;
    assign {r_port, g_port, b_port} = DE ? {imgData[15:12], imgData[10:7], imgData[4:1]} : 0;

endmodule
