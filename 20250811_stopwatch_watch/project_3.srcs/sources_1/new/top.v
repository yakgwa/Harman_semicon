`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/11 13:32:49
// Design Name: 
// Module Name: top
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


module top(
    input clk, reset, 
    input btn_0,
    input btn_1,
    input [1:0] mod_sel, 
    input Btn_L, Btn_R, Btn_U, Btn_D,
    output [3:0] fnd_com, 
    output [7:0] fnd_data,
    output [1:0] led
    );

    wire [23:0] w_time_1;
    wire [23:0] w_time_2;
    wire [23:0] w_time_3;

    led_1x2 U_LED(
        .mod_sel(mod_sel),
        .led(led)
    );

    stopwatch U_SW(
        .clk(clk),
        .reset(reset),
        .mod_sel(mod_sel[0]), 
        .Btn_L(Btn_L),
        .Btn_R(Btn_R),
        .i_time(w_time_1)
        //.btn_0(btn_0),
        // .fnd_com(w_fnd_com_1),
        // .fnd_data(w_fnd_data_1)
    );
    
    watch U_W(
        .clk(clk),
        .reset(reset),
        .mod_sel(mod_sel[1]),
        .Btn_U(Btn_U),
        .Btn_L(Btn_L),
        .Btn_D(Btn_D),
        .i_time(w_time_2),
        .btn_0(btn_0)
        // .fnd_com(w_fnd_com_2),
        // .fnd_data(w_fnd_data_2)
        );

    mux U_MUX_(
        .i_time_1(w_time_1),
        .i_time_2(w_time_2),
        .sel(btn_1),
        .bcd(w_time_3)
    );

    fnd_controller U_FND_CTRL(
    .clk(clk),
    .reset(reset),
    .i_time(w_time_3),
    .btn_0(btn_0),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
    );

endmodule


module led_1x2(
    input mod_sel,
    output reg [1:0] led
        );

    always@(*) begin
        case(mod_sel)
            2'b00 : 
                led = 2'b01;
            2'b01 :
                led = 2'b10;
            default : led = 2'b00;
        endcase
    end

endmodule


module mux(
    input [23:0] i_time_1,
    input [23:0] i_time_2,
    input sel,
    output [23:0] bcd
);

    assign bcd = sel ? i_time_2 : i_time_1;

endmodule