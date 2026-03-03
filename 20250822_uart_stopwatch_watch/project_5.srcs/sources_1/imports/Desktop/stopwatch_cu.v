`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/06 14:50:09
// Design Name: 
// Module Name: stopwatch_cu
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

module stopwatch_cu(
    input clk,
    input reset,
    input mod_sel,
    input i_runstop,
    input i_clear,
    output o_runstop,
    output o_clear    
    );
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] c_state, n_state;
    reg runstop_reg, runstop_next;
    reg clear_reg, clear_next;

    assign o_runstop = runstop_reg;
    assign o_clear = clear_reg;
    // state register
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            c_state <= STOP;
            runstop_reg <= 1'b0;
            clear_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            runstop_reg <= runstop_next;
            clear_reg <= clear_next;
        end
    end
    // next combinational logic
    always@(*) begin
        n_state = c_state;
        runstop_next = runstop_reg;
        clear_next = clear_reg;
        if(mod_sel == 1'b0) begin
        case(c_state)
            STOP : begin
                // moore output
                runstop_next = 1'b0;
                clear_next = 1'b0;
                // next state
                if(i_runstop) begin
                    n_state = RUN;
                end else if(i_clear) begin
                    n_state = CLEAR;
                end
            end
            RUN : begin
                runstop_next = 1'b1;            
                if(i_runstop) begin
                    n_state = STOP;
                end
            end
            CLEAR : begin
                clear_next = 1'b1;                
                n_state = STOP;
            end
        endcase
        end
    end
    // output logic
    // 현재 상태 출력을 next_combinational logic에 in
endmodule
