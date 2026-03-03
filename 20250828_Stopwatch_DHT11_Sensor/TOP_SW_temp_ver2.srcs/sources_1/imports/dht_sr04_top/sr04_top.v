`timescale 1ns / 1ps
module sr04_top (
    input        clk,
    input        rst,
    input        start,
    input        uart_start,
    input        echo,
    output       trig,
    output       cal_don,
    output [11:0]dist_data,     
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [31:0] w_send_data;
    wire w_tick_1us;
    wire [11:0] w_dist_data;
    wire w_start;
    wire w_empty_ctrl;
    wire [7:0] w_ctrl_data, w_tx_data;
    wire w_pop;
    wire w_tx_full;
    wire w_send_done;

    
    sr04_controller U_SR04_CTRL (
        .clk(clk),
        .rst(rst),
        .start(w_start || uart_start),
        .i_tick(w_tick_1us),
        .echo(echo),
        .o_trig(trig),
        .cal_don(cal_don),
        .o_dist(w_dist_data),
        .dist_data(dist_data)
    );
    fnd_controller_sr04 U_FND_CTRL_SR04(
    .clk(clk),
    .rst(rst),
    .i_dist(w_dist_data),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
    );
    button_debounce U_START_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(start),
        .o_btn(w_start)
    );
    tick_gen_1us_sr04 U_TICK_GEN_1US_SR04 (
    .clk(clk),
    .rst(rst),
    .o_tick_1us(w_tick_1us)
);
    
endmodule

module sr04_controller (
    input        clk,
    input        rst,
    input        start,
    input        i_tick,
    input        echo,
    output       o_trig,
    output       cal_don,
    output [11:0] o_dist,
    output [11:0] dist_data
);


     parameter  IDLE = 3'b000, START = 3'b001, WAIT = 3'b010, 
               DIST = 3'b011,CAL_MUL = 3'b100, CAL_SHIFT = 3'b101, CAL = 3'b110;

    reg [2:0] state, next;
    reg [11:0] dist_cur, dist_next;
    reg start_trig_cur, start_trig_next;
    reg cal_done_reg, cal_done_next;

    reg [$clog2(40000)-1:0] tick_cnt_reg;
    reg [$clog2(40000)-1:0] tick_cnt_next;

    assign o_trig = start_trig_cur;
    assign o_dist = dist_cur;
    assign cal_don = cal_done_reg;
    assign dist_data = dist_cur;

    
    reg [27:0] mul_reg, mul_next;   
    reg [11:0] div_reg, div_next;   

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state           <= IDLE;
            tick_cnt_reg    <= 0;
            start_trig_cur  <= 0;
            dist_cur        <= 0;
            cal_done_reg    <= 0;
            mul_reg         <= 0;
            div_reg         <= 0;
        end else begin
            state           <= next;
            start_trig_cur  <= start_trig_next;
            dist_cur        <= dist_next;
            tick_cnt_reg    <= tick_cnt_next;
            cal_done_reg    <= cal_done_next;
            mul_reg         <= mul_next;
            div_reg         <= div_next;
            
        end
    end

    // next state logic
    always @(*) begin
        next = state;
        dist_next = dist_cur;
        start_trig_next = start_trig_cur;
        tick_cnt_next = tick_cnt_reg;
        cal_done_next = 0;
        mul_next = mul_reg;
        div_next = div_reg;
        case (state)
            IDLE: begin
                tick_cnt_next = 0;
                if (start) begin
                    start_trig_next = 0;
                    next = START;
                end
            end

            START: begin
                if (i_tick) begin
                    tick_cnt_next   = tick_cnt_reg + 1;
                    start_trig_next = 1'b1;
                    if (tick_cnt_reg == 10) begin
                        tick_cnt_next   = 0;
                        start_trig_next = 1'b0;
                        next = WAIT;
                    end
                end
            end

            WAIT: begin
                if (echo) begin
                    if (i_tick) begin
                        tick_cnt_next = 0;
                        next = DIST;
                    end
                end
            end

            DIST: begin
                if (echo == 1) begin
                    if (i_tick) begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end else begin
                    next = CAL_MUL;
                end
            end
            CAL_MUL:begin
                mul_next = tick_cnt_reg * 5650; 
                next = CAL_SHIFT;
            end

            CAL_SHIFT: begin
                div_next = mul_reg >> 15;
                next = CAL;
            end
            CAL:begin
                cal_done_next = 1;
                dist_next     = div_reg; // 파이프라인 결과 사용
                next          = IDLE;
            end
        endcase
    end



endmodule



module tick_gen_1us_sr04 (
    input  clk,
    input  rst,
    output o_tick_1us
);

    //1us
    parameter FCOUNT = 100_000_000 / 100_000_0;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_tick;

    assign o_tick_1us = r_tick;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_tick <= 0;
            r_counter <= 0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                r_tick <= 1;
                r_counter <= 0;
            end else begin
                r_tick = 0;
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule
