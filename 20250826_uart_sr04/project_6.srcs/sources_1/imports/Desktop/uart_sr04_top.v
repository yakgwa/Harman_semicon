`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/22 10:21:28
// Design Name: 
// Module Name: uart_sr04_top
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


module uart_sr04_top(
    input clk,
    input rst,
    input start,
    input echo,
    output trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    input rx,
    output tx
    );

    // wire w_tick_1us;
    // wire [8:0] w_dist;
    // wire w_rx_trigger;
    // wire [7:0] w_rx_fifo_data;
    // wire w_receive;
    // wire w_start;
    // wire [7:0] w_split_data_1000, w_split_data_100, w_split_data_10, w_split_data_1, w_o_bcd;
    // wire w_echo_done, w_enable_wr;

    wire       w_tick_gen_1us;
    wire       w_b_tick;

    wire       w_start_from_btn;
    wire       w_start_from_uart;
    wire       w_start;

    wire [8:0] w_dist;
    wire       w_measure_done;

    wire [7:0] w_rx_data, w_rx_fifo_q;
    wire w_rx_done;
    wire w_rx_fifo_empty, w_rx_fifo_pop_req;

    wire [7:0] w_tx_fifo_push_data;
    wire       w_tx_fifo_push;
    wire       w_tx_fifo_full;
    wire       w_tx_busy;
    wire       w_tx_fifo_empty;
    wire [7:0] w_tx_fifo_popdata;

    wire [31:0] w_o_data;


    tick_gen_1us U_tick_gen_1us (
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_tick_gen_1us)
    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );

    button_debounce U_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(start),
        .o_btn(w_start_from_btn)
    );

    assign w_start = w_start_from_btn | w_start_from_uart;

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_data),
        .push(w_rx_done),
        .pop(w_rx_fifo_pop_req),
        .pop_data(w_rx_fifo_q),
        .full(),
        .empty(w_rx_fifo_empty)
    );

    receive_controller U_RECEIVE_CONTROLLER(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_fifo_q),
        .rx_trigger(~w_rx_fifo_empty),
        .o_pop(w_rx_fifo_pop_req),
        .o_start(w_start_from_uart)
    );

    sr04_controller U_SR04_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .start(w_start),
        .echo(echo),
        .i_tick(w_tick_gen_1us),
        .o_trig(trig),
        .o_dist(w_dist),
        .o_echo_done(w_echo_done)
    );

    datatoascii U_DATATOASCII(
        .i_data({5'b0,w_dist}),
        .o_data(w_o_data)
    );

    send_controller U_SEND_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .i_data(w_o_data),
        .echo_done(w_echo_done),
        .o_start(w_tx_fifo_push),
        .o_bcd(w_tx_fifo_push_data),
        .tx_busy(w_tx_fifo_full)
        );

    fnd_controller U_FND_CU (
        .clk(clk),
        .reset(rst),
        .counter({5'b0, w_dist}),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_popdata),
        .b_tick(w_b_tick),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_tx_fifo_push_data),
        .push(w_tx_fifo_push),
        .pop(~w_tx_busy),
        .pop_data(w_tx_fifo_popdata),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );


endmodule

module receive_controller(
//     input        clk,
//     input        reset,
//     input  [7:0] rx_fifo_data,
//     input        rx_trigger,
//     output       o_pop,
//     output       o_start
// );

//     assign o_pop = rx_trigger;
//     assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));


    input clk,
    input reset,
    input [7:0] rx_fifo_data,
    input rx_trigger,
    output o_pop,
    output o_start
    );

    
    parameter IDLE = 2'b00, RECEIVE = 2'b01;
    reg [1:0] c_state, n_state;
    reg pop_reg, pop_next;
    reg start_reg, start_next;

    assign o_pop = pop_reg;
    assign o_start = start_reg;

    // state register
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            c_state <= IDLE;
            pop_reg <= 1'b0;
            start_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            pop_reg <= pop_next;
            start_reg <= start_next;
        end
    end
    // next combinational logic
    always@(*) begin
        n_state = c_state;
        pop_next = 1'b0;//send_reg;
        start_next = 1'b0;//start_reg;
        case(c_state)
            IDLE : begin          
                if(rx_trigger) begin 
                    n_state = RECEIVE;
                    pop_next = 1'b1;
                end
            end          
            RECEIVE : begin
                n_state = IDLE;
                if(rx_fifo_data == 8'h64) begin
                    start_next = 1'b1;
                end
            end
        endcase
    end                
endmodule


module datatoascii(
    input [13:0] i_data, // 0000 ~ 9999
    output [31:0] o_data
    );

    assign o_data[7:0] = i_data % 10 + 8'h30; // o_data[7:0]
    assign o_data[15:8] = (i_data/10) % 10 + 8'h30; // o_data[15:8]
    assign o_data[23:16] = (i_data/100) % 10 + 8'h30; // o_data[23:16]
    assign o_data[31:24] = (i_data/1000) % 10 + 8'h30; // o_data[31:24]
endmodule

module send_controller(
    input clk,
    input rst,
    input [31:0] i_data,
    input echo_done,
    output o_start,
    output [7:0] o_bcd,
    input tx_busy
);

    parameter IDLE = 3'b000, WAIT = 3'b001, DIGIT_1000 = 3'b010, DIGIT_100 = 3'b100, DIGIT_10 = 3'b101, DIGIT_1 = 3'b110;
    // DIGIT_1000 = 3'b001, DIGIT_100 = 3'b010, DIGIT_10 = 3'b100, DIGIT_1 = 3'b101;
    //reg clk_reg, clk_next;
    reg [3:0] state, next;
    reg [3:0] digit_1000_reg, digit_100_reg, digit_10_reg, digit_1_reg;
    reg [7:0] o_bcd_reg, o_bcd_next;
    reg o_start_reg, o_start_next;

    assign o_bcd = o_bcd_reg;
    assign o_start = o_start_reg;

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            digit_1000_reg <= 0;
            digit_100_reg <= 0;
            digit_10_reg  <= 0;
            digit_1_reg   <= 0;
        end else begin
            state <= next;
            o_bcd_reg <= o_bcd_next;
            o_start_reg <= o_start_next;
            if (next == WAIT) begin
                digit_1000_reg <= i_data[31:24];
                digit_100_reg <= i_data[23:16];
                digit_10_reg <= i_data[15:8];
                digit_1_reg <= i_data[7:0];                
            end
        end
    end

    always @(*) begin
        next = state;
        o_start_next = 1'b0;
        o_bcd_next  = o_bcd_reg;
        case (state)
            IDLE: begin
                if (echo_done == 1) begin
                    next = WAIT;
                end
            end
            WAIT: begin
                next = DIGIT_1000;
            end

            DIGIT_1000: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_1000_reg + 8'h30;
                    next = DIGIT_100;
                end
            end
            DIGIT_100: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_100_reg + 8'h30;
                    next = DIGIT_10;
                end
            end
            DIGIT_10: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_10_reg + 8'h30;
                    next = DIGIT_1;
                end
            end
            DIGIT_1: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_1_reg + 8'h30;
                    next = IDLE;
                end
            end            
        endcase
    end

endmodule


//     always@(*)begin
//         next = state;
//         clk_next = 1'b0;
//         o_start = 1'b0;
//         case(state)
//             IDLE : begin
//                 if(echo_done == 1) begin
//                     clk_next = 0;
//                     next = DIGIT_1000;
//                 end else begin
//                     next = IDLE;
//                 end
//             end
//             DIGIT_1000 : begin
//                 o_bcd = i_data[7:0];
//                 o_start = 1'b1;
//                 if(clk_reg == 1) begin
//                     o_start = 1'b0;
//                     clk_reg = 0;
//                     next = DIGIT_100;
//                 end else begin
//                     clk_next = clk_reg + 1;
//                 end
//                 //next = WAIT_100;
//             end
//             // WAIT_1000 : begin
//             //     enable_wr = 1'b1;
//             //     o_bcd = split_data_1000;
//             //     next = DIGIT_100;
//             // end
//             DIGIT_100 : begin
//                 o_bcd = i_data[15:8];
//                 o_start = 1'b1;
//                 if(clk_reg == 1) begin
//                     o_start = 1'b0;
//                     clk_reg = 0;
//                     next = DIGIT_10;
//                 end else begin
//                     clk_next = clk_reg + 1;
//                 end
//             end
//             DIGIT_10 : begin
//                 o_bcd = i_data[23:16];
//                 o_start = 1'b1;
//                 if(clk_reg == 1) begin
//                     o_start = 1'b0;
//                     clk_reg = 0;
//                     next = DIGIT_1;
//                 end else begin
//                     clk_next = clk_reg + 1;
//                 end
//             end
//             DIGIT_1 : begin
//                 o_bcd = i_data[31:24];
//                 o_start = 1'b1;
//                 if(clk_reg == 1) begin
//                     o_start = 1'b0;
//                     clk_reg = 0;
//                     next = IDLE;
//                 end else begin
//                     clk_next = clk_reg + 1;
//                 end
//             end
//         endcase
//     end
// endmodule