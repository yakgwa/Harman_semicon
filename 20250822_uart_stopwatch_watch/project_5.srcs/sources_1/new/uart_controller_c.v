`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/19 15:08:46
// Design Name: 
// Module Name: uart_controller_c
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


module uart_controller_c(
    input clk,
    input reset,
    input [7:0] rx_fifo_data,
    input rx_trigger,
    output o_run,
    output o_clear,
    output o_sel,
    output o_sec_inc,
    output o_min_inc,
    output o_hour_inc,
    output o_btn_0,
    output o_btn_1
    );

    //parameter IDLE = 3'b000, STOP = 3'b001, RUN = 3'b010, CLEAR = 3'b011, SEL = 3'b100, SEC_INC = 3'b101, MIN_INC = 3'b110, HOUR_INC = 3'b111;
    parameter IDLE = 4'b0000, STOP = 4'b0001, RUN = 4'b0010, CLEAR = 4'b0011, SEL = 4'b0100, SEC_INC = 4'b0101, MIN_INC = 4'b0110, HOUR_INC = 4'b0111, BTN_0 = 4'b1000, BTN_1 = 4'b1001;
    //reg [3:0] c_state, n_state;
    reg [4:0] c_state, n_state;
    reg runstop_reg, runstop_next;
    reg clear_reg, clear_next;
    reg sel_reg, sel_next;
    reg sec_inc_reg, sec_inc_next;
    reg min_inc_reg, min_inc_next;
    reg hour_inc_reg, hour_inc_next;
    reg btn_0_reg, btn_0_next;
    reg btn_1_reg, btn_1_next;

    assign o_run = runstop_reg;
    assign o_clear = clear_reg;
    assign o_sel = sel_reg;
    assign o_sec_inc = sec_inc_reg;
    assign o_min_inc = min_inc_reg;
    assign o_hour_inc = hour_inc_reg;
    assign o_btn_0 = btn_0_reg;
    assign o_btn_1 = btn_1_reg;

    // state register
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            c_state <= IDLE;
            runstop_reg <= 1'b0;
            clear_reg <= 1'b0;
            sel_reg <= 1'b0;
            sec_inc_reg <= 1'b0;
            min_inc_reg <= 1'b0;
            hour_inc_reg <= 1'b0;
            btn_0_reg <= 1'b0;
            btn_1_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            runstop_reg <= runstop_next;
            clear_reg <= clear_next;
            sel_reg <= sel_next;
            sec_inc_reg <= sec_inc_next;
            min_inc_reg <= min_inc_next;
            hour_inc_reg <= hour_inc_next;
            btn_0_reg <= btn_0_next;
            btn_1_reg <= btn_1_next;
        end
    end
    // next combinational logic
    always@(*) begin
        n_state = c_state;
        runstop_next = runstop_reg;
        clear_next = clear_reg;
        sel_next = sel_reg;
        sec_inc_next = 1'b0;//sec_inc_reg;
        min_inc_next = 1'b0;//min_inc_reg;
        hour_inc_next = 1'b0;//hour_inc_reg;
        btn_0_next = btn_0_reg;//1'b0;
        btn_1_next = btn_1_reg;//1'b0;
        case(c_state)
            IDLE : begin          
                if(rx_trigger && rx_fifo_data == 8'h72) begin // r
                    n_state = RUN;
                end else if(rx_trigger && rx_fifo_data == 8'h73) begin // s
                    n_state = STOP;                     
                end else if(rx_trigger && rx_fifo_data == 8'h63) begin // c
                    n_state = CLEAR;  
                end else if(rx_trigger && rx_fifo_data == 8'h62) begin // b
                    n_state = SEL;    
                end else if(rx_trigger && rx_fifo_data == 8'h75) begin // u
                    n_state = SEC_INC;    
                end else if(rx_trigger && rx_fifo_data == 8'h6c) begin // l
                    n_state = MIN_INC;    
                end else if(rx_trigger && rx_fifo_data == 8'h64) begin // d
                    n_state = HOUR_INC;   
                end else if(rx_trigger && rx_fifo_data == 8'h6f) begin // o
                    n_state = BTN_0;                
                end else if(rx_trigger && rx_fifo_data == 8'h70) begin // p
                    n_state = BTN_1;  
                end
            end
            STOP : begin
                runstop_next = 1'b0;   
                n_state = IDLE;    
            end
            RUN : begin
                runstop_next = 1'b1;    
                n_state = IDLE;        
            end
            CLEAR : begin
                clear_next = 1'b1;            
                n_state = IDLE;
            end     
            SEL : begin
                sel_next = 1'b1;         
                n_state = IDLE;
            end   
            SEC_INC : begin
                sec_inc_next = 1'b1;         
                n_state = IDLE;
            end   
            MIN_INC : begin
                min_inc_next = 1'b1;         
                n_state = IDLE;
            end   
            HOUR_INC : begin
                hour_inc_next = 1'b1;         
                n_state = IDLE;
            end      
            BTN_0 : begin
                btn_0_next = ~btn_0_reg;//1'b1;         
                n_state = IDLE;
            end  
            BTN_1 : begin
                btn_1_next = ~btn_1_reg;//1'b1;         
                n_state = IDLE;
            end                                               
        endcase
    end

endmodule
