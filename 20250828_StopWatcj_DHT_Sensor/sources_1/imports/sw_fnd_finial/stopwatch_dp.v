`timescale 1ns / 1ps

module stopwatch_dp (
    input        clk,
    input        rst,
    input        i_runstop,
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
    ) U_MSEC_COUNTER (
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
    ) U_SEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .i_clear(i_clear),
        .o_time(sec),
        .o_tick(w_min_tick)
    );
    //////////////////////////////////////////
    // min_counter
    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_MIN_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .i_clear(i_clear),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    // hour_counter
    time_counter #(
        .BIT_WIDTH (5),
        .TIME_COUNT(24)
    ) U_HOUR_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .i_clear(i_clear),
        .o_time(hour),
        .o_tick()
    );
    //////////////////////////////////////////
    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .o_tick_100hz(w_tick_100hz)
    );
endmodule

module tick_gen_100hz (
    input  clk,
    input  rst,
    input  i_runstop,
    output o_tick_100hz
);
    parameter FCOUNT = 100_000_000 / 100;
    reg [$clog2(FCOUNT) - 1 : 0] r_counter;
    reg r_tick;

    assign o_tick_100hz = r_tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_tick    <= 1'b0;
        end else begin
            if (i_runstop == 1'b1) begin
                if (r_counter == FCOUNT - 1) begin
                    r_counter <= 0;
                    r_tick    <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick    <= 1'b0;
                end
            end
        end
    end
endmodule


