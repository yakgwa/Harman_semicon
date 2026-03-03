`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 13:39:20
// Design Name: 
// Module Name: up_counter
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

module up_counter(
    input clk,
    input reset,
    input i_run,
    input i_clear,
    input i_updown,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

wire w_tick_10hz;
wire [13:0] w_counter;
wire w_o_run;
wire w_o_clear;

counter_controller U_COUNTER_CONTROLLER(
    .clk(clk),
    .reset(reset),
    .i_run(i_run),    
    .o_run(w_o_run),
    .i_clear(i_clear),
    .o_clear(w_o_clear)
);
fnd_controller U_FND_CNTL(
    .clk(clk),
    .reset(reset),
    .counter(w_counter),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
);
clk_gen_10hz U_CLK_GEN_10HZ(
    .clk(clk),
    .reset(reset),
    .o_clk_10hz(w_tick_10hz)
);

counter_10000 U_COUNTER_10000(
    .clk(w_tick_10hz),
    .reset(reset),
    .enable(w_o_run),
    .o_counter(w_counter),
    .updown(i_updown),
    .clear(w_o_clear)
);
endmodule

module counter_controller(
    input clk,
    input reset,
    input i_run,    
    input i_clear,
    output reg o_run,
    output reg o_clear
);

    reg [1:0] state, next_state;
    parameter IDLE = 2'b00, RUN  = 2'b01, CLEAR = 2'b10 ;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

always @(*) begin
    case (state)
        IDLE: begin
            if (i_run)
                next_state = RUN;
            else if (i_clear)
                next_state = CLEAR;            
            else
                next_state = IDLE;
        end
        RUN: begin
            if (!i_run)
                next_state = IDLE;
            else
                next_state = RUN; 
        end
        CLEAR: begin
            if (!i_clear)
                next_state = IDLE;
            else
                next_state = CLEAR; 
        end
        default: next_state = IDLE;
    endcase
end

    always @(*) begin
        case (state)
            IDLE: begin o_run = 1'b0; o_clear = 1'b0; end
            RUN : begin o_run = 1'b1; o_clear = 1'b0; end
            CLEAR : begin o_run = 1'b0; o_clear = 1'b1; end
            default: begin o_run = 1'b0; o_clear = 1'b0; end
        endcase
    end

endmodule

module counter_10000(
    input clk,
    input reset,
    input updown,
    input enable,
    input clear,
    output [13:0] o_counter
);

reg [$clog2(10_000) - 1 : 0] r_counter;

assign o_counter = r_counter;

always@(posedge clk or posedge reset) begin
    if(reset || clear) begin
        r_counter <= 0;
    end else if(enable) begin
        if (updown) begin  
            if (r_counter == 9999)
                r_counter <= 0;
            else
                r_counter <= r_counter + 1;
        end else begin    
            if (r_counter == 0)
                r_counter <= 9999;
            else
                r_counter <= r_counter - 1;
        end
    end
end

endmodule


module clk_gen_10hz(
    input clk,
    input reset,
    output o_clk_10hz
);

// counter 10_000_000
parameter F_COUNTER = 10_000_000;
reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
reg r_clk_10kz;

assign o_clk_10hz = r_clk_10kz;

always@(posedge clk or posedge reset) begin
    if(reset) begin
        r_counter <= 0;
        r_clk_10kz <= 1;
    end else begin
        if(r_counter == F_COUNTER -1) begin
            r_counter <= 0;
            r_clk_10kz <= 1'b1;
        end else begin
            if(r_counter == F_COUNTER/2 - 1) begin
                r_clk_10kz <= 1'b0;
            end
            r_counter <= r_counter + 1;
        end
    end
end

endmodule