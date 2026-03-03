`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 11:00:13
// Design Name: 
// Module Name: button_debounce
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


module button_debounce(
    input clk,
    input rst,
    input i_btn,
    output o_btn
    );

    parameter [2:0] IDLE = 3'b000, A = 3'b001, B = 3'b010, C = 3'b011, D = 3'b100;

    reg [2:0] state, state_next;
    reg flag_reg, flag_next;

    // edge detect
    // assign으로 FF delay로 처리도 가능

    reg o_btn_reg, o_btn_next;

    //assign o_btn = flag_reg;
    assign o_btn = o_btn_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            flag_reg  <= 0;
            o_btn_reg <= 0;
        end else begin
            state       <= state_next;
            flag_reg  <= flag_next;
            o_btn_reg <= o_btn_next;
        end
    end

    always @(*) begin
        state_next   = state;
        flag_next  = flag_reg;
        o_btn_next = 1'b0; // 항상 0일 때 한번만 1로 out
        case (state)
            IDLE: begin
                flag_next = 1'b0;   // moore output
                if (i_btn) begin    // mealy output
                    state_next = A; 
                end 
            end
            A: begin
                flag_next = 1'b0;
                if (i_btn) begin
                    state_next = B;
                end else begin
                    state_next =IDLE;
                end
            end
            B: begin
                flag_next = 1'b0;
                if (i_btn) begin
                    state_next = C;
                end else begin
                    state_next =IDLE;
                end
            end
            C: begin
                flag_next = 1'b0;
                if (i_btn) begin
                    o_btn_next = 1'b1; // 한번만 발생하게 하려면 D로 넘어갈때 부분에 추가
                    state_next = D;
                end else begin
                    state_next =IDLE;
                end
            end
            D: begin
                flag_next = 1'b1;
                if (i_btn) begin
                    state_next = D;
                end else begin
                    state_next =IDLE;
                end
            end

        endcase
    end
endmodule

