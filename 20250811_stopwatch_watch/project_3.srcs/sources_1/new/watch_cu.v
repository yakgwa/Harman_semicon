`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/11 11:44:00
// Design Name: 
// Module Name: watch_cu
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


module watch_cu(
    input clk,
    input reset,
    input mod_sel,
    input i_btn_left,
    input i_btn_up,
    input i_btn_down,
    output o_sec,
    output o_min,
    output o_hour  
    );
    parameter STOP = 2'b00, SEC = 2'b01, MIN = 2'b10, HOUR = 2'b11;
    reg [1:0] c_state, n_state;
    reg sec_reg, sec_next;
    reg min_reg, min_next;
    reg hour_reg, hour_next;

    assign o_sec = sec_reg;
    assign o_min = min_reg;
    assign o_hour = hour_reg;
    // state register
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            c_state <= STOP;
            sec_reg <= 1'b0;
            min_reg <= 1'b0;
            hour_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            sec_reg <= sec_next;
            min_reg <= min_next;
            hour_reg <= hour_next;
        end
    end
    // next combinational logic
    always@(*) begin
        n_state = c_state;
        sec_next = sec_reg;
        min_next = min_reg;
        hour_next = hour_reg;
        if(mod_sel) begin
        case(c_state)
                STOP : begin
                    // moore output
                    sec_next = 1'b0;
                    min_next = 1'b0;
                    hour_next = 1'b0;
                    // next state
                    if(i_btn_left) begin
                        n_state = MIN;
                    end else if(i_btn_up) begin
                        n_state = SEC;
                    end else if(i_btn_down) begin
                        n_state = HOUR;
                    end
                end
                SEC : begin
                    sec_next = 1'b1;
                    if(i_btn_up == 1'b0) begin                
                        n_state = STOP;
                    end
                end
                MIN : begin
                    min_next = 1'b1;
                    if(i_btn_left == 1'b0) begin                
                        n_state = STOP;
                    end
                end
                HOUR : begin
                    hour_next = 1'b1;
                    if(i_btn_down == 1'b0) begin                
                        n_state = STOP;
                    end
                end
            endcase
        end
    end
    // output logic
    // 현재 상태 출력을 next_combinational logic에 in
endmodule
