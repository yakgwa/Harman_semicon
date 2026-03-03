`timescale 1ns / 1ps

module Laplacian_Filter #(
    parameter IMG_WIDTH = 640
)(
    input  logic         clk,
    input  logic         reset,
    input  logic [23:0]  i_data,      // RGB888 input
    input  logic [9:0]   x_pixel,
    input  logic [9:0]   y_pixel,
    input  logic         DE,
    output logic [23:0]  o_data       // RGB888 output
);

    // -------------------------
    // RGB 분리
    // -------------------------
    logic [7:0] i_r, i_g, i_b;
    assign i_r = i_data[23:16];
    assign i_g = i_data[15:8];
    assign i_b = i_data[7:0];

    logic [7:0] o_r, o_g, o_b;
    assign o_data = {o_r, o_g, o_b};

    // -------------------------
    // Line Buffer (2 line)
    // -------------------------
    logic [7:0] line1_r [0:IMG_WIDTH-1];
    logic [7:0] line2_r [0:IMG_WIDTH-1];
    logic [7:0] line1_g [0:IMG_WIDTH-1];
    logic [7:0] line2_g [0:IMG_WIDTH-1];
    logic [7:0] line1_b [0:IMG_WIDTH-1];
    logic [7:0] line2_b [0:IMG_WIDTH-1];

    // -------------------------
    // 3×3 Window
    // -------------------------
    logic [7:0] w_r[0:8];
    logic [7:0] w_g[0:8];
    logic [7:0] w_b[0:8];

    // -------------------------
    // New Column
    // -------------------------
    logic [7:0] new_r[2:0]; // 위, 중간, 현재
    logic [7:0] new_g[2:0];
    logic [7:0] new_b[2:0];

    assign new_r[2] = (x_pixel >= 2) ? line2_r[x_pixel-2] : 8'd0; // y-2
    assign new_r[1] = (x_pixel >= 1) ? line1_r[x_pixel-1] : 8'd0; // y-1
    assign new_r[0] = i_r;                                         // y

    assign new_g[2] = (x_pixel >= 2) ? line2_g[x_pixel-2] : 8'd0;
    assign new_g[1] = (x_pixel >= 1) ? line1_g[x_pixel-1] : 8'd0;
    assign new_g[0] = i_g;

    assign new_b[2] = (x_pixel >= 2) ? line2_b[x_pixel-2] : 8'd0;
    assign new_b[1] = (x_pixel >= 1) ? line1_b[x_pixel-1] : 8'd0;
    assign new_b[0] = i_b;

    // -------------------------
    // Pipeline valid
    // -------------------------
    logic [2:0] valid_pipeline;

    // -------------------------
    // Line buffer & window update
    // -------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            valid_pipeline <= 3'd0;
            for (int i=0; i<9; i++) begin
                w_r[i] <= 8'd0;
                w_g[i] <= 8'd0;
                w_b[i] <= 8'd0;
            end
        end else if (DE) begin
            // --- line buffer ---
            line2_r[x_pixel] <= line1_r[x_pixel];
            line1_r[x_pixel] <= i_r;
            line2_g[x_pixel] <= line1_g[x_pixel];
            line1_g[x_pixel] <= i_g;
            line2_b[x_pixel] <= line1_b[x_pixel];
            line1_b[x_pixel] <= i_b;

            // --- shift window left ---
            w_r[0] <= w_r[1]; w_r[1] <= w_r[2];
            w_r[3] <= w_r[4]; w_r[4] <= w_r[5];
            w_r[6] <= w_r[7]; w_r[7] <= w_r[8];
            w_r[2] <= new_r[2]; w_r[5] <= new_r[1]; w_r[8] <= new_r[0];

            w_g[0] <= w_g[1]; w_g[1] <= w_g[2];
            w_g[3] <= w_g[4]; w_g[4] <= w_g[5];
            w_g[6] <= w_g[7]; w_g[7] <= w_g[8];
            w_g[2] <= new_g[2]; w_g[5] <= new_g[1]; w_g[8] <= new_g[0];

            w_b[0] <= w_b[1]; w_b[1] <= w_b[2];
            w_b[3] <= w_b[4]; w_b[4] <= w_b[5];
            w_b[6] <= w_b[7]; w_b[7] <= w_b[8];
            w_b[2] <= new_b[2]; w_b[5] <= new_b[1]; w_b[8] <= new_b[0];

            // --- pipeline valid ---
            valid_pipeline <= {valid_pipeline[1:0], (x_pixel >= 2 && y_pixel >= 2)};
        end
    end

    // -------------------------
    // Laplacian function
    // -------------------------
    function signed [15:0] laplace(
        input [7:0] a0,a1,a2,
        input [7:0] a3,a4,a5,
        input [7:0] a6,a7,a8
    );
        begin
            laplace = (4*a4) - a1 - a3 - a5 - a7;
        end
    endfunction

    function [7:0] clamp8(input signed [15:0] v);
        begin
            if (v < 0) clamp8 = 8'd0;
            else if (v > 255) clamp8 = 8'd255;
            else clamp8 = v[7:0];
        end
    endfunction

    // -------------------------
    // Output stage
    // -------------------------
    
always_ff @(posedge clk) begin
        if (reset) begin
            o_r <= 8'd0; o_g <= 8'd0; o_b <= 8'd0;
        end else if (valid_pipeline[2]) begin
            // Laplacian 연산 후 128 offset 추가
            logic signed [15:0] temp_r, temp_g, temp_b;
    
            temp_r = laplace(w_r[0],w_r[1],w_r[2], w_r[3],w_r[4],w_r[5], w_r[6],w_r[7],w_r[8]) + 16'd128;
            temp_g = laplace(w_g[0],w_g[1],w_g[2], w_g[3],w_g[4],w_g[5], w_g[6],w_g[7],w_g[8]) + 16'd128;
            temp_b = laplace(w_b[0],w_b[1],w_b[2], w_b[3],w_b[4],w_b[5], w_b[6],w_b[7],w_b[8]) + 16'd128;
    
            o_r <= clamp8(temp_r);
            o_g <= clamp8(temp_g);
            o_b <= clamp8(temp_b);
        end else begin
            o_r <= 8'd0; o_g <= 8'd0; o_b <= 8'd0;
        end
    end

endmodule
