`timescale 1ns / 1ps

module watch_dp (
    input        clk,
    input        rst,
    input        i_set_mode_active,
    input        i_hour_set,
    input  [4:0] i_hour_value,
    input        i_min_set,
    input  [5:0] i_min_value,
    input        i_sec_set,
    input  [5:0] i_sec_value,
    input        i_clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    // msec_counter
    time_counter #(
        .BIT_WIDTH (7),
        .TIME_COUNT(100)
    ) U_WC_MSEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_clear(i_clear),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );
    // sec_counter
    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_WC_SEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .i_clear(i_clear),
        .i_set(i_sec_set),
        .i_set_value(i_sec_value),
        .o_time(sec),
        .o_tick(w_min_tick)
    );
    // min_counter
    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_WC_MIN_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .i_clear(i_clear),
        .i_set(i_min_set),
        .i_set_value(i_min_value),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    // hour_counter
    time_counter #(
        .BIT_WIDTH (5),
        .TIME_COUNT(24)
    ) U_WC_HOUR_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .i_clear(i_clear),
        .i_set(i_hour_set),
        .i_set_value(i_hour_value),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .i_runstop(~i_set_mode_active),
        .o_tick_100hz(w_tick_100hz)
    );
endmodule

module time_counter #(
    parameter BIT_WIDTH = 7,
    TIME_COUNT = 100
) (
    input clk,
    input rst,
    input i_tick,
    input i_clear,
    input i_set,
    input [BIT_WIDTH - 1 : 0] i_set_value,
    output [BIT_WIDTH - 1 : 0] o_time,
    output o_tick
);

    // state define
    reg [$clog2(TIME_COUNT) - 1 : 0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    // state register SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    // next combinational logic
    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;

        if (i_tick) begin
            if (count_reg == TIME_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
            end
        end

        if (i_set == 1'b1) begin
            count_next = i_set_value;
        end

        if (i_clear == 1'b1) begin
            count_next = 0;
        end
    end
endmodule



