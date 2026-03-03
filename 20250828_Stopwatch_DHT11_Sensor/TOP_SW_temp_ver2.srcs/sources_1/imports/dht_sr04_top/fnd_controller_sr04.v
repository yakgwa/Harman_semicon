`timescale 1ns / 1ps

module fnd_controller_sr04 (
    input         clk,
    input         rst,
    input  [11:0] i_dist,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data
);
    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [2:0] w_sel;
    wire w_clk_1khz;

    
    clk_div_1khz_sr04 U_CLK_DIV_1KHZ_SR04 (
        .clk(clk),
        .rst(rst),
        .o_clk_1khz(w_clk_1khz)
);

    counter_8_sr04 U_COUNTER_4_SR04 (
        .clk(w_clk_1khz),
        .rst(rst),
        .sel(w_sel)
);

    digit_splitter_sr04 U_DS_SR04 (
        .bcd_data(i_dist),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
);

    decoder_2x4_sr04 U_DECODER_2x4_SR04 (
        .sel(w_sel[1:0]),
        .fnd_com(fnd_com)
);

    mux_8x1_sr04 U_8X1_MUX_SR04 (
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .digit_5(4'hf),
        .digit_6(4'he),
        .digit_7(4'hf),  // dot display
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_bcd)
);

    bcd_decoder_sr04 U_BCD_DOCODER_SR04(
    .bcd(w_bcd),
    .fnd_data(fnd_data)
);
endmodule

module clk_div_1khz_sr04 (
    input  clk,
    input  rst,
    output o_clk_1khz
);
    // counter 100_000
    // $clog2 는 system에서 제공하는 task
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk_1khz;
    assign o_clk_1khz = r_clk_1khz;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter  <= 0;
                r_clk_1khz <= 1;
            end else begin
                r_counter  <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end

endmodule

module counter_8_sr04 (
    input        clk,
    input        rst,
    output [2:0] sel
);

    reg [2:0] counter;
    assign sel = counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            // intial
            counter <= 0;
        end else begin
            // operation
            counter <= counter + 1;
        end
    end

endmodule

module decoder_2x4_sr04 (
    input  [1:0] sel,
    output [3:0] fnd_com
);

    assign fnd_com = (sel == 2'b00) ? 4'b1110 :
                     (sel == 2'b01) ? 4'b1101 :
                     (sel == 2'b10) ? 4'b1011 :
                     (sel == 2'b11) ? 4'b0111 : 4'b1111;

endmodule


module mux_8x1_sr04 (
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] digit_5,
    input [3:0] digit_6,
    input [3:0] digit_7,  // dot display
    input [3:0] digit_8,
    input [2:0] sel,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    always @(*) begin
        case (sel)
            3'b000:  r_bcd = digit_1;
            3'b001:  r_bcd = digit_10;
            3'b010:  r_bcd = digit_100;
            3'b011:  r_bcd = digit_1000;
            3'b100:  r_bcd = digit_5;
            3'b101:  r_bcd = digit_6;
            3'b110:  r_bcd = digit_7;
            3'b111:  r_bcd = digit_8;
            default: r_bcd = digit_1;
        endcase
    end
endmodule


module digit_splitter_sr04 (
    input  [11:0] bcd_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);
    assign digit_1 = bcd_data % 10;
    assign digit_10 = (bcd_data / 10) % 10;
    assign digit_100 = (bcd_data / 100) % 10;
    assign digit_1000 = (bcd_data / 1000) % 10;
endmodule



module bcd_decoder_sr04 (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);
    always @(bcd) begin
        case (bcd)
            4'b0000: fnd_data = 8'hc0;
            4'b0001: fnd_data = 8'hF9;
            4'b0010: fnd_data = 8'hA4;
            4'b0011: fnd_data = 8'hB0;
            4'b0100: fnd_data = 8'h99;
            4'b0101: fnd_data = 8'h92;
            4'b0110: fnd_data = 8'h82;
            4'b0111: fnd_data = 8'hF8;
            4'b1000: fnd_data = 8'h80;
            4'b1001: fnd_data = 8'h90;
            4'b1010: fnd_data = 8'h88;
            4'b1011: fnd_data = 8'h83;
            4'b1100: fnd_data = 8'hc6;
            4'b1101: fnd_data = 8'hA1;
            4'b1110: fnd_data = 8'h7f;
            4'b1111: fnd_data = 8'hff;
            default: fnd_data = 8'hff;
        endcase
    end
endmodule
