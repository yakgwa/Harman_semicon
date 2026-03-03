`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/05 09:20:08
// Design Name: 
// Module Name: inte_top
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

module inte_top(
    input clk,
    input rst,
    input rx,
    input start,
    input clear,
    input mode,
    output [13:0] o_count,
    output tx
    );

    //wire w_enable;
    wire w_clear;
    wire w_mode;
    wire w_rx_done;
    wire [7:0] w_rx_data;
    //wire [13:0] w_count;
    wire [7:0] w_rx_fifo_q;
    wire w_rx_fifo_empty, w_rx_fifo_pop_req;
    //wire [7:0] w_tx_fifo_push_data;
    wire       w_tx_fifo_push;
    wire       w_tx_fifo_full;
    wire       w_tx_busy;
    wire       w_tx_fifo_empty;
    wire [7:0] w_tx_fifo_popdata;
    wire       w_start_from_btn;
    wire       w_start_from_uart;
    wire       w_start;
    wire       w_b_tick;  
    wire       w_clear_from_uart; 
    wire       w_clear_from_btn; 
    wire       w_mode_from_uart;
    //wire       w_mode_from_btn;



    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );

    button_debounce U_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(start),
        .o_btn(w_start_from_btn)
    );

    button_debounce U_BD_1 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(clear),
        .o_btn(w_clear_from_btn)
    );

    // button_debounce_ori U_BD_2 (
    //     .clk  (clk),
    //     .rst  (rst),
    //     .i_btn(mode),
    //     .o_btn(w_mode_from_btn)
    // );

    assign w_start = w_start_from_btn | w_start_from_uart;
    assign w_clear = w_clear_from_btn | w_clear_from_uart;
    assign w_mode = w_mode_from_uart;

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

    fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_fifo_q),
        .push(w_rx_fifo_pop_req),
        .pop(~w_tx_busy),
        .pop_data(w_tx_fifo_popdata),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );


    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tx_start(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_popdata),
        .b_tick(w_b_tick),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    command_controller_1 U_COMMAND_CONTROLLER_1(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_fifo_q),
        .rx_trigger(~w_rx_fifo_empty),
        .i_btn(mode), //
        .o_pop(w_rx_fifo_pop_req),
        .o_start(w_start_from_uart),
        .o_clear(w_clear_from_uart),
        .o_mode(w_mode_from_uart)
    );


    counter_top U_COUNTER_TOP_1(
        .clk(clk),
        .rst(rst),
        .o_count(o_count),
        .enable(w_start),
        .clear(w_clear),
        .mode(w_mode)
    );


    // fnd_controller U_FND_CONTROLLER_1(
    //     .clk(clk),
    //     .rst(rst),
    //     .counter(w_count),
    //     .fnd_com(fnd_com),
    //     .fnd_data(fnd_data)
    // );

endmodule

module command_controller_1(
    input clk,
    input reset,
    input [7:0] rx_fifo_data,
    input rx_trigger,
    input i_btn,
    output o_pop,
    output o_start,
    output o_clear,
    output o_mode
    );

    reg o_mode_prev, rx_trigger_prev;
    reg btn_prev;

    assign o_pop = rx_trigger;
    assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));
    assign o_clear = (rx_trigger && (rx_fifo_data == 8'h72));
//    assign o_mode = (rx_trigger && (rx_fifo_data == 8'h6d));
    assign o_mode = o_mode_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_mode_prev <= 1'b0;
            rx_trigger_prev <= 1'b0;
            btn_prev <= i_btn;
        end else begin
            rx_trigger_prev <= rx_trigger;
            if (rx_trigger && !rx_trigger_prev) begin // Detect the rising edge of the trigger
                if (rx_fifo_data == 8'h6d) begin
                    o_mode_prev <= !o_mode_prev;
                end
            end
            if (i_btn && !btn_prev) begin
                o_mode_prev <= !o_mode_prev;
            end            
        end
    end
 endmodule

// module inte_top(
//     input clk,
//     input rst,
//     input rx,
//     input start,
//     input clear,
//     input mode,
//     output [3:0] fnd_com,
//     output [7:0] fnd_data,
//     output tx
//     );

//     wire w_enable;
//     wire w_clear;
//     wire w_mode;
//     wire w_rx_done;
//     wire [7:0] w_rx_data;
//     wire [13:0] w_count;
//     wire [7:0] w_rx_fifo_q;
//     wire w_rx_fifo_empty, w_rx_fifo_pop_req;
//     wire [7:0] w_tx_fifo_push_data;
//     wire       w_tx_fifo_push;
//     wire       w_tx_fifo_full;
//     wire       w_tx_busy;
//     wire       w_tx_fifo_empty;
//     wire [7:0] w_tx_fifo_popdata;
//     wire       w_start_from_btn;
//     wire       w_start_from_uart;
//     wire       w_start;
//     wire       w_b_tick;  
//     wire       w_clear_from_uart; 
//     wire       w_clear_from_btn; 
//     wire       w_mode_from_uart;
//     wire       w_mode_from_btn;



//     baud_tick_gen U_BAUD_TICK_GEN (
//         .clk(clk),
//         .rst(rst),
//         .o_b_tick(w_b_tick)
//     );

//     button_debounce U_BD (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(start),
//         .o_btn(w_start_from_btn)
//     );

//     button_debounce U_BD_1 (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(clear),
//         .o_btn(w_clear_from_btn)
//     );

//     // button_debounce_ori U_BD_2 (
//     //     .clk  (clk),
//     //     .rst  (rst),
//     //     .i_btn(mode),
//     //     .o_btn(w_mode_from_btn)
//     // );

//     assign w_start = w_start_from_btn | w_start_from_uart;
//     assign w_clear = w_clear_from_btn | w_clear_from_uart;
//     assign w_mode = w_mode_from_uart | w_mode_from_btn;

//     uart_rx U_UART_RX (
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .b_tick(w_b_tick),
//         .rx_data(w_rx_data),
//         .rx_done(w_rx_done)
//     );

//     fifo U_RX_FIFO (
//         .clk(clk),
//         .rst(rst),
//         .push_data(w_rx_data),
//         .push(w_rx_done),
//         .pop(w_rx_fifo_pop_req),
//         .pop_data(w_rx_fifo_q),
//         .full(),
//         .empty(w_rx_fifo_empty)
//     );

//     fifo U_TX_FIFO (
//         .clk(clk),
//         .rst(rst),
//         .push_data(w_rx_fifo_q),
//         .push(w_rx_fifo_pop_req),
//         .pop(~w_tx_busy),
//         .pop_data(w_tx_fifo_popdata),
//         .full(w_tx_fifo_full),
//         .empty(w_tx_fifo_empty)
//     );


//     uart_tx U_UART_TX (
//         .clk(clk),
//         .rst(rst),
//         .tx_start(~w_tx_fifo_empty),
//         .tx_data(w_tx_fifo_popdata),
//         .b_tick(w_b_tick),
//         .tx_busy(w_tx_busy),
//         .tx(tx)
//     );

//     command_controller_1 U_COMMAND_CONTROLLER(
//         .clk(clk),
//         .reset(rst),
//         .rx_fifo_data(w_rx_fifo_q),
//         .rx_trigger(~w_rx_fifo_empty),
//         .i_btn(mode), //
//         .o_pop(w_rx_fifo_pop_req),
//         .o_start(w_start_from_uart),
//         .o_clear(w_clear_from_uart),
//         .o_mode(w_mode_from_uart)
//     );


//     counter_top U_COUNTER_TOP_1(
//         .clk(clk),
//         .rst(rst),
//         .o_count(w_count),
//         .enable(w_start),
//         .clear(w_clear),
//         .mode(w_mode)
//     );


//     fnd_controller U_FND_CONTROLLER_1(
//         .clk(clk),
//         .rst(rst),
//         .counter(w_count),
//         .fnd_com(fnd_com),
//         .fnd_data(fnd_data)
//     );

// endmodule

// // module command_controller_1(
// //     input        clk,
// //     input        reset,
// //     input  [7:0] rx_fifo_data,
// //     input        rx_trigger,
// //     output       o_pop,
// //     output       o_start,
// //     output       o_clear,
// //     output       o_mode
// //     );

// //     assign o_pop = rx_trigger;
// //     assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));
// //     assign o_clear = (rx_trigger && (rx_fifo_data == 8'h72));
// //     assign o_mode = (rx_trigger && (rx_fifo_data == 8'h6d));

// // endmodule

// module command_controller_1(
//     input clk,
//     input reset,
//     input [7:0] rx_fifo_data,
//     input rx_trigger,
//     input i_btn,
//     output o_pop,
//     output o_start,
//     output o_clear,
//     output o_mode
//     );

//     reg o_mode_prev, rx_trigger_prev;
//     reg btn_prev;

//     assign o_pop = rx_trigger;
//     assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));
//     assign o_clear = (rx_trigger && (rx_fifo_data == 8'h72));
//    assign o_mode = (rx_trigger && (rx_fifo_data == 8'h6d));
//     assign o_mode = o_mode_prev;

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             o_mode_prev <= 1'b0;
//             rx_trigger_prev <= 1'b0;
//             btn_prev <= i_btn;
//         end else begin
//             rx_trigger_prev <= rx_trigger;
//             if (rx_trigger && !rx_trigger_prev) begin // Detect the rising edge of the trigger
//                 if (rx_fifo_data == 8'h6d) begin
//                     o_mode_prev <= !o_mode_prev;
//                 end
//             end
//             if (i_btn && !btn_prev) begin
//                 o_mode_prev <= !o_mode_prev;
//             end            
//         end
//     end
//  endmodule

// module command_controller_1(
//     input clk,
//     input reset,
//     input [7:0] rx_fifo_data,
//     input rx_trigger,
//     output o_pop,
//     output o_start,
//     output o_clear,
//     output o_mode
//     );

//     reg o_mode_prev, rx_trigger_prev;

//     assign o_pop = rx_trigger;
//     assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));
//     assign o_clear = (rx_trigger && (rx_fifo_data == 8'h72));
// //    assign o_mode = (rx_trigger && (rx_fifo_data == 8'h6d));
//     assign o_mode = o_mode_prev;

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             o_mode_prev <= 1'b0;
//             rx_trigger_prev <= 1'b0;
//         end else begin
//             rx_trigger_prev <= rx_trigger;
//             if (rx_trigger && !rx_trigger_prev) begin // Detect the rising edge of the trigger
//                 if (rx_fifo_data == 8'h6d) begin
//                     o_mode_prev <= !o_mode_prev;
//                 end
//             end
//         end
//     end
//  endmodule


// //////////////// loop back //////////////////
// module uart_top_1(
//     input clk,
//     input rst,
//     //input btn_r,
//     input rx,
//     output tx
//     //output rx_trigger,
//     //output [7:0] rx_fifo_data
//     );

//     wire w_start;
//     wire w_b_tick;
//     wire rx_done;
//     wire [7:0] w_rx_data , w_rx_fifio_popdata, w_tx_fifio_popdata;
//     wire w_rx_empty, w_tx_fifo_full, w_tx_fifo_empty, w_tx_busy;

//     assign rx_fifo_data = w_rx_data;
//     assign rx_trigger   = ~w_rx_empty;

//     // button_debounce U_BD_START(
//     //     .clk(clk), 
//     //     .rst(rst),
//     //     .i_btn(btn_r),
//     //     .o_btn(w_start)
//     // );

//     uart_tx U_UART_TX(
//         .clk(clk),
//         .rst(rst),
//         .tx_start(~w_tx_fifo_empty),
//         .tx_data(w_tx_fifio_popdata),
//         .b_tick(w_b_tick),
//         .tx(tx),
//         .tx_busy(w_tx_busy)
//     );

//     fifo U_TX_FIFO(
//         .clk(clk),
//         .rst(rst),
//         .push_data(w_rx_fifio_popdata), 
//         .push(~w_rx_empty),        
//         .pop(~w_tx_busy),                // from uart tx
//         .pop_data(w_tx_fifio_popdata),           // to uart tx 
//         .full(w_tx_fifo_full),
//         .empty(w_tx_fifo_empty)               // to uart tx 
//         );


//     fifo U_RX_FIFO(
//         .clk(clk),
//         .rst(rst),
//         .push_data(w_rx_data), // from uart rx
//         .push(rx_done),        // from uart rx
//         .pop(~w_tx_fifo_full),                // to tx fifo
//         .pop_data(w_rx_fifio_popdata),           // to tx fifo
//         .full(),
//         .empty(w_rx_empty)               // to tx fifo
//         );


//     uart_rx U_UART_RX(
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .b_tick(w_b_tick),
//         .rx_data(w_rx_data),
//         .rx_done(rx_done)
//     );

//     baud_tick_gen U_BAUD_TICK_GEN(
//         .clk(clk),
//         .rst(rst),
//         .o_b_tick(w_b_tick)
//     );


// endmodule

// // module uart_top_1(
// //     input clk,
// //     input rst,
// //     input tx_start,
// //     input [7:0] tx_data,
// //     output tx_busy,
// //     output tx,
// //     input rx,
// //     output [7:0] rx_data,
// //     output rx_done
// //     );

// //     wire w_b_tick;
// //     wire [7:0] w_rx_data;
// //     wire w_rx_done;

// //     uart_rx U_UART_RX_1(
// //         .clk(clk),
// //         .rst(rst),
// //         .b_tick(w_b_tick),
// //         .rx(rx),
// //         .rx_data(rx_data),
// //         .rx_done(rx_done)
// //     );

// //     baud_tick_gen U_BAUD_TICK_1(
// //         .clk(clk),
// //         .rst(rst),
// //         .o_b_tick(w_b_tick)
// //     );    

// //     uart_tx U_UART_TX_1(
// //         .clk(clk),
// //         .rst(rst),
// //         .b_tick(w_b_tick),
// //         .tx_start(tx_start),
// //         .tx_data(tx_data),
// //         .tx_busy(tx_busy),
// //         .tx(tx)


// //     );
// // endmodule
