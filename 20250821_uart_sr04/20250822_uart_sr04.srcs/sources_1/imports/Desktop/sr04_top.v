`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/20 10:24:34
// Design Name: 
// Module Name: sr04_top
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


module sr04_top(
    input clk,
    input rst,
    input start,
    input echo,
    output trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );
    // input clk,
    // input rst,
    // input start,
    // input echo,
    // output o_trig,
    // output [8:0] o_dist
    // );

    // wire w_tick_1us;

    // tick_gen_1us U_TICK_GEN_1US(
    //     .clk(clk),
    //     .rst(rst),
    //     .o_tick_1us(w_tick_1us)
    // );

    // sr04_controller U_SR04_CONTROLLER(
    //     .clk(clk),
    //     .rst(rst),
    //     .start(start),
    //     .echo(echo),
    //     .i_tick(w_tick_1us),
    //     .o_trig(o_trig),
    //     .o_dist(o_dist)
    // );
    wire w_tick_1us;
    wire [8:0] w_dist;

    tick_gen_1us U_TICK_GEN_1US(
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_tick_1us)
    );

    button_debounce U_BD(
        .clk(clk), 
        .rst(rst),
        .i_btn(start),
        .o_btn(w_start)
    );

    sr04_controller U_SR04_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .start(w_start),
        .echo(echo),
        .i_tick(w_tick_1us),
        .o_trig(trig),
        .o_dist(w_dist)
    );

    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(rst),
        .counter({5'b0,w_dist}),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );


endmodule

module sr04_controller(
    input clk,
    input rst,
    input start,
    input echo,
    input i_tick,
    output o_trig,
    output [8:0] o_dist
);
    parameter [1:0] IDLE = 2'b00, START = 2'b01, WAIT = 2'b10, DIST_CAL = 2'b11;
    reg [1:0] state, state_next;
    reg [8:0] dist, dist_next;
    reg echo_done, echo_done_next;
    reg [3:0] tick_cnt, tick_cnt_next;
    reg [14:0] tick_cnt_1us, tick_cnt_1us_next;
    reg trig, trig_next;

    assign o_dist = dist;
    assign o_trig = trig;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state <= 0;
            dist <= 0;
            echo_done <= 0;
            tick_cnt <= 0;
            trig <= 0;
            tick_cnt_1us <= 0;
        end else begin
            state <= state_next;
            dist <= dist_next;
            echo_done <= echo_done_next;
            tick_cnt <= tick_cnt_next;
            trig <= trig_next;
            tick_cnt_1us <= tick_cnt_1us_next;
        end
    end

    always@(*) begin
        state_next = state;
        dist_next = dist;
        echo_done_next = echo_done;
        tick_cnt_next = tick_cnt;
        trig_next = trig;
        tick_cnt_1us_next = tick_cnt_1us;
        case(state)
            IDLE : begin
                trig_next = 1'b0;
                echo_done_next = 1'b0;
                if(start) begin
                    trig_next = 1'b1;
                    state_next = START;
                end
            end
            START : begin
                if(i_tick) begin
                    if(tick_cnt == 10) begin
                        trig_next = 1'b0;
                        state_next = WAIT;
                    end else begin
                        trig_next = 1'b0;
                        tick_cnt_next = tick_cnt + 1;
                    end
                end
            end
            WAIT : begin
                trig_next = 1'b0;
                tick_cnt_1us_next = 1'b0;
                if(i_tick) begin
                    if(echo) begin
                        state_next = DIST_CAL;
                    end
                end
            end
            DIST_CAL : begin
                if(i_tick) begin
                    tick_cnt_1us_next = tick_cnt_1us + 1;
                end
                if(echo == 0) begin
                    echo_done_next = 1'b1;
                    // dist_next = tick_cnt_1us / 58;
                    state_next = IDLE;
                    if(tick_cnt_1us >= 23200) begin 
                        dist_next = 9'd400;
                    end else begin
                        dist_next = tick_cnt_1us / 58;
                    end
                end
                end
        endcase
    end


endmodule

module tick_gen_1us(
    input clk,
    input rst,
    output o_tick_1us
);

    parameter TICK_COUNT = 100_000_000 / 1_000_000;
    reg [$clog2(TICK_COUNT) - 1 : 0] counter_reg;
    reg tick_1us;

    assign o_tick_1us = tick_1us;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            tick_1us <= 0;
        end else begin
            if(counter_reg == TICK_COUNT - 1) begin   
                counter_reg = 0;
                tick_1us = 1;
            end else begin
                counter_reg = counter_reg + 1;
                tick_1us = 0;
            end
        end
    end

    // parameter TICK_COUNT = 100_000_000 / 1_000_000;
    // reg [$clog2(TICK_COUNT) - 1 : 0] counter_reg, counter_next;
    // reg tick_reg, tick_next;

    // assign o_tick_1us = tick_reg;

    // always@(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         counter_reg <= 0;
    //         tick_reg <= 0;
    //     end else begin
    //         counter_reg <= counter_next;
    //         tick_reg <= tick_next;
    //     end
    // end
        
    // always@(*) begin
    //     counter_next = counter_reg;
    //     tick_next = tick_reg;
    //     if(counter_reg == TICK_COUNT - 1) begin   
    //         counter_next = 0;
    //         tick_next = 1;
    //     end else begin
    //         counter_next = counter_reg + 1;
    //         tick_next = 0;
    //     end
    // end

endmodule