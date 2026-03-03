`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/11 11:43:45
// Design Name: 
// Module Name: watch_dp
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


module watch_dp(
    input clk,
    input reset,
    input i_sec,
    input i_min,
    input i_hour,
    // output [6:0] msec,
    // output [5:0] sec,
    // output [5:0] min,
    // output [4:0] hour
    output [23:0] i_time
    );

    wire w_tick_100hz;
    wire w_sec_tick;
    wire w_min_tick;
    wire w_hour_tick;
    

    time_counter_1 #(.BIT_WIDTH(7), .TIME_COUNT(100), .INIT_VALUE(0)) U_MSEC_COUNTER(
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .i_btn(1'b0),
        .o_time(i_time[6:0]),
        //.o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter_1 #(.BIT_WIDTH(6), .TIME_COUNT(60), .INIT_VALUE(0)) U_SEC_COUNTER(
        .clk(clk),
        .reset(reset),
        .i_tick(w_sec_tick),
        .i_btn(i_sec),
        .o_time(i_time[12:7]),
        //.o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter_1 #(.BIT_WIDTH(6), .TIME_COUNT(60), .INIT_VALUE(59)) U_MIN_COUNTER(
        .clk(clk),
        .reset(reset),
        .i_tick(w_min_tick),
        .i_btn(i_min),
        .o_time(i_time[18:13]),
        //.o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter_1 #(.BIT_WIDTH(5), .TIME_COUNT(24), .INIT_VALUE(12)) U_HOUR_COUNTER(
        .clk(clk),
        .reset(reset),
        .i_tick(w_hour_tick),
        .i_btn(i_hour),
        .o_time(i_time[23:19]),
        //.o_time(hour),
        .o_tick()
    );


    tick_gen_100hz_1 U_TICK_GEN_100HZ(
        .clk(clk),
        .reset(reset),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule

module time_counter_1 #(parameter BIT_WIDTH = 7, TIME_COUNT = 100, INIT_VALUE = 0) (
    input clk,
    input reset,
    input i_tick,
    input i_btn,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
    );
    reg [$clog2(TIME_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    assign o_time = count_reg;
    assign o_tick = tick_reg;
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            count_reg <= INIT_VALUE;//0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end
    always@(*) begin
        count_next = count_reg;
        tick_next = 1'b0;
        if(i_btn) begin
            if(count_reg == TIME_COUNT-1) begin
                count_next = 0;
                tick_next = 1'b1;            
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        //end 
        end else if(i_tick) begin
            if(count_reg == TIME_COUNT-1) begin
                count_next = 0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                //tick_next = 1'b0;
            end
        end
    end


endmodule


module tick_gen_100hz_1(
    input clk,
    input reset,
    output o_tick_100hz
);
    parameter FCOUNT = 100_000_000 / 100;
    reg [$clog2(FCOUNT)-1 : 0 ] r_counter;
    reg r_tick;
    assign o_tick_100hz = r_tick;
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_tick <= 1'b0;
        end else begin
            if(r_counter == FCOUNT -1) begin
                r_counter <= 0;
                r_tick <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_tick <= 1'b0;
            end // else begin
                    //tick_next = 1'b0;
        end
    end


endmodule
