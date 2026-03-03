`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/11 00:41:39
// Design Name: 
// Module Name: spi_ctrl
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


module spi_ctrl(
    input logic clk,
    input logic reset,
    input logic btn,
    input logic [13:0] counter,

    input logic cs,
    input logic si_done,
    input logic [7:0]  si_data,

    output logic [15:0] fndData,
    output logic [7:0] tx_data,
    output logic start
);

    parameter IDLE = 0, L_BYTE = 1, L_DATA=2, H_BYTE = 3, H_DATA=4;
    wire o_btn;
    logic [2:0] state, state_next;
    logic [7:0] LData_reg, LData_next;
    logic [7:0] HData_reg, HData_next;
    logic [15:0] FndData_reg, FndData_next;
    logic [7:0] tx_data_reg, tx_data_next;
    logic start_reg, start_next;

    assign fndData = FndData_reg;
    assign tx_data = tx_data_reg;
    assign start = start_reg;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            tx_data_reg <= 8'b0;
            start_reg <= 0;
        end else begin
            state     <= state_next;
            FndData_reg <= FndData_next;
            LData_reg   <= LData_next;
            HData_reg   <= HData_next;
            tx_data_reg <= tx_data_next;
            start_reg <= start_next;            
        end
    end

    always_comb begin
        state_next = state;
        FndData_next  = FndData_reg;
        LData_next    = LData_reg;
        HData_next    = HData_reg;
        tx_data_next = tx_data_reg;
        start_next = 0;          
        case (state)
            IDLE: begin
                FndData_next = {HData_reg, LData_reg};
                if (btn) begin
                    start_next = 1;
                    state_next = L_BYTE;
                    tx_data_next = counter[7:0];
                end
            end
            L_BYTE: begin
                if (!cs) begin
                    if (si_done) begin
                        state_next = L_DATA;
                    end
                end
            end
            L_DATA : begin
                start_next = 1;
                LData_next    = si_data;
                state_next = H_BYTE;
                tx_data_next = {2'b00, counter[13:8]};
            end
            H_BYTE: begin
                if (!cs) begin
                    if (si_done) begin
                        state_next = H_DATA;
                    end
                end
            end
            H_DATA: begin
                HData_next    = si_data;
		        //FndData_next = {si_data, LData_reg};
                state_next = IDLE;             
            end
        endcase
    end

    // btn_debounce U_BTN_DEBOUNCE (
    //     .clk  (clk),
    //     .reset(reset),
    //     .i_btn(btn),
    //     .o_btn(o_btn)
    // );

endmodule

module btn_debounce(
    input logic clk,
    input logic reset,
    input logic i_btn,
    output logic o_btn
    );
    wire btn_debounce;

    // state
    logic [7:0] q_reg, q_next;
    logic edge_detect;
    logic r_1khz;

    // 1khz clk
    parameter COUNT =100_000;
    logic [$clog2(COUNT)-1:0] counter;
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            r_1khz <= 1'b0;
        end else begin
            if (counter == COUNT -1) begin
                counter <=0;
                r_1khz <=1'b1;
            end else begin
                counter <= counter +1;
                r_1khz <=1'b0;
            end
        end

    end

    always_ff @(posedge r_1khz or posedge reset) begin
        if(reset) q_reg <=0;
        else q_reg <= q_next;
    end
    // next logic
    always_comb begin
    //always @(i_btn, r_1khz) begin
        q_next = {i_btn, q_reg[7:1]};
    end 
    
    // 8 input AND gate
    assign btn_debounce = ~&q_reg;

    //edge detector

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            edge_detect <= 0;
        end else begin
            edge_detect <= btn_debounce;
        end
    end

    //edge detector 최종 출력
    assign o_btn =(~edge_detect) & btn_debounce;


endmodule
