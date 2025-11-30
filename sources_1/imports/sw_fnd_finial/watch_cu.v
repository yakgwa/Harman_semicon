`timescale 1ns / 1ps

module watch_cu (
    input            clk,
    input            rst,
    input            i_btn_l,
    input            i_btn_r, 
    input            i_btn_u,
    input            i_btn_d,
    input            i_btn_c,
    output reg       o_hour_set,
    output reg       o_min_set,
    output reg       o_sec_set,
    output reg [4:0] o_hour_value,
    output reg [5:0] o_min_value,
    output reg [5:0] o_sec_value,
    output           o_clear,
    output     [1:0] o_state,
    output           o_set_mode_active
);

    parameter S_IDLE = 2'b00;
    parameter S_SET_HOUR = 2'b01;
    parameter S_SET_MIN = 2'b10;
    parameter S_SET_SEC = 2'b11;

    reg [1:0] c_state, n_state;
    reg [4:0] hour_reg;
    reg [5:0] min_reg;
    reg [5:0] sec_reg;

    wire up_pulse, down_pulse, left_pulse, right_pulse;

    btn_pulse_gen U_PULSE_U (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn_u),
        .o_pulse(up_pulse)
    );
    btn_pulse_gen U_PULSE_D (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn_d),
        .o_pulse(down_pulse)
    );
    btn_pulse_gen U_PULSE_L (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn_l),
        .o_pulse(left_pulse)
    );
    btn_pulse_gen U_PULSE_R (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn_r),
        .o_pulse(right_pulse)
    );

    assign o_clear = i_btn_c;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= S_IDLE;
            hour_reg <= 0;
            min_reg  <= 0;
            sec_reg  <= 0;
        end else begin
            c_state <= n_state;

            if (up_pulse) begin
                case (c_state)
                    S_SET_HOUR: hour_reg <= (hour_reg == 23) ? 0 : hour_reg + 1;
                    S_SET_MIN: min_reg <= (min_reg == 59) ? 0 : min_reg + 1;
                    S_SET_SEC: sec_reg <= (sec_reg == 59) ? 0 : sec_reg + 1;
                endcase
            end else if (down_pulse) begin
                case (c_state)
                    S_SET_HOUR: hour_reg <= (hour_reg == 0) ? 23 : hour_reg - 1;
                    S_SET_MIN: min_reg <= (min_reg == 0) ? 59 : min_reg - 1;
                    S_SET_SEC: sec_reg <= (sec_reg == 0) ? 59 : sec_reg - 1;
                endcase
            end
        end
    end

    always @(*) begin
        n_state = c_state;

        case (c_state)
            S_IDLE: begin
                if (left_pulse || right_pulse) begin
                    n_state = S_SET_HOUR;
                end
            end
            S_SET_HOUR: begin
                if (right_pulse) begin
                    n_state = S_SET_MIN;
                end else if (left_pulse) begin
                    n_state = S_IDLE;
                end
            end
            S_SET_MIN: begin
                if (right_pulse) begin
                    n_state = S_SET_SEC;
                end else if (left_pulse) begin
                    n_state = S_SET_HOUR;
                end
            end
            S_SET_SEC: begin
                if (right_pulse) begin
                    n_state = S_IDLE;
                end else if (left_pulse) begin
                    n_state = S_SET_MIN;
                end
            end
        endcase
    end

    always @(*) begin
        o_hour_set   = 1'b0;
        o_min_set    = 1'b0;
        o_sec_set    = 1'b0;
        o_hour_value = hour_reg;
        o_min_value  = min_reg;
        o_sec_value  = sec_reg;

        case (c_state)
            S_SET_HOUR: begin
                if (up_pulse || down_pulse) begin
                    o_hour_set = 1'b1;
                end
            end

            S_SET_MIN: begin
                if (up_pulse || down_pulse) begin
                    o_min_set = 1'b1;
                end
            end

            S_SET_SEC: begin
                if (up_pulse || down_pulse) begin
                    o_sec_set = 1'b1;
                end
            end
        endcase
    end
    assign o_set_mode_active = (c_state != S_IDLE);
    assign o_state = c_state;

endmodule
