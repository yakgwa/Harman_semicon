`timescale 1ns / 1ps

module stopwatch_cu (
    input  clk,
    input  rst,
    input  i_runstop_pulse,  // input_runstop
    input  i_clear_pulse,
    output o_runstop,  // ouput_runstop
    output o_clear
);

    // state define
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] c_state, n_state;  // current_state, next_state
    reg runstop_reg, runstop_next;
    reg clear_reg, clear_next;

    assign o_runstop = runstop_reg;
    assign o_clear   = clear_reg;

    // state register SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state     <= STOP;  // 순차로직이니까 nonblock으로 설계
            runstop_reg <= 1'b0;
            clear_reg   <= 1'b0;
        end else begin
            c_state     <= n_state;
            runstop_reg <= runstop_next;
            clear_reg   <= clear_next;
        end
    end

    // next combinational logic
    always @(*) begin
        // latch 방지를 위해 초기화!
        n_state      = c_state;
        runstop_next = runstop_reg;
        clear_next   = clear_reg;

        case (c_state)
            STOP: begin
                // moore output
                runstop_next = 1'b0;
                clear_next   = 1'b0;
                // next state
                if (i_runstop_pulse) begin
                    n_state = RUN;
                end else if (i_clear_pulse) begin
                    n_state = CLEAR;
                end
            end
            RUN: begin
                runstop_next = 1'b1;
                if (i_runstop_pulse) begin
                    n_state = STOP;
                end
            end
            CLEAR: begin
                clear_next = 1'b1;
                n_state = STOP;
            end
        endcase
    end

endmodule
