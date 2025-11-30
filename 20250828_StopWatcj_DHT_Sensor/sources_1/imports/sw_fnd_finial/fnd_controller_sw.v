`timescale 1ns / 1ps

module fnd_controller (
    input         clk,
    input         reset,
    input         mode,
    input         sw_mode,
    input  [23:0] i_sw_time,
    input  [23:0] i_w_time,
    input  [ 1:0] i_w_state,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data
);

    wire [3:0] w_bcd, w_dot_data, w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [3:0] w_msec_sec, w_min_hour;
    wire [2:0] w_sel;
    wire w_clk_1khz;

    wire [23:0] selected_time;
    assign selected_time = (sw_mode == 1'b0) ? i_sw_time : i_w_time;

    reg  [19:0] blink_counter;
    wire blink_en;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            blink_counter <= 0;
        end else begin
            blink_counter <= blink_counter + 1;
        end
    end

    assign blink_en = blink_counter[19];

    clk_div_1khz U_CLK_DIV_1KHZ (
        .clk(clk),
        .reset(reset),
        .o_clk_1khz(w_clk_1khz)
    );

    counter_8 U_COUNTER_8 (
        .clk  (w_clk_1khz),
        .reset(reset),
        .sel  (w_sel)
    );

    decoder_2x4 U_DECODER_2x4 (
        .sel(w_sel[1:0]),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_MSEC_DS (
        .count_data(selected_time[6:0]),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_SEC_DS (
        .count_data(selected_time[12:7]),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_MIN_DS (
        .count_data(selected_time[18:13]),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_HOUR_DS (
        .count_data(selected_time[23:19]),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    comparator_msec U_COMP_DOT(
    .msec(selected_time[6:0]),
    .dot_data(w_dot_data)
    );

    wire [3:0] final_hour_d10, final_hour_d1;
    wire [3:0] final_min_d10, final_min_d1;
    wire [3:0] final_sec_d10, final_sec_d1;

    parameter S_SET_HOUR = 2'b01;
    parameter S_SET_MIN  = 2'b10;
    parameter S_SET_SEC  = 2'b11;

    assign final_hour_d10 = (sw_mode && i_w_state == S_SET_HOUR && blink_en) ? 4'hF : w_hour_digit_10;
    assign final_hour_d1  = (sw_mode && i_w_state == S_SET_HOUR && blink_en) ? 4'hF : w_hour_digit_1;
    
    assign final_min_d10 = (sw_mode && i_w_state == S_SET_MIN && blink_en) ? 4'hF : w_min_digit_10;
    assign final_min_d1  = (sw_mode && i_w_state == S_SET_MIN && blink_en) ? 4'hF : w_min_digit_1;

    assign final_sec_d10 = (sw_mode && i_w_state == S_SET_SEC && blink_en) ? 4'hF : w_sec_digit_10;
    assign final_sec_d1  = (sw_mode && i_w_state == S_SET_SEC && blink_en) ? 4'hF : w_sec_digit_1;



    // msec_sec
    mux_8x1 U_MUX_8X1_MSEC_SEC (
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10),
        .digit_100 (final_sec_d1),
        .digit_1000(final_sec_d10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_msec_sec)
    );

    // min_hour
    mux_8x1 U_MUX_8X1_MIN_HOUR (
        .digit_1(final_min_d1),
        .digit_10(final_min_d10),
        .digit_100(final_hour_d1),
        .digit_1000(final_hour_d10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_min_hour)
    );

    mux_2x1 U_MUX_2X1 (
        .sel(mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    bcd_decoder U_BCD_DECODER (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );
endmodule

module comparator_msec (
    input  [6:0] msec,
    output [3:0] dot_data
);
    
    assign dot_data = (msec < 50) ? 4'hf:4'he;

endmodule

module clk_div_1khz (
    input  clk,
    input  reset,
    output o_clk_1khz
);

    // counter 100,000
    reg [$clog2(
100000
) - 1 : 0]
        r_counter;  //$clog2(100000) : 이진수 비트 수 표현 = 2^17 ∴ 17
    reg r_clk_1khz;
    assign o_clk_1khz = r_clk_1khz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter  <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 100000 - 1) begin
                r_counter  <= 0;
                r_clk_1khz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end

endmodule

// 4진 카운터 => 8진 카운터로 변경
module counter_8 (
    input        clk,    // clock
    input        reset,
    output [2:0] sel
);

    reg [2:0] counter;
    assign sel = counter;
    always @(posedge clk, posedge reset) begin // clk 또는 reset 이 상승edge 가 발생했을 때
        if (reset) begin
            // initial(초기화)
            counter <= 0;  // <= : 출력을 이쪽으로 해라
        end else begin
            // opertion(동작해라)
            counter <= counter + 1;
        end
    end

endmodule

module decoder_2x4 (
    input  [1:0] sel,
    output [3:0] fnd_com
);

    assign fnd_com = (sel == 2'b00) ? 4'b1110:
                     (sel == 2'b01) ? 4'b1101:
                     (sel == 2'b10) ? 4'b1011:
                     (sel == 2'b11) ? 4'b0111:4'b1111; // 조건이 있으면 무조건 넣어주기(4'b1111 은 없으니까)

endmodule

module mux_2x1 (
    input        sel,
    input  [3:0] msec_sec,
    input  [3:0] min_hour,
    output [3:0] bcd
);

    assign bcd = sel ? min_hour : msec_sec;

endmodule

// 4x1 -> 8x1
module mux_8x1 (
    input      [3:0] digit_1,
    input      [3:0] digit_10,
    input      [3:0] digit_100,
    input      [3:0] digit_1000,
    input      [3:0] digit_5,
    input      [3:0] digit_6,
    input      [3:0] digit_7,     // digit dot display
    input      [3:0] digit_8,
    input      [2:0] sel,
    output reg [3:0] bcd
);

    always @(*) begin  // * : 모든 입력을 감시하겠다
        case (sel)
            3'b000:  bcd = digit_1;
            3'b001:  bcd = digit_10;
            3'b010:  bcd = digit_100;
            3'b011:  bcd = digit_1000;
            3'b100:  bcd = digit_5;
            3'b101:  bcd = digit_6;
            3'b110:  bcd = digit_7;
            3'b111:  bcd = digit_8;
            default: bcd = digit_1;
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH-1:0] count_data,
    output [          3:0] digit_1,
    output [          3:0] digit_10
);

    assign digit_1  = count_data % 10;
    assign digit_10 = (count_data / 10) % 10;

endmodule

module bcd_decoder (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'b0000: fnd_data = 8'hc0;  //
            4'b0001: fnd_data = 8'hF9;
            4'b0010: fnd_data = 8'hA4;
            4'b0011: fnd_data = 8'hB0;
            4'b0100: fnd_data = 8'h99;
            4'b0101: fnd_data = 8'h92;
            4'b0110: fnd_data = 8'h82;
            4'b0111: fnd_data = 8'hF8;
            4'b1000: fnd_data = 8'h80;
            4'b1001: fnd_data = 8'h90;  // 0 ~ 9
            4'b1010: fnd_data = 8'h88;
            4'b1011: fnd_data = 8'h83;
            4'b1100: fnd_data = 8'hc6;
            4'b1101: fnd_data = 8'ha1;
            4'b1110: fnd_data = 8'h7f;  // only dot display
            4'b1111: fnd_data = 8'hff;  // all off
            default: fnd_data = 8'hff;
        endcase
    end

endmodule
