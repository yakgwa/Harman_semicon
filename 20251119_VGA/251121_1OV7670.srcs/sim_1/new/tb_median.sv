`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/23 18:59:55
// Design Name: 
// Module Name: tb_median
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
module tb_median_filter;

    parameter IMG_WIDTH = 8;  // 작은 테스트용

    logic clk;
    logic reset;
    logic [11:0] i_data;
    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic DE;

    logic [11:0] o_data;

    // Median filter instance
    median_filter #(.IMG_WIDTH(IMG_WIDTH)) UUT (
        .clk(clk),
        .reset(reset),
        .i_data(i_data),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE),
        .o_data(o_data)
    );

    // Clock
    always #5 clk = ~clk;

    logic [3:0] test_r[0:2][0:2];
    logic [3:0] test_g[0:2][0:2];
    logic [3:0] test_b[0:2][0:2];

    initial begin
        clk = 0;
        reset = 1;
        DE = 0;
        x_pixel = 0;
        y_pixel = 0;
        i_data = 12'h000;

        #20;
        reset = 0;
        DE = 1;

        // 입력 테스트 패턴: 3x3 영역
        // r,g,b 각 4비트, 중앙값이 5가 되도록
        // 0  3  7
        // 2  5  8
        // 1  6  9
        logic [3:0] test_r[0:2][0:2] = '{{0,3,7},{2,5,8},{1,6,9}};
        logic [3:0] test_g[0:2][0:2] = '{{0,3,7},{2,5,8},{1,6,9}};
        logic [3:0] test_b[0:2][0:2] = '{{0,3,7},{2,5,8},{1,6,9}};

        for (y_pixel=0; y_pixel<3; y_pixel=y_pixel+1) begin
            for (x_pixel=0; x_pixel<3; x_pixel=x_pixel+1) begin
                i_data = {test_r[y_pixel][x_pixel], test_g[y_pixel][x_pixel], test_b[y_pixel][x_pixel]};
                #10;
                $display("Pixel(%0d,%0d): input=%h, output=%h", x_pixel, y_pixel, i_data, o_data);
            end
        end

        #20 $finish;
    end

endmodule

