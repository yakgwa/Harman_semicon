`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 19:08:55
// Design Name: 
// Module Name: Grayfilter
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


module Gray_filter(
    input  logic [3:0] i_r,
    input  logic [3:0] i_g,
    input  logic [3:0] i_b,
    output logic [3:0] o_r,
    output logic [3:0] o_g,
    output logic [3:0] o_b
    );
    
    logic [11:0] gray;
    
    assign gray = 51 * i_r + 179 * i_g + 26 * i_b;
    
     assign o_r = gray[11:8];
     assign o_g = gray[11:8];
     assign o_b = gray[11:8];
    
    
    
    
    
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
