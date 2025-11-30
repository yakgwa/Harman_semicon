`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/26 10:35:15
// Design Name: 
// Module Name: color_detect
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

module color_detect(
    input  logic       clk,
    input  logic       reset,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    input  logic [3:0] R,
    input  logic [3:0] G,
    input  logic [3:0] B,
    output logic       blue_detect,
    output logic       red_detect
);

    // 텍스트 영역 정의 (text_display와 동일하게)
    localparam int CHAR_WIDTH  = 8;
    localparam int CHAR_HEIGHT = 8;
    localparam int MAX_CHARS   = 5;
    localparam int CAM_WIDTH   = 320;
    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS*CHAR_WIDTH)/2;
    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS*CHAR_WIDTH;
    localparam int TEXT_Y_START = 16;
    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            blue_detect <= 0;
            red_detect  <= 0;
        end else begin
            // 텍스트 영역 안에서 색 감지
            if(x_pixel >= TEXT_X_START && x_pixel < TEXT_X_END &&
               y_pixel >= TEXT_Y_START && y_pixel < TEXT_Y_END) begin

                if(B > 10) begin //if(R < 5 && G < 5 && B > 10) begin
                    blue_detect <= 1;
                    red_detect  <= 0;
                end else if(R > 10) begin //end else if(R > 10 && G < 5 && B < 5) begin
                    blue_detect <= 0;
                    red_detect  <= 1;
                end else begin
                    blue_detect <= 0;
                    red_detect  <= 0;
                end

            end else begin
                // 텍스트 영역 밖에서는 detect 유지하지 않음
                blue_detect <= 0;
                red_detect  <= 0;
            end
        end
    end

endmodule




//module color_detect(
//    input  logic       clk,
//    input  logic       reset,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    input  logic [3:0] R,
//    input  logic [3:0] G,
//    input  logic [3:0] B,
//    output logic       blue_detect,
//    output logic       red_detect
//);

//    reg [31:0] blue_count;
//    reg [31:0] red_count;

//    always_ff @(posedge clk, posedge reset) begin
//        if(reset) begin
//            blue_count   <= 0;
//            red_count    <= 0;
//            blue_detect  <= 0;
//            red_detect   <= 0;
//        end else begin
//            if(x_pixel == 0 && y_pixel == 0) begin
//                blue_count <= 0;
//                red_count  <= 0;
//            end

//            if(R < 5 && G < 5 && B > 10)       blue_count <= blue_count + 1; // 파랑
//            else if(R > 10 && G < 5 && B < 5)  red_count  <= red_count + 1;  // 빨강

//            if(x_pixel == 639 && y_pixel == 479) begin
//                blue_detect <= (blue_count > 0);
//                red_detect  <= (red_count  > 0);
//            end
//        end
//    end
//endmodule

