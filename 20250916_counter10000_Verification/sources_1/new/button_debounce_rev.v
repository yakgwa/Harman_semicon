`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 17:12:13
// Design Name: 
// Module Name: button_debounce_rev
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


module button_debounce_rev(
    input clk,
    input rst,
    input i_btn,
    output o_btn
    );

    parameter [2:0] IDLE = 3'b000, A = 3'b001, B = 3'b010, C = 3'b011, D = 3'b100;

    reg [2:0] state, state_next;
    reg flag_reg, flag_next;

    reg[$clog2(100)-1:0] counter_reg;
    reg clk_reg;
    reg edge_reg;
    wire debounce;
    // edge detect
    // assign으로 FF delay로 처리도 가능
    //assign o_btn = flag_reg;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if(counter_reg == 9) begin //99
                counter_reg <= 0;
                clk_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg <= 1'b0;
            end
        end
    end


    always @(posedge clk_reg or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            flag_reg  <= 0;
        end else begin
            state       <= state_next;
            flag_reg  <= flag_next;
        end
    end

    always @(*) begin
        state_next   = state;
        flag_next  = flag_reg;
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

    assign debounce = &flag_reg; 

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end

    assign o_btn = ~edge_reg & debounce;


endmodule


