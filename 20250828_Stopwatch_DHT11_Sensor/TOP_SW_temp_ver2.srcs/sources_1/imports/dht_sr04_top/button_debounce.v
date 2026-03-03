`timescale 1ns / 1ps
module button_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    reg [7:0] q_reg, q_next;
    reg edge_reg;
    wire debounce;

    // clock divider
    reg[$clog2(1000)-1:0] counter_reg;
    reg clk_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            clk_reg <= 0;
        end else begin
            if (counter_reg == 999) begin
                counter_reg <= 0;
                clk_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg <= 1'b0;
            end
        end
    end



    // debounce
    always @(posedge clk_reg, posedge rst) begin
        if (rst) begin
            q_reg <= 8'b0;
        end else begin
            q_reg <= q_next;
        end
    end

        // push upper 3 bit to next 3 register => serial input parallel output shift register
        always @(*) begin
            q_next = {i_btn,q_reg[7:1]};
        end
        // 4 input AND
        assign debounce = &q_reg;
        
        // Q5 out 
        always @(posedge clk, posedge rst) begin
            if (rst) begin
                edge_reg <= 1'b0;
            end else begin
                edge_reg <= debounce;
            end
        end

        // edge output
        assign o_btn = ~edge_reg & debounce;

    endmodule
