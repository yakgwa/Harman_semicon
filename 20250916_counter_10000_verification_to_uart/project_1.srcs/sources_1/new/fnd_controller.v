`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 16:18:17
// Design Name: 
// Module Name: fnd_controller
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


module fnd_controller(
    input clk,
    input rst,
    input [13:0] counter,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

    wire [3:0] w_digit_1;
    wire [3:0] w_digit_10;
    wire [3:0] w_digit_100;
    wire [3:0] w_digit_1000;
    wire [3:0] w_bcd;

    wire w_clk_1khz;
    wire [1:0] w_sel;

    clk_1khz U_CLK_1KHZ(
        .clk(clk),
        .rst(rst),
        .o_tick(w_clk_1khz)
    );

    counter_4 U_COUNTER_4(
        .clk(w_clk_1khz),
        .rst(rst),
        .o_sel(w_sel)
    );

    decoder_2x4 U_DECODER_2X4(
        .sel(w_sel),
        .fnd_com(fnd_com)
    );

    digit_spliter U_DIGIT_SPLITER(
        .i_counter(counter),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );

    mux_4x1 U_MUX_4X1(
        .i_data_1(w_digit_1),
        .i_data_10(w_digit_10),
        .i_data_100(w_digit_100),
        .i_data_1000(w_digit_1000),
        .sel(w_sel),
        .o_bcd(w_bcd)
    );

    bcd_decoder U_BCD_DECODER(
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

module digit_spliter(
    input [13:0] i_counter,
    output [3:0] o_digit_1,
    output [3:0] o_digit_10,
    output [3:0] o_digit_100,
    output [3:0] o_digit_1000
);
    assign o_digit_1 = i_counter % 10;
    assign o_digit_10 = (i_counter/10) % 10;
    assign o_digit_100 = (i_counter/100) % 10;
    assign o_digit_1000 = (i_counter/1000) % 10;


endmodule

module mux_4x1(
    input [3:0] i_data_1,
    input [3:0] i_data_10,
    input [3:0] i_data_100,
    input [3:0] i_data_1000,
    input [1:0] sel,
    output reg [3:0] o_bcd
);
    always@(*) begin
        case(sel)
            2'b00 : o_bcd = i_data_1;
            2'b01 : o_bcd = i_data_10;
            2'b10 : o_bcd = i_data_100;
            2'b11 : o_bcd = i_data_1000;
            default : o_bcd = i_data_1;
        endcase
    end


endmodule

module clk_1khz(
    input clk,
    input rst,
    output o_tick
    ); 

    parameter FCOUNT = 100_000_000 / 1000;
    reg r_clk_1khz;
    reg [$clog2(FCOUNT) - 1 : 0] r_counter; // for 10hz

    assign o_tick = r_clk_1khz;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            r_counter <= 0;
            r_clk_1khz <= 0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk_1khz <= 1;
            end else begin
                r_counter <= r_counter + 1;
                if (r_counter == FCOUNT/2 - 1) begin
                    r_clk_1khz <= 0;
                end
            //r_counter <= r_counter + 1;
            end
        end 
    end
endmodule

// module clk_1khz(
//     input clk,
//     input rst,
//     output o_tick
// );

//     // counter 10_000
//     reg [$clog2(100_000)-1 : 0] r_counter; //$clog2는 시스템에서 제공하는 task
//     reg r_clk_1khz;
//     assign o_clk_1khz = r_clk_1khz;

//     always@(posedge clk or posedge rst) begin
//         if(rst) begin
//             r_counter <= 0;
//             r_clk_1khz <= 1'b0;
//         end else begin
//             if (r_counter == 99_000) begin
//                 r_counter <= 0;
//                 r_clk_1khz <= 1'b1;
//             end else begin
//                 r_counter <= r_counter + 1'b1;
//                 r_clk_1khz <= 1'b0;
//             end
//         end
//     end

// endmodule

module counter_4(
    input clk,
    input rst,
    output [1:0] o_sel
    );

    reg [1:0] r_counter;

    assign o_sel = r_counter;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4(
    input [1:0] sel,
    output [3:0] fnd_com
);

    assign fnd_com = (sel == 2'b00) ? 4'b1110 :
                      (sel == 2'b01) ? 4'b1101 :
                      (sel == 2'b10) ? 4'b1011 :
                      (sel == 2'b11) ? 4'b0111 : 4'b1111;                  

endmodule

//     input clk,
//     input rst,
//     // input  [7:0] bcd,
//     input [13:0] counter,
//     //input [1:0] sel,
//     output [7:0] fnd_data,
//     output [3:0] fnd_com
// );

// //assign fnd_com = 4'b1110;

// wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
// wire [3:0] w_bcd;
// wire [1:0] w_sel;
// wire w_clk_1khz;

// clk_div_1khz U_CLK_DIV_1KHZ(
//     .clk(clk),
//     .rst(rst),
//     .o_clk_1khz(w_clk_1khz)
// );

// counter_4 U_COUNTER_4(
//     .clk(w_clk_1khz),
//     .rst(rst),
//     .sel(w_sel)
// );

// digit_spliter U_DS(
//     .count_data(counter),
//     .digit_1(w_digit_1),
//     .digit_10(w_digit_10),
//     .digit_100(w_digit_100),
//     .digit_1000(w_digit_1000)
// );

// decoder_2x4 U_DECODER_2x4(
//     .sel(w_sel),
//     .fnd_com(fnd_com)
// );

// mux_4x1 U_MUX_4x1(
//     .digit_1(w_digit_1),
//     .digit_10(w_digit_10),
//     .digit_100(w_digit_100),
//     .digit_1000(w_digit_1000),
//     .sel(w_sel),
//     .bcd(w_bcd)
// );

// bcd_decoder U_BCD_DECODER(
//     .bcd(w_bcd),
//     .fnd_data(fnd_data)
// );

// endmodule

// module clk_div_1khz(
//     input clk,
//     input rst,
//     output o_clk_1khz
// );

//     // counter 10_000
//     reg [$clog2(100_000)-1 : 0] r_counter; //$clog2는 시스템에서 제공하는 task
//     reg r_clk_1khz;
//     assign o_clk_1khz = r_clk_1khz;

//     always@(posedge clk or posedge rst) begin
//         if(rst) begin
//             r_counter <= 0;
//             r_clk_1khz <= 1'b0;
//         end else begin
//             if (r_counter == 99_000) begin
//                 r_counter <= 0;
//                 r_clk_1khz <= 1'b1;
//             end else begin
//                 r_counter <= r_counter + 1'b1;
//                 r_clk_1khz <= 1'b0;
//             end
//         end
//     end

// endmodule

// module counter_4(
//     input clk,
//     input rst,
//     output [1:0] sel
// );

//     reg [1:0] counter; // overflow가 나도 상관없음
//                        // always 구문에서 값을 받아서 저장하므로 합성기가 자동으로 Flip-flop 생성
//     assign sel = counter;

//     always@(posedge clk or posedge rst) begin 
//         if(rst) begin // clk의 상승엣지 or reset의 상승엣지가 발생했을때 begin ~ end 실행
//             // initial
//             counter <= 2'b00;
//         end else begin
//             // operation
//             counter <= counter + 1'b1;
//         end
//     end

// endmodule

// module decoder_2x4(
//     input [1:0] sel,
//     output [3:0] fnd_com
// );

//     assign fnd_com = (sel == 2'b00) ? 4'b1110 :
//                       (sel == 2'b01) ? 4'b1101 :
//                       (sel == 2'b10) ? 4'b1011 :
//                       (sel == 2'b11) ? 4'b0111 : 4'b1111;                  

// endmodule

// module mux_4x1(
//     input [3:0] digit_1,
//     input [3:0] digit_10,
//     input [3:0] digit_100,
//     input [3:0] digit_1000,
//     input [1:0] sel,
//     output [3:0] bcd
// );
//     reg [3:0] r_bcd;
//     assign bcd = r_bcd;

//     always@(*) begin
//         case(sel)
//             2'b00 : r_bcd = digit_1;
//             2'b01 : r_bcd = digit_10;
//             2'b10 : r_bcd = digit_100;
//             2'b11 : r_bcd = digit_1000;
//             default : r_bcd = digit_1;
//         endcase
//     end

// endmodule

// module digit_spliter(
//     input [13:0] count_data,
//     output [3:0] digit_1,
//     output [3:0] digit_10,
//     output [3:0] digit_100,
//     output [3:0] digit_1000
// );
//     assign digit_1 = count_data % 10;
//     assign digit_10 = (count_data / 10) % 10;
//     assign digit_100 = (count_data / 100) % 10;
//     assign digit_1000 = (count_data / 1000) % 10;

//     // always@(*) begin
//     //     case(bcd_data)
//     // end

// endmodule

// module bcd_decoder(
//     input  [3:0] bcd,
//     output reg [7:0] fnd_data
// );

//     always@(*) begin 
//         case(bcd)
//         4'b0000 :  fnd_data = 8'hc0;
//         4'b0001 :  fnd_data = 8'hF9; 
//         4'b0010 :  fnd_data = 8'hA4;
//         4'b0011 :  fnd_data = 8'hB0;
//         4'b0100 :  fnd_data = 8'h99;
//         4'b0101 :  fnd_data = 8'h92;
//         4'b0110 :  fnd_data = 8'h82;
//         4'b0111 :  fnd_data = 8'hF8;
//         4'b1000 :  fnd_data = 8'h80;
//         4'b1001 :  fnd_data = 8'h90;
//         4'b1010 :  fnd_data = 8'h88;
//         4'b1011 :  fnd_data = 8'h83;
//         4'b1100 :  fnd_data = 8'hc6;
//         4'b1101 :  fnd_data = 8'ha1;
//         4'b1110 :  fnd_data = 8'h86;
//         4'b1111 :  fnd_data = 8'h8e;
//         default :  fnd_data = 8'hff;
//         endcase
//     end

// endmodule
